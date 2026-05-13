IF EXISTS
(
    SELECT 1
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[USP_UPD_SEPCNGastosPE]')
      AND type = 'P'
)
BEGIN
    DROP PROCEDURE [dbo].[USP_UPD_SEPCNGastosPE];
END
GO

CREATE PROCEDURE [dbo].[USP_UPD_SEPCNGastosPE]
(
    @IdUsuario    INT,
    @IdContrato   INT,
    @MotivoCambio NVARCHAR(2000) = N'',
    @Data         Type_UPD_SEPCNGastosPE READONLY
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Fecha DATETIME = GETDATE();

    DROP TABLE IF EXISTS #Data;
    DROP TABLE IF EXISTS #DataGasto;
    DROP TABLE IF EXISTS #ResumenRegistrosActualizados;
    DROP TABLE IF EXISTS #BitacoraCambios;

    CREATE TABLE #Data
    (
        FilaExcel                   INT,
        IdPedimentoComprobante      INT           NULL,
        IdPedimentoComprobanteRaw   NVARCHAR(100) NULL,   -- Valor original del Excel para trazabilidad
        IdRegistro                  INT           NULL,
        CodigoSE                    NVARCHAR(100),
        IdActividad                 INT           NULL,
        IdContrato                  INT,
        Observaciones               NVARCHAR(MAX),
        ConDetalle                  BIT,
        ConDetallePedimento         BIT,
        ConDetalleCodigo            BIT,
        TipoDocumento               INT           NULL
    );

    CREATE TABLE #DataGasto
    (
        IdPedimentoComprobante INT,
        IdRegistro             INT,
        IdCBSISH               INT,
        PCN                    FLOAT,
        IdUsuarioModPor        INT,
        ModificadoEn           DATETIME
    );

    CREATE TABLE #ResumenRegistrosActualizados
    (
        IdPedimentoComprobante INT,
        Registros              NVARCHAR(MAX)
    );

    CREATE TABLE #BitacoraCambios
    (
        TipoDocumento          INT,
        IdPedimentoComprobante INT,
        Detalle                NVARCHAR(MAX)
    );

    DECLARE @IdProceso UNIQUEIDENTIFIER = NEWID();  -- Identificador único del proceso de importación

    BEGIN TRY
        BEGIN TRAN;

        -- 1. Cargar datos del TVP
        INSERT INTO #Data
        (
            FilaExcel,
            IdPedimentoComprobante,
            IdPedimentoComprobanteRaw,
            CodigoSE,
            IdContrato,
            Observaciones,
            ConDetalle,
            ConDetallePedimento,
            ConDetalleCodigo,
            TipoDocumento
        )
        SELECT
            FilaExcel,
            IdPedimentoComprobante,
            IdPedimentoComprobanteRaw,
            ISNULL(LTRIM(RTRIM(CodigoSE)), N''),
            IdContrato,
            ISNULL(Observaciones, N''),
            CASE WHEN LEN(LTRIM(RTRIM(ISNULL(Observaciones, N'')))) > 0 THEN 1 ELSE 0 END,
            CASE WHEN IdPedimentoComprobante IS NULL THEN 1 ELSE 0 END,
            CASE WHEN LEN(LTRIM(RTRIM(ISNULL(CodigoSE, N'')))) > 0 THEN 0 ELSE 1 END,
            NULL
        FROM @Data;

        -- 2. Resolver tipo de documento si existe
        UPDATE #Data
        SET TipoDocumento = ISNULL(FI_PedimentoComprobante.cvtipodocfacturacion, 0)
        FROM #Data
        LEFT JOIN FI_PedimentoComprobante (NOLOCK)
            ON #Data.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante;

        -- Prefijo separador para observaciones existentes
        UPDATE #Data
        SET Observaciones = N' | ' + Observaciones
        WHERE ConDetalle = 1;

        -- 3. Validar que el pedimento/comprobante exista en el contrato
        UPDATE #Data
        SET Observaciones = Observaciones + N' | El pedimento/comprobante no se encuentra registrado en el sistema o en el contrato.',
            ConDetalle    = 1
        WHERE ConDetallePedimento = 0
          AND NOT EXISTS
          (
              SELECT 1
              FROM CO_Registro (NOLOCK)
              INNER JOIN FI_PedimentoComprobante (NOLOCK)
                  ON CO_Registro.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
              WHERE CO_Registro.IdPedimentoComprobante = #Data.IdPedimentoComprobante
                AND FI_PedimentoComprobante.IdContrato              = #Data.IdContrato
          );

        -- 4. Validar y resolver CodigoSE -> IdActividad
        UPDATE #Data
        SET IdActividad   = MM_BS_Actividad.IdActividad,
            Observaciones = CASE
                                WHEN ISNULL(MM_BS_Actividad.Activo, 0) = 0
                                THEN Observaciones + N' | El Código SE no se encuentra como activo.'
                                ELSE Observaciones
                            END,
            ConDetalle    = CASE
                                WHEN ISNULL(MM_BS_Actividad.Activo, 0) = 0 THEN 1
                                ELSE ConDetalle
                            END
        FROM #Data
        INNER JOIN MM_BS_Actividad (NOLOCK)
            ON  #Data.ConDetalleCodigo = 0
            AND #Data.CodigoSE = ISNULL(LTRIM(RTRIM(MM_BS_Actividad.Codigo)), N'');

        UPDATE #Data
        SET Observaciones = Observaciones + N' | El Código SE no se encuentra registrado.',
            ConDetalle    = 1
        WHERE ConDetalleCodigo = 0
          AND IdActividad IS NULL;

        -- 5. Preparar gastos a actualizar
        INSERT INTO #DataGasto
        (
            IdPedimentoComprobante,
            IdRegistro,
            IdCBSISH,
            PCN,
            IdUsuarioModPor,
            ModificadoEn
        )
        SELECT
            #Data.IdPedimentoComprobante,
            CO_Registro.IdRegistro,
            #Data.IdActividad,
            0,
            @IdUsuario,
            @Fecha
        FROM #Data
        INNER JOIN CO_Registro (NOLOCK)
            ON  #Data.ConDetalle             = 0
            AND #Data.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante
        INNER JOIN FI_PedimentoComprobante (NOLOCK)
            ON  CO_Registro.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
            AND FI_PedimentoComprobante.IdContrato = #Data.IdContrato
        GROUP BY
            #Data.IdPedimentoComprobante,
            CO_Registro.IdRegistro,
            #Data.IdActividad;

        -- 6. Actualizar CO_Registro
        UPDATE CO_Registro
        SET CO_Registro.IdCBSISH        = #DataGasto.IdCBSISH,
            CO_Registro.PCN             = #DataGasto.PCN,
            CO_Registro.IdUsuarioModPor = #DataGasto.IdUsuarioModPor,
            CO_Registro.ModificadoEn    = #DataGasto.ModificadoEn
        FROM CO_Registro
        INNER JOIN #DataGasto
            ON CO_Registro.IdRegistro = #DataGasto.IdRegistro;

        -- 7. Marcar registros sin gastos
        UPDATE #Data
        SET Observaciones = #Data.Observaciones + N' | El pedimento/comprobante no cuenta con registros de gastos.',
            ConDetalle    = 1
        FROM #Data
        LEFT JOIN #DataGasto
            ON #Data.IdPedimentoComprobante = #DataGasto.IdPedimentoComprobante
        WHERE #Data.ConDetalle = 0
          AND #DataGasto.IdPedimentoComprobante IS NULL;

        -- 8. Obtener resumen de registros actualizados por pedimento/comprobante
        INSERT INTO #ResumenRegistrosActualizados
        (
            IdPedimentoComprobante,
            Registros
        )
        SELECT
            #DataGasto.IdPedimentoComprobante,
            STUFF
            (
                (
                    SELECT N', ' + CAST(dg2.IdRegistro AS NVARCHAR(20))
                    FROM #DataGasto dg2
                    WHERE dg2.IdPedimentoComprobante = #DataGasto.IdPedimentoComprobante
                    FOR XML PATH(''), TYPE
                ).value('.', 'NVARCHAR(MAX)'),
                1, 2, N''
            )
        FROM #DataGasto
        GROUP BY #DataGasto.IdPedimentoComprobante;

        -- 9. Agregar IDs de registros actualizados a Observaciones
        UPDATE #Data
        SET Observaciones = CAST(#Data.Observaciones AS NVARCHAR(MAX))
                            + N' | Se actualizaron los registros con identificador: '
                            + #ResumenRegistrosActualizados.Registros
                            + N' relacionados con este pedimento/comprobante.'
        FROM #Data
        INNER JOIN #ResumenRegistrosActualizados
            ON #Data.IdPedimentoComprobante = #ResumenRegistrosActualizados.IdPedimentoComprobante
        WHERE #Data.ConDetalle = 0;

        -- 10. Limpiar prefijo sobrante
        UPDATE #Data
        SET Observaciones = CASE
                                WHEN LEFT(Observaciones, 3) = N' | '
                                THEN STUFF(Observaciones, 1, 3, N'')
                                ELSE Observaciones
                            END
        WHERE Observaciones LIKE N' |%';

        -- 11. Preparar detalle de cambios para bitácora
        --     Incluye datos enviados por el cliente (lo que llegó del Excel)
        --     y el resultado del proceso para cada registro — útil para verificaciones y aclaraciones
        INSERT INTO #BitacoraCambios
        (
            TipoDocumento,
            IdPedimentoComprobante,
            Detalle
        )
        SELECT
            ISNULL(d.TipoDocumento, 0),
            d.IdPedimentoComprobante,
            -- Datos tal como llegaron del Excel (Raw preserva el valor original aunque no sea numérico)
            N'[Enviado] Fila='        + CAST(d.FilaExcel AS NVARCHAR(10))
            + N' IdPedimento='        + ISNULL(d.IdPedimentoComprobanteRaw, N'NULL')
            + N' CodigoSE='           + ISNULL(d.CodigoSE, N'')
            -- Resultado del proceso
            + N' | [Resultado] '
            + CASE
                WHEN d.ConDetalle = 0
                THEN N'Actualizado correctamente. Registros=' + ISNULL(r.Registros, N'N/A')
                ELSE N'Error: ' + ISNULL(CAST(d.Observaciones AS NVARCHAR(MAX)), N'')
              END
        FROM #Data d
        LEFT JOIN #ResumenRegistrosActualizados r
            ON d.IdPedimentoComprobante = r.IdPedimentoComprobante
        WHERE d.IdPedimentoComprobanteRaw IS NOT NULL
          AND d.IdPedimentoComprobanteRaw <> N'';

       -- 12. Bitácora — un registro por tipo de documento presente en el lote
        INSERT INTO AP_Bitacora
        (
            Fecha,
            Tipo,
            Mensaje,
            Detalle,
            UsuarioId,
            ContratoId
        )
        SELECT
            GETDATE(),
            CASE ISNULL(d.TipoDocumento, 0)
                WHEN 2 THEN 'Importacion PI'
                WHEN 3 THEN 'Importacion PE'
                ELSE 'Importacion PE/PI'
            END,
            CASE
                WHEN LEN(ISNULL(@MotivoCambio, N'')) > 0
                    THEN N'Motivo: ' + @MotivoCambio
                ELSE N''
            END,
            N'IdProceso: ' + LEFT(CAST(@IdProceso AS NVARCHAR(36)), 8) + N' | '
            + N'Contrato=' + CAST(MAX(d.IdContrato) AS NVARCHAR(20)) + N' | '
            + CAST(COUNT(*) AS NVARCHAR(20)) + N' registros procesados, '
            + CAST(SUM(CASE WHEN d.ConDetalle = 0 THEN 1 ELSE 0 END) AS NVARCHAR(20)) + N' actualizados correctamente, '
            + CAST(SUM(CASE WHEN d.ConDetalle = 1 THEN 1 ELSE 0 END) AS NVARCHAR(20)) + N' con error. '
            + N'Detalle: '
            + ISNULL
              (
                  STUFF
                  (
                      (
                          SELECT N' || ' + bc.Detalle
                          FROM #BitacoraCambios bc
                          WHERE bc.TipoDocumento = ISNULL(d.TipoDocumento, 0)
                          FOR XML PATH(''), TYPE
                      ).value('.', 'NVARCHAR(MAX)'),
                      1,
                      4,
                      N''
                  ),
                  N'Sin cambios.'
              ),
            @IdUsuario,
            @IdContrato
        FROM #Data d
        WHERE d.IdPedimentoComprobanteRaw IS NOT NULL
          AND d.IdPedimentoComprobanteRaw <> N''
        GROUP BY ISNULL(d.TipoDocumento, 0);

        COMMIT TRAN;

        -- 13. Resultado final para el grid
        --     IdPedimentoComprobante usa Raw como fallback para mostrar el valor original
        --     cuando el cliente mandó un valor no numérico (IdPedimentoComprobante = NULL)
        SELECT
            FilaExcel,
            ISNULL(CAST(IdPedimentoComprobante AS NVARCHAR(20)), IdPedimentoComprobanteRaw) AS IdPedimentoComprobante,
            CodigoSE,
            IdContrato,
            Observaciones
        FROM #Data;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO
