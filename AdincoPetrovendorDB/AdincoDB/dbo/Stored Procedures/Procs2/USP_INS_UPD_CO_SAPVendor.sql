IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_INS_UPD_CO_SAPVendor'
)
    DROP PROCEDURE USP_INS_UPD_CO_SAPVendor;
GO

CREATE PROCEDURE USP_INS_UPD_CO_SAPVendor
    @Table_CO_Type_SAPVendor CO_Type_SAPVendor READONLY,
    @UsuarioId INT,
    @ContratoId INT,
    @IdImportBitacora INT,
    @NombreArchivo VARCHAR(100)
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;

        SET NOCOUNT ON;

        DECLARE @ErrorMessage VARCHAR(8000),
                @FechaHoy DATETIME = GETDATE(),
                @VendorIDSAPEnOtroContrato INT = 0,
                @IdBitacora INT = 0;

        CREATE TABLE #TablaTemporalSAPVendor
        (
            [NumeroFila] INT NULL,
            [VendorIDSAP] VARCHAR(20) NULL,
            [VendorName] VARCHAR(250) NULL,
            [TaxID] VARCHAR(14) NULL,
            [Country] VARCHAR(50) NULL,
            [Address] VARCHAR(300) NULL,
            [ContactName] VARCHAR(250) NULL,
            [ContactEmail] VARCHAR(100) NULL,
            [CompanyCode] VARCHAR(4) NULL,
            [VendorAccountGroup] VARCHAR(10) NULL,
            [KeyLastImport] VARCHAR(50) NULL,
            [EsActualizacion] BIT NULL,
            [EnOtroContrato] BIT NULL,
            [OtroContratoId] INT NULL,
            [UsuarioId] INT NULL,
            [ContratoId] INT NULL,
            [NumeroPrioridad] INT NULL
        );

        CREATE TABLE #TablaTemporalDetalles
        (
            [VendorIDSAP] VARCHAR(20) NULL,
            [OtroContratoId] INT NULL
        );

        CREATE TABLE #TablaTemporalOrden
        (
            [NumeroFila] INT NULL,
            [NumeroPrioridad] INT NULL
        );

        CREATE TABLE #TablaTemporalDetallesFiltrados
        (
            [VendorIDSAP] VARCHAR(8000) NULL,
            [OtroContratoId] INT NULL
        );

        INSERT INTO #TablaTemporalSAPVendor
        (
            [NumeroFila],
            [VendorIDSAP],
            [VendorName],
            [TaxID],
            [Country],
            [Address],
            [ContactName],
            [ContactEmail],
            [CompanyCode],
            [VendorAccountGroup],
            [KeyLastImport],
            [EsActualizacion],
            [EnOtroContrato],
            [UsuarioId],
            [ContratoId]
        )
        SELECT DISTINCT
            [NumeroFila],
            [VendorIDSAP],
            [VendorName],
            [TaxID],
            [Country],
            [Address],
            [ContactName],
            [ContactEmail],
            [CompanyCode],
            [VendorAccountGroup],
            [KeyLastImport],
            0,
            0,
            @UsuarioId,
            @ContratoId
        FROM @Table_CO_Type_SAPVendor;

        INSERT INTO #TablaTemporalOrden
        (
            [NumeroFila],
            [NumeroPrioridad]
        )
        SELECT DISTINCT
            #TablaTemporalSAPVendor.NumeroFila,
            ROW_NUMBER() OVER (PARTITION BY #TablaTemporalSAPVendor.VendorIDSAP
                               ORDER BY #TablaTemporalSAPVendor.NumeroFila DESC
                              ) NumeroPrioridad
        FROM #TablaTemporalSAPVendor

        UPDATE #TablaTemporalSAPVendor
        SET #TablaTemporalSAPVendor.NumeroPrioridad = #TablaTemporalOrden.NumeroPrioridad
        FROM #TablaTemporalSAPVendor
            JOIN #TablaTemporalOrden
                ON #TablaTemporalSAPVendor.NumeroFila = #TablaTemporalOrden.NumeroFila

        UPDATE #TablaTemporalSAPVendor
        SET #TablaTemporalSAPVendor.EsActualizacion = 1
        FROM #TablaTemporalSAPVendor
            JOIN CO_SAPVendor
                ON #TablaTemporalSAPVendor.VendorIDSAP = CO_SAPVendor.VendorIDSAP
                   AND #TablaTemporalSAPVendor.ContratoId = CO_SAPVendor.IdContrato

        UPDATE #TablaTemporalSAPVendor
        SET #TablaTemporalSAPVendor.EnOtroContrato = 1,
            #TablaTemporalSAPVendor.OtroContratoId = CO_SAPVendor.IdContrato
        FROM #TablaTemporalSAPVendor
            JOIN CO_SAPVendor
                ON #TablaTemporalSAPVendor.VendorIDSAP = CO_SAPVendor.VendorIDSAP
                   AND #TablaTemporalSAPVendor.ContratoId <> CO_SAPVendor.IdContrato

        /*Insercion de Vendors*/
        INSERT INTO CO_SAPVendor
        (
            VendorIDSAP,
            IdContrato,
            VendorName,
            TaxID,
            Country,
            Address,
            ContactName,
            ContactEmail,
            CreadoEl,
            CreadoPor,
            CompanyCode,
            VendorAccountGroup,
            Activo,
            KeyLastImport
        )
        SELECT VendorIDSAP,
               ContratoId,
               VendorName,
               CASE
                   WHEN RTRIM(LTRIM(ISNULL(#TablaTemporalSAPVendor.TaxID, ''))) = '' THEN
                       #TablaTemporalSAPVendor.TaxID
                   ELSE
                       RTRIM(LTRIM(ISNULL(#TablaTemporalSAPVendor.TaxID, '')))
               END,
               Country,
               Address,
               ContactName,
               ContactEmail,
               @FechaHoy,
               UsuarioId,
               CompanyCode,
               VendorAccountGroup,
               1,
               KeyLastImport
        FROM #TablaTemporalSAPVendor
        WHERE #TablaTemporalSAPVendor.NumeroPrioridad = 1
              AND ISNULL(EsActualizacion, 0) = 0
              AND ISNULL(#TablaTemporalSAPVendor.EnOtroContrato, 0) = 0;

        /*Actualizacion de Vendors*/
        UPDATE CO_SAPVendor
        SET VendorName = #TablaTemporalSAPVendor.VendorName,
            TaxID = CASE
                        WHEN RTRIM(LTRIM(ISNULL(#TablaTemporalSAPVendor.TaxID, ''))) = '' THEN
                            #TablaTemporalSAPVendor.TaxID
                        ELSE
                            RTRIM(LTRIM(ISNULL(#TablaTemporalSAPVendor.TaxID, '')))
                    END,
            Country = #TablaTemporalSAPVendor.Country,
            Address = #TablaTemporalSAPVendor.Address,
            ContactName = #TablaTemporalSAPVendor.ContactName,
            ContactEmail = #TablaTemporalSAPVendor.ContactEmail,
            CreadoPor = #TablaTemporalSAPVendor.UsuarioId,
            ModificadoEl = getdate(),
            CompanyCode = #TablaTemporalSAPVendor.CompanyCode,
            VendorAccountGroup = #TablaTemporalSAPVendor.VendorAccountGroup,
            Activo = 1,
            KeyLastImport = #TablaTemporalSAPVendor.KeyLastImport
        FROM CO_SAPVendor
            JOIN #TablaTemporalSAPVendor
                ON CO_SAPVendor.VendorIDSAP = #TablaTemporalSAPVendor.VendorIDSAP
                   AND CO_SAPVendor.IdContrato = #TablaTemporalSAPVendor.ContratoId
        WHERE #TablaTemporalSAPVendor.NumeroPrioridad = 1
              AND ISNULL(#TablaTemporalSAPVendor.EsActualizacion, 0) = 1
              AND ISNULL(#TablaTemporalSAPVendor.EnOtroContrato, 0) = 0;

        SELECT @VendorIDSAPEnOtroContrato = COUNT(1)
        FROM #TablaTemporalSAPVendor
        WHERE ISNULL(#TablaTemporalSAPVendor.EnOtroContrato, 0) = 1;

        IF (@VendorIDSAPEnOtroContrato > 0)
        BEGIN
            INSERT INTO #TablaTemporalDetalles
            (
                VendorIDSAP,
                OtroContratoId
            )
            SELECT VendorIDSAP,
                   OtroContratoId
            FROM #TablaTemporalSAPVendor
            WHERE ISNULL(#TablaTemporalSAPVendor.EnOtroContrato, 0) = 1
            GROUP BY VendorIDSAP,
                     OtroContratoId

            INSERT INTO #TablaTemporalDetallesFiltrados
            (
                VendorIDSAP,
                OtroContratoId
            )
            SELECT DISTINCT
                STUFF(
                (
                    SELECT DISTINCT
                        ', ',
                        CONVERT(VARCHAR(20), T.VendorIDSAP)
                    FROM #TablaTemporalDetalles T
                    WHERE #TablaTemporalDetalles.OtroContratoId = T.OtroContratoId
                    FOR XML PATH('')
                ),
                1,
                2,
                ''
                     ) AS VendorIDSAP,
                OtroContratoId
            FROM #TablaTemporalDetalles (NOLOCK)

            SELECT @IdBitacora = ISNULL(MAX(Id), 0) + 1
            FROM CO_SAP_ImportBitacora_Detalle

            SELECT @ErrorMessage = STUFF(
                                   (
                                       SELECT DISTINCT
                                           ', Se detectaron que los VendorIDSAP [',
                                           CONVERT(VARCHAR(8000), T.VendorIDSAP),
                                           '] se encuentran agregado en el contrato (',
                                           CONVERT(VARCHAR(20), T.OtroContratoId) + ')'
                                       FROM #TablaTemporalDetallesFiltrados T
                                       FOR XML PATH('')
                                   ),
                                   1,
                                   2,
                                   ''
                                        )

            INSERT INTO CO_SAP_ImportBitacora_Detalle
            (
                Id,
                IdImportBitacora,
                NombreArchivo,
                Error,
                TieneError,
                CreadoEl
            )
            SELECT @IdBitacora,
                   @IdImportBitacora,
                   @NombreArchivo,
                   @ErrorMessage,
                   1,
                   @FechaHoy;

            SELECT CONCAT(
                             'Se encontraron VendorIDSAP pertenecientes a otros contratos, para más detalle validar la tabla CO_SAP_ImportBitacora_Detalle con identificador: ',
                             CONVERT(VARCHAR(10), @IdBitacora)
                         );
        END
		ELSE
		BEGIN
			SELECT '';
		END

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        SELECT @ErrorMessage = ERROR_MESSAGE()

        ROLLBACK TRAN

        RAISERROR(@ErrorMessage, 17, 1)
    END CATCH;
END