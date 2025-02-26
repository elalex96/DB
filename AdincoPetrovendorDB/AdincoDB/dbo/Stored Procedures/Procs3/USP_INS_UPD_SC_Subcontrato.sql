IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_INS_UPD_SC_Subcontrato'
)
    DROP PROCEDURE USP_INS_UPD_SC_Subcontrato;
GO

CREATE PROCEDURE USP_INS_UPD_SC_Subcontrato
    @Table_SC_Type_Subcontratos SC_Type_Subcontratos READONLY,
    @UsuarioId INT,
    @ContratoId INT,
    @ContratistaId INT,
    @NombreArchivo VARCHAR(100)
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;

        SET NOCOUNT ON;

        DECLARE @ErrorMessage VARCHAR(8000),
                @FechaHoy DATETIME = GETDATE(),
                @IdProveedor INT,
                @IdSubcontrato INT = 0,
                @CuentaSubcontratos INT = 1,
                @NumeroSubcontratos INT = 0,
                @IdSCMaterial INT = 0,
                @idBitacora INT = 0;

        CREATE TABLE #TablaTemporalSubcontratos
        (
            NumeroFila INT NULL,
            DocumentoCompras VARCHAR(100) NULL,
            Posicion VARCHAR(100) NULL,
            CentroDeBeneficio VARCHAR(500) NULL,
            FechaDocumento DATE NULL,
            ProveedorCentroSuministrador VARCHAR(100) NULL,
            Material VARCHAR(100) NULL,
            TextoBreve VARCHAR(1000) NULL,
            DescripcionLarga VARCHAR(8000) NULL,
            CantidadDePedido DECIMAL(18, 5) NULL,
            UnidadMedidaPedido VARCHAR(100) NULL,
            PrecioNeto DECIMAL(18, 2) NULL,
            Moneda VARCHAR(100) NULL,
            PrefijoOT VARCHAR(500) NULL,
            SubContratista VARCHAR(100) NULL,
            IdSubContratista INT NULL,
            IdCentroCosto INT NULL,
            MaterialConcepto VARCHAR(200) NULL,
            IdUnidad INT NULL,
            IdMoneda INT NULL
        );

        CREATE TABLE #TablaTemporalSubcontratos_Agrupado
        (
            PrefijoOT VARCHAR(500) NULL,
            FechaDocumento DATE NULL,
            IdSubcontrato INT NULL,
            IdRow INT NULL
        );

        CREATE TABLE #TablaTemporalSubcontratos_Materiales_Agrupado
        (
            PrefijoOT VARCHAR(500) NULL,
            MaterialConcepto VARCHAR(200) NULL,
            IdSubcontrato INT NULL,
            NumeroFila INT NULL,
            IdSCMaterial INT NULL,
            FechaDocumento DATE NULL,
            IdRow INT NULL,
            IdRowRelacionado INT NULL
        )

        CREATE TABLE #Temporal_CC_CentroCosto
        (
            IdCentroCosto INT NULL,
            CentroCosto NVARCHAR(300) NULL,
            IdProveedor INT NULL
        )

        CREATE TABLE #Temporal_PV_Subcontratista
        (
            IdSubcontratista INT NULL,
            RazonSocial VARCHAR(8000) NULL
        )

        CREATE TABLE #Temporal_PV_MM_MaterialUnidad
        (
            IdUnidad INT NULL,
            Unidad VARCHAR(8000) NULL
        )

        CREATE TABLE #Temporal_PV_TipoMoneda
        (
            IdMoneda INT NULL,
            TipoMonedaCorto VARCHAR(100) NULL
        )

        INSERT INTO #TablaTemporalSubcontratos
        (
            NumeroFila,
            DocumentoCompras,
            Posicion,
            CentroDeBeneficio,
            FechaDocumento,
            ProveedorCentroSuministrador,
            Material,
            TextoBreve,
            DescripcionLarga,
            CantidadDePedido,
            UnidadMedidaPedido,
            PrecioNeto,
            Moneda,
            PrefijoOT,
            SubContratista,
            MaterialConcepto
        )
        SELECT NumeroFila,
               DocumentoCompras,
               Posicion,
               CentroDeBeneficio,
               FechaDocumento,
               ProveedorCentroSuministrador,
               Material,
               TextoBreve,
               DescripcionLarga,
               CantidadDePedido,
               UnidadMedidaPedido,
               PrecioNeto,
               Moneda,
               'CSD-' + DocumentoCompras,
               CASE
                   WHEN TRY_CAST(LEFT(ProveedorCentroSuministrador, CHARINDEX(' ', ProveedorCentroSuministrador + ' ')
                                                                    - 1)AS INT) IS NOT NULL THEN
                       SUBSTRING(
                                    ProveedorCentroSuministrador,
                                    CHARINDEX(' ', ProveedorCentroSuministrador) + 1,
                                    LEN(ProveedorCentroSuministrador)
                                )
                   ELSE
                       ProveedorCentroSuministrador
               END,
               Material + '-' + Posicion
        FROM @Table_SC_Type_Subcontratos;

        INSERT INTO #Temporal_CC_CentroCosto
        (
            IdCentroCosto,
            CentroCosto,
            IdProveedor
        )
        SELECT CC.IdCentroCosto,
               CC.CentroCosto,
               CC.IdProveedor
        FROM Petrovendor..CC_CentroCosto CC (NOLOCK)
            INNER JOIN Adinco..CO_Contrato C (NOLOCK)
                ON C.IdContrato = @ContratoId
            INNER JOIN Adinco..CO_Contratista CONT (NOLOCK)
                ON C.IdContratista = CONT.IdContratista
            INNER JOIN Petrovendor..s_proveedor PROV (NOLOCK)
                ON CONT.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = PROV.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
                   AND CC.IdProveedor = PROV.IdProveedor
        WHERE CC.IsActivo = 1
        GROUP BY CC.IdCentroCosto,
                 CC.CentroCosto,
                 CC.IdProveedor
        ORDER BY CC.CentroCosto

        UPDATE #TablaTemporalSubcontratos
        SET #TablaTemporalSubcontratos.IdCentroCosto = #Temporal_CC_CentroCosto.IdCentroCosto
        FROM #TablaTemporalSubcontratos
            INNER JOIN #Temporal_CC_CentroCosto
                ON UPPER(LTRIM(RTRIM(#TablaTemporalSubcontratos.CentroDeBeneficio))) = UPPER(LTRIM(RTRIM(#Temporal_CC_CentroCosto.CentroCosto)))

        SELECT TOP 1
            @IdProveedor = IdProveedor
        FROM #Temporal_CC_CentroCosto

        INSERT INTO Petrovendor..CC_CentroCosto
        (
            CentroCosto,
            IdProveedor,
            CreadoEl,
            IsActivo
        )
        SELECT LTRIM(RTRIM(#TablaTemporalSubcontratos.CentroDeBeneficio)),
               @IdProveedor,
               @FechaHoy,
               1
        FROM #TablaTemporalSubcontratos
        WHERE IdCentroCosto IS NULL
        GROUP BY #TablaTemporalSubcontratos.CentroDeBeneficio

        DELETE FROM #Temporal_CC_CentroCosto

        INSERT INTO #Temporal_CC_CentroCosto
        (
            IdCentroCosto,
            CentroCosto,
            IdProveedor
        )
        SELECT CC.IdCentroCosto,
               CC.CentroCosto,
               CC.IdProveedor
        FROM Petrovendor..CC_CentroCosto CC (NOLOCK)
            INNER JOIN Adinco..CO_Contrato C (NOLOCK)
                ON C.IdContrato = @ContratoId
            INNER JOIN Adinco..CO_Contratista CONT (NOLOCK)
                ON C.IdContratista = CONT.IdContratista
            INNER JOIN Petrovendor..s_proveedor PROV (NOLOCK)
                ON CONT.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = PROV.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
                   AND CC.IdProveedor = PROV.IdProveedor
        WHERE CC.IsActivo = 1
        GROUP BY CC.IdCentroCosto,
                 CC.CentroCosto,
                 CC.IdProveedor
        ORDER BY CC.CentroCosto

        UPDATE #TablaTemporalSubcontratos
        SET #TablaTemporalSubcontratos.IdCentroCosto = #Temporal_CC_CentroCosto.IdCentroCosto
        FROM #TablaTemporalSubcontratos
            INNER JOIN #Temporal_CC_CentroCosto
                ON UPPER(LTRIM(RTRIM(#TablaTemporalSubcontratos.CentroDeBeneficio))) = UPPER(LTRIM(RTRIM(#Temporal_CC_CentroCosto.CentroCosto)))

        INSERT INTO PV_Subcontratista
        (
            RazonSocial,
            IsActivo,
            IsEliminado,
            IdStatusValidacion
        )
        SELECT LTRIM(RTRIM(#TablaTemporalSubcontratos.SubContratista)),
               1,
               0,
               0
        FROM #TablaTemporalSubcontratos
            LEFT JOIN PV_Subcontratista
                ON UPPER(LTRIM(RTRIM(#TablaTemporalSubcontratos.SubContratista))) = UPPER(LTRIM(RTRIM(PV_Subcontratista.RazonSocial)))
        WHERE PV_Subcontratista.IdSubcontratista IS NULL

        INSERT INTO #Temporal_PV_Subcontratista
        (
            IdSubcontratista,
            RazonSocial
        )
        SELECT IdSubcontratista,
               RazonSocial
        FROM PV_Subcontratista (NOLOCK)
        WHERE IsActivo = 1

        UPDATE #TablaTemporalSubcontratos
        SET #TablaTemporalSubcontratos.IdSubContratista = #Temporal_PV_Subcontratista.IdSubcontratista
        FROM #TablaTemporalSubcontratos
            INNER JOIN #Temporal_PV_Subcontratista
                ON UPPER(LTRIM(RTRIM(#TablaTemporalSubcontratos.SubContratista))) = UPPER(LTRIM(RTRIM(#Temporal_PV_Subcontratista.RazonSocial)))

        INSERT INTO Petrovendor.dbo.PV_MM_MaterialUnidad
        (
            Unidad,
            IsActivo,
            IsEliminado,            
            CreadoEn
        )
        SELECT LTRIM(RTRIM(#TablaTemporalSubcontratos.UnidadMedidaPedido)),
               1,
               0,
               @FechaHoy
        FROM #TablaTemporalSubcontratos
            LEFT JOIN Petrovendor.dbo.PV_MM_MaterialUnidad 
                ON UPPER(LTRIM(RTRIM(#TablaTemporalSubcontratos.UnidadMedidaPedido))) COLLATE SQL_Latin1_General_CP1_CI_AS = UPPER(LTRIM(RTRIM(Petrovendor.dbo.PV_MM_MaterialUnidad.Unidad))) COLLATE SQL_Latin1_General_CP1_CI_AS
        WHERE Petrovendor.dbo.PV_MM_MaterialUnidad .IdUnidad IS NULL

        INSERT INTO #Temporal_PV_MM_MaterialUnidad
        (
            IdUnidad,
            Unidad
        )
        SELECT IdUnidad,
               Unidad
        FROM Petrovendor.dbo.PV_MM_MaterialUnidad  WITH (NOLOCK)
        WHERE IsActivo = 1

        UPDATE #TablaTemporalSubcontratos
        SET #TablaTemporalSubcontratos.IdUnidad = #Temporal_PV_MM_MaterialUnidad.IdUnidad
        FROM #TablaTemporalSubcontratos
            INNER JOIN #Temporal_PV_MM_MaterialUnidad
                ON UPPER(LTRIM(RTRIM(#TablaTemporalSubcontratos.UnidadMedidaPedido))) = UPPER(LTRIM(RTRIM(#Temporal_PV_MM_MaterialUnidad.Unidad)))

        INSERT INTO PV_TipoMoneda
        (
            TipoMoneda,
            TipoMonedaCorto,
            Eliminado
        )
        SELECT LTRIM(RTRIM(#TablaTemporalSubcontratos.Moneda)),
               LTRIM(RTRIM(#TablaTemporalSubcontratos.Moneda)),
               0
        FROM #TablaTemporalSubcontratos
            LEFT JOIN PV_TipoMoneda
                ON UPPER(LTRIM(RTRIM(#TablaTemporalSubcontratos.Moneda))) = UPPER(LTRIM(RTRIM(PV_TipoMoneda.TipoMonedaCorto)))
        WHERE PV_TipoMoneda.IdMoneda IS NULL

        INSERT INTO #Temporal_PV_TipoMoneda
        (
            IdMoneda,
            TipoMonedaCorto
        )
        SELECT tm.IdMoneda,
               tm.TipoMonedaCorto
        FROM PV_TipoMoneda tm WITH (NOLOCK);

        UPDATE #TablaTemporalSubcontratos
        SET #TablaTemporalSubcontratos.IdMoneda = #Temporal_PV_TipoMoneda.IdMoneda
        FROM #TablaTemporalSubcontratos
            INNER JOIN #Temporal_PV_TipoMoneda
                ON UPPER(LTRIM(RTRIM(#TablaTemporalSubcontratos.Moneda))) = UPPER(LTRIM(RTRIM(#Temporal_PV_TipoMoneda.TipoMonedaCorto)))

        INSERT INTO #TablaTemporalSubcontratos_Agrupado
        (
            PrefijoOT,
            FechaDocumento,
            IdRow
        )
        SELECT PrefijoOT,
               FechaDocumento,
               ROW_NUMBER() OVER (ORDER BY PrefijoOT, FechaDocumento) AS IdRow
        FROM #TablaTemporalSubcontratos
        GROUP BY PrefijoOT,
                 FechaDocumento

        INSERT INTO #TablaTemporalSubcontratos_Materiales_Agrupado
        (
            PrefijoOT,
            MaterialConcepto,
            NumeroFila,
            FechaDocumento,
            IdRow
        )
        SELECT PrefijoOT,
               MaterialConcepto,
               NumeroFila,
               FechaDocumento,
               ROW_NUMBER() OVER (ORDER BY PrefijoOT, MaterialConcepto, FechaDocumento, NumeroFila) AS IdRow
        FROM #TablaTemporalSubcontratos
        GROUP BY PrefijoOT,
                 MaterialConcepto,
                 NumeroFila,
                 FechaDocumento

        UPDATE #TablaTemporalSubcontratos_Agrupado
        SET #TablaTemporalSubcontratos_Agrupado.IdSubcontrato = SC_Subcontrato.IdSubContrato
        FROM #TablaTemporalSubcontratos_Agrupado
            INNER JOIN SC_Subcontrato WITH (NOLOCK)
                ON #TablaTemporalSubcontratos_Agrupado.PrefijoOT = SC_Subcontrato.PrefijoOTDocumento
                   AND #TablaTemporalSubcontratos_Agrupado.FechaDocumento = SC_Subcontrato.FechaDocumento 
				   AND SC_Subcontrato.IsEliminado = 0

        UPDATE #TablaTemporalSubcontratos_Materiales_Agrupado
        SET #TablaTemporalSubcontratos_Materiales_Agrupado.IdSubcontrato = #TablaTemporalSubcontratos_Agrupado.IdSubcontrato,
            #TablaTemporalSubcontratos_Materiales_Agrupado.IdRowRelacionado = #TablaTemporalSubcontratos_Agrupado.IdRow
        FROM #TablaTemporalSubcontratos_Materiales_Agrupado
            INNER JOIN #TablaTemporalSubcontratos_Agrupado
                ON #TablaTemporalSubcontratos_Materiales_Agrupado.PrefijoOT = #TablaTemporalSubcontratos_Agrupado.PrefijoOT
                   AND #TablaTemporalSubcontratos_Materiales_Agrupado.FechaDocumento = #TablaTemporalSubcontratos_Agrupado.FechaDocumento

        UPDATE #TablaTemporalSubcontratos_Materiales_Agrupado
        SET #TablaTemporalSubcontratos_Materiales_Agrupado.IdSCMaterial = SC_Materiales.IdSCMaterial
        FROM #TablaTemporalSubcontratos_Materiales_Agrupado
            INNER JOIN SC_Materiales (NOLOCK)
                ON #TablaTemporalSubcontratos_Materiales_Agrupado.IdSubcontrato = SC_Materiales.IdSubContrato
                   AND #TablaTemporalSubcontratos_Materiales_Agrupado.MaterialConcepto = SC_Materiales.MaterialConceptoDocumento

        SELECT @NumeroSubcontratos = COUNT(*)
        FROM #TablaTemporalSubcontratos_Agrupado

        WHILE @CuentaSubcontratos <= @NumeroSubcontratos
        BEGIN
            -- Comprobamos si existe un Subcontrato para la fila actual
            IF EXISTS
            (
                SELECT 1
                FROM #TablaTemporalSubcontratos_Agrupado
                WHERE IdRow = @CuentaSubcontratos
                      AND IdSubcontrato IS NOT NULL
            )
            BEGIN
                -- Si existe, obtenemos el IdSubcontrato
                SELECT @IdSubcontrato = IdSubcontrato
                FROM #TablaTemporalSubcontratos_Agrupado
                WHERE IdRow = @CuentaSubcontratos;
            END
            ELSE
            BEGIN
                SELECT @IdSubcontrato = ISNULL(MAX(IdSubContrato), 0) + 1
                FROM SC_Subcontrato WITH (TABLOCKX)

                INSERT INTO SC_Subcontrato
                (
                    IdSubContrato,
                    IdSubContratista,
                    IdContratista,
                    NumeroSubContrato,
                    CreadoPor,
                    CreadoEl,
                    IsActivo,
                    IsEliminado,
                    Objeto,
                    PrefijoOT,
                    IdMoneda,
                    FechaInicio,
                    FechaFin,
                    FechaDocumento,
                    PrefijoOTDocumento,
                    IdCentroCosto
                )
                SELECT TOP 1
                    @IdSubcontrato,
                    #TablaTemporalSubcontratos.IdSubContratista,
                    @ContratistaId,
                    #TablaTemporalSubcontratos.DocumentoCompras,
                    @UsuarioId,
                    @FechaHoy,
                    1,
                    0,
                    CAST(#TablaTemporalSubcontratos.TextoBreve AS VARCHAR(300)),
                    CAST(#TablaTemporalSubcontratos.PrefijoOT AS VARCHAR(13)),
                    #TablaTemporalSubcontratos.IdMoneda,
                    CAST(#TablaTemporalSubcontratos.FechaDocumento AS DATETIME),
                    CAST(#TablaTemporalSubcontratos.FechaDocumento AS DATETIME),
                    #TablaTemporalSubcontratos.FechaDocumento,
                    #TablaTemporalSubcontratos.PrefijoOT,
                    #TablaTemporalSubcontratos.IdCentroCosto
                FROM #TablaTemporalSubcontratos_Agrupado
                    INNER JOIN #TablaTemporalSubcontratos
                        ON #TablaTemporalSubcontratos_Agrupado.IdRow = @CuentaSubcontratos
                           AND #TablaTemporalSubcontratos_Agrupado.PrefijoOT = #TablaTemporalSubcontratos.PrefijoOT
                           AND #TablaTemporalSubcontratos_Agrupado.FechaDocumento = #TablaTemporalSubcontratos.FechaDocumento;
         END

            SELECT @IdSCMaterial = ISNULL(MAX(IdSCMaterial), 0)
            FROM SC_Materiales WITH (TABLOCKX);

            INSERT INTO SC_Materiales
            (
                IdSCMaterial,
                Concepto,
                IdUnidad,
                Cantidad,
                PrecioUnitario,
                Importe,
                Descripcion,
                DescripcionCorta,
                IdSubContrato,
                IdMaestro,
                CreadoPor,
                CreadoEl,
                FechaDocumento,
                PrefijoOTDocumento,
                MaterialConceptoDocumento
            )
            SELECT @IdSCMaterial + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),
                   #TablaTemporalSubcontratos.MaterialConcepto,
                   #TablaTemporalSubcontratos.IdUnidad,
                   #TablaTemporalSubcontratos.CantidadDePedido,
                   #TablaTemporalSubcontratos.PrecioNeto,
                   #TablaTemporalSubcontratos.CantidadDePedido * #TablaTemporalSubcontratos.PrecioNeto,
                   #TablaTemporalSubcontratos.DescripcionLarga,
                   #TablaTemporalSubcontratos.TextoBreve,
                   @IdSubcontrato,
                   NULL,
                   @UsuarioId,
                   @FechaHoy,
                   #TablaTemporalSubcontratos.FechaDocumento,
                   #TablaTemporalSubcontratos.PrefijoOT,
                   #TablaTemporalSubcontratos.MaterialConcepto
            FROM #TablaTemporalSubcontratos_Materiales_Agrupado
                INNER JOIN #TablaTemporalSubcontratos
                    ON #TablaTemporalSubcontratos_Materiales_Agrupado.IdRowRelacionado = @CuentaSubcontratos
                       AND #TablaTemporalSubcontratos_Materiales_Agrupado.IdSCMaterial IS NULL
                       AND #TablaTemporalSubcontratos_Materiales_Agrupado.NumeroFila = #TablaTemporalSubcontratos.NumeroFila
            GROUP BY #TablaTemporalSubcontratos.MaterialConcepto,
                     #TablaTemporalSubcontratos.IdUnidad,
                     #TablaTemporalSubcontratos.CantidadDePedido,
                     #TablaTemporalSubcontratos.PrecioNeto,
                     #TablaTemporalSubcontratos.CantidadDePedido * #TablaTemporalSubcontratos.PrecioNeto,
                     #TablaTemporalSubcontratos.DescripcionLarga,
                     #TablaTemporalSubcontratos.TextoBreve,
                     #TablaTemporalSubcontratos.FechaDocumento,
                     #TablaTemporalSubcontratos.PrefijoOT,
                     #TablaTemporalSubcontratos.MaterialConcepto

            SELECT @idBitacora = ISNULL(MAX(IdSCBitacora), 0)
            FROM SC_MaterialesBitacora WITH (TABLOCKX);

            INSERT INTO SC_MaterialesBitacora
            (
                IdSCBitacora,
                IdSCMaterial,
                CantidadRespaldo,
                FechaRespaldo,
                ModificadoPor,
                Cantidad,
                PrecioUnitario
            )
            SELECT @idBitacora + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),
                   SC_Materiales.IdSCMaterial,
                   SC_Materiales.Cantidad,
                   @FechaHoy,
                   @UsuarioId,
                   SC_Materiales.Cantidad,
                   SC_Materiales.PrecioUnitario
            FROM #TablaTemporalSubcontratos_Materiales_Agrupado
                INNER JOIN SC_Materiales (NOLOCK)
                    ON #TablaTemporalSubcontratos_Materiales_Agrupado.IdRowRelacionado = @CuentaSubcontratos
                       AND #TablaTemporalSubcontratos_Materiales_Agrupado.PrefijoOT = SC_Materiales.PrefijoOTDocumento
                       AND #TablaTemporalSubcontratos_Materiales_Agrupado.FechaDocumento = SC_Materiales.FechaDocumento
                       AND #TablaTemporalSubcontratos_Materiales_Agrupado.MaterialConcepto = SC_Materiales.MaterialConceptoDocumento
                       AND SC_Materiales.IdSubContrato = @IdSubcontrato
                       AND SC_Materiales.CreadoEl = @FechaHoy
            GROUP BY SC_Materiales.IdSCMaterial,
                     SC_Materiales.Cantidad,
                     SC_Materiales.Cantidad,
                     SC_Materiales.PrecioUnitario

        EXEC [dbo].[p_SC_Materiales_Gen] @IdSubcontrato, '';

            SET @CuentaSubcontratos = @CuentaSubcontratos + 1;
        END

        SELECT '';

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        SELECT @ErrorMessage = ERROR_MESSAGE()

        ROLLBACK TRAN

        RAISERROR(@ErrorMessage, 17, 1)
    END CATCH;
END