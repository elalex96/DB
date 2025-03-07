IF OBJECT_ID('[dbo].[USP_UPD_SEPCNGastos]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].USP_UPD_SEPCNGastos;
GO

CREATE PROCEDURE [dbo].USP_UPD_SEPCNGastos
(
    @IdUsuario INT,
    @IdContrato INT,
    @Data Type_UPD_SEPCNGastos READONLY
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Fecha DATETIME = GETDATE(); -- Fecha actual para las actualizaciones

    -- Crear tabla temporal para almacenar los datos de entrada
    CREATE TABLE #Data
    (
        FilaExcel INT,
        UUID VARCHAR(500),
        IdFactura INT,
        CodigoSE NVARCHAR(100),
        IdActividad INT,
        PCN VARCHAR(200),
        ValorPCN FLOAT,
        IdContrato INT,
        Observaciones VARCHAR(MAX),
        ConDetalle BIT,
        ConDetalleUUID BIT,
        ConDetalleCodigo BIT,
        ConDetallePCN BIT
    );

    -- Crear otra tabla temporal para los registros de gastos
    CREATE TABLE #DataGasto
    (
        IdFactura INT,
        IdRegistro INT,
        IdCBSISH INT,
        PCN FLOAT,
        IdUsuarioModPor FLOAT,
        ModificadoEn DATETIME
    );

    -- Insertar los datos de entrada en la tabla temporal #Data
    INSERT INTO #Data
    (
        FilaExcel,
        UUID,
        CodigoSE,
        PCN,
        IdContrato,
        Observaciones,
        ConDetalle,
        ConDetalleUUID,
        ConDetalleCodigo,
        ConDetallePCN
    )
    SELECT FilaExcel,
           ISNULL(LTRIM(RTRIM(UUID)), ''),
           ISNULL(LTRIM(RTRIM(CodigoSE)), ''),
           ISNULL(LTRIM(RTRIM(PCN)), ''),
           IdContrato,
           ISNULL(Observaciones, ''),
           CASE
               WHEN LEN(LTRIM(RTRIM(ISNULL(Observaciones, '')))) > 0 THEN
                   1
               ELSE
                   0
           END,
           CASE
               WHEN LEN(LTRIM(RTRIM(ISNULL(UUID, '')))) > 0 THEN
                   0
               ELSE
                   1
           END,
           CASE
               WHEN LEN(LTRIM(RTRIM(ISNULL(CodigoSE, '')))) > 0 THEN
                   0
               ELSE
                   1
           END,
           CASE
               WHEN LEN(LTRIM(RTRIM(ISNULL(PCN, '')))) > 0 THEN
                   0
               ELSE
                   1
           END
    FROM @Data;

    -- Agregar un prefijo ' | ' a las observaciones si se tienen detalles
    UPDATE #Data
    SET Observaciones = ' | ' + Observaciones
    WHERE #Data.ConDetalle = 1;

    -- Actualizar las facturas en #Data
    UPDATE #Data
    SET #Data.IdFactura = FI_Factura.IdFactura
    FROM #Data
        JOIN FI_Factura (NOLOCK)
            ON #Data.ConDetalleUUID = 0
               AND #Data.UUID = ISNULL(LTRIM(RTRIM(FI_Factura.UUID)), '')
               AND #Data.IdContrato = FI_Factura.IdContrato;

    UPDATE #Data
    SET Observaciones = Observaciones + ' | La factura no se encuentra registrada en el sistema o en el contrato.',
        ConDetalle = 1
    WHERE #Data.ConDetalleUUID = 0
          AND #Data.IdFactura IS NULL;

    UPDATE #Data
    SET #Data.IdActividad = MM_BS_Actividad.IdActividad,
        #Data.Observaciones = CASE
                                  WHEN ISNULL(MM_BS_Actividad.Activo, 0) = 0 THEN
                                      Observaciones + ' | El Código SE no se encuentra como activo.'
                                  ELSE
                                      Observaciones
                              END,
        #Data.ConDetalle = CASE
                               WHEN ISNULL(MM_BS_Actividad.Activo, 0) = 0 THEN
                                   1
                               ELSE
                                   #Data.ConDetalle
                           END
    FROM #Data
        JOIN MM_BS_Actividad (NOLOCK)
            ON #Data.ConDetalleCodigo = 0
               AND #Data.CodigoSE = ISNULL(LTRIM(RTRIM(MM_BS_Actividad.Codigo)), '');

    UPDATE #Data
    SET Observaciones = Observaciones + ' | El Código SE no se encuentra registrado.',
        ConDetalle = 1
    WHERE #Data.ConDetalleCodigo = 0
          AND #Data.IdActividad IS NULL;

    UPDATE #Data
    SET ValorPCN = TRY_CAST(PCN AS FLOAT)
    WHERE TRY_CAST(PCN AS FLOAT) IS NOT NULL
          AND #Data.ConDetallePCN = 0;

    UPDATE #Data
    SET Observaciones = Observaciones + ' | El PCN no es un valor flotante.',
        ConDetalle = 1
    WHERE TRY_CAST(PCN AS FLOAT) IS NULL
          AND #Data.ConDetallePCN = 0
          AND ValorPCN IS NULL;

    UPDATE #Data
    SET Observaciones = CASE
                            WHEN ValorPCN > 1 THEN
                                Observaciones + ' | El PCN es un valor mayor a 1.'
                            WHEN ValorPCN < 0 THEN
                                Observaciones + ' | El PCN es un valor menor a 0.'
                            ELSE
                                Observaciones
                        END,
        ConDetalle = CASE
                         WHEN ValorPCN > 1 THEN
                             1
                         WHEN ValorPCN < 0 THEN
                             1
                         ELSE
                             ConDetalle
                     END;

    -- Insertar los registros de gasto en la tabla temporal #DataGasto
    INSERT INTO #DataGasto
    (
        IdFactura,
        IdRegistro,
        IdCBSISH,
        PCN,
        IdUsuarioModPor,
        ModificadoEn
    )
    SELECT #Data.IdFactura,
           CO_Registro.IdRegistro,
           #Data.IdActividad,
           #Data.ValorPCN,
           @IdUsuario,
           @Fecha
    FROM #Data
        JOIN CO_Registro (NOLOCK)
            ON ConDetalle = 0
               AND #Data.IdFactura = CO_Registro.IdFactura
    GROUP BY #Data.IdFactura,
             CO_Registro.IdRegistro,
             #Data.IdActividad,
             #Data.ValorPCN;

    -- Actualizar los registros de CO_Registro con los datos de #DataGasto
    UPDATE CO_Registro
    SET IdCBSISH = #DataGasto.IdCBSISH,
        PCN = #DataGasto.PCN,
        IdUsuarioModPor = #DataGasto.IdUsuarioModPor,
        ModificadoEn = #DataGasto.ModificadoEn
    FROM #DataGasto
        JOIN CO_Registro (NOLOCK)
            ON #DataGasto.IdRegistro = CO_Registro.IdRegistro;

    UPDATE #Data
    SET #Data.Observaciones = CASE
                                  WHEN #DataGasto.IdFactura IS NULL THEN
                                      #Data.Observaciones + ' | La factura no cuenta con registros de gastos.'
                                  ELSE
                                      #Data.Observaciones
                              END,
        #Data.ConDetalle = CASE
                               WHEN #DataGasto.IdFactura IS NULL THEN
                                   1
                               ELSE
                                   #Data.ConDetalle
                           END
    FROM #Data
        LEFT JOIN #DataGasto
            ON #Data.IdFactura = #DataGasto.IdFactura
    WHERE ConDetalle = 0
          AND #DataGasto.IdFactura IS NULL

    -- Actualizar las observaciones en #Data con los registros actualizados
    UPDATE d
    SET Observaciones = CAST(Observaciones AS NVARCHAR(MAX)) + N' | Se actualizaron los registros con identificador: ' + registros
                        + N' relacionados con esta Factura.'
    FROM #Data d
        JOIN
        (
            SELECT dg.IdFactura,
                   STUFF(
                            (
                                SELECT ', ' + CAST(dg2.IdRegistro AS NVARCHAR)
                                FROM #DataGasto dg2
                                WHERE dg2.IdFactura = dg.IdFactura
                                FOR XML PATH(''), TYPE
                            ).value('.', 'NVARCHAR(MAX)'),
                            1,
                            2,
                            ''
                        ) AS registros
            FROM #DataGasto dg
            GROUP BY dg.IdFactura
        ) AS sub
            ON d.IdFactura = sub.IdFactura
    WHERE d.ConDetalle = 0;

    -- Eliminar el prefijo ' | ' en las observaciones si existe
    UPDATE #Data
    SET Observaciones = CASE
                            WHEN LEFT(Observaciones, 2) = ' | ' THEN
                                STUFF(Observaciones, 1, 2, '')
                            ELSE
                                Observaciones
                        END
    WHERE Observaciones LIKE ' |%';

    -- Seleccionar los resultados finales
    SELECT FilaExcel,
           UUID,
           CodigoSE,
           PCN,
           IdContrato,
           Observaciones
    FROM #Data;
END