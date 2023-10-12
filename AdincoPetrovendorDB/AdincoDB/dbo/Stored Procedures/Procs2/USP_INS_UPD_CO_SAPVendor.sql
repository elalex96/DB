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

        CREATE TABLE #TablaTemporalOrden
        (
            [NumeroFila] INT NULL,
            [NumeroPrioridad] INT NULL
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
            RTRIM(LTRIM(ISNULL([NumeroFila], ''))),
            RTRIM(LTRIM(ISNULL([VendorIDSAP], ''))),
            RTRIM(LTRIM(ISNULL([VendorName], ''))),
            RTRIM(LTRIM(ISNULL([TaxID], ''))),
            RTRIM(LTRIM(ISNULL([Country], ''))),
            RTRIM(LTRIM(ISNULL([Address], ''))),
            RTRIM(LTRIM(ISNULL([ContactName], ''))),
            RTRIM(LTRIM(ISNULL([ContactEmail], ''))),
            RTRIM(LTRIM(ISNULL([CompanyCode], ''))),
            RTRIM(LTRIM(ISNULL([VendorAccountGroup], ''))),
            RTRIM(LTRIM(ISNULL([KeyLastImport], ''))),
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
               TaxID,
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
            TaxID = #TablaTemporalSAPVendor.TaxID,
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

        SELECT '';

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        SELECT @ErrorMessage = ERROR_MESSAGE()

        ROLLBACK TRAN

        RAISERROR(@ErrorMessage, 17, 1)
    END CATCH;
END