IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_INS_UPD_CO_SAPPO'
)
    DROP PROCEDURE USP_INS_UPD_CO_SAPPO;
GO

CREATE PROCEDURE USP_INS_UPD_CO_SAPPO
    @Table_CO_Type_SAPPO CO_Type_SAPPO READONLY,
    @UsuarioId INT,
    @ContratoId INT = 10039,	
    @IdImportBitacora INT,
    @NombreArchivo VARCHAR(100),
    @IdContratista INT,
    @NumeroRegitros INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;

        SET NOCOUNT ON;
        DECLARE @ErrorMessage VARCHAR(8000),
                @FechaHoy DATETIME = GETDATE();

        CREATE TABLE #TablaTemporalSAPPO
        (
            [NumeroFila] INT NULL,
            [VersionNumber] TINYINT NULL,
            [SAPVendorNumber] VARCHAR(20) NULL,
            [ItemNumber] SMALLINT NULL,
            [SAPMaterialNumber] VARCHAR(50) NULL,
            [Quantity] FLOAT(53) NULL,
            [UnitPrice] FLOAT(53) NULL,
            [Currency] VARCHAR(50) NULL,
            [Total] FLOAT(53) NULL,
            [DeliveryAddress] VARCHAR(250) NULL,
            [SAPPONumber] VARCHAR(20) NULL,
            [DeliveryDate] VARCHAR(8) NULL,
            [Comments] VARCHAR(250) NULL,
            [CostObject] VARCHAR(20) NULL,
            [MaterialGroup] VARCHAR(50) NULL,
            [MaterialGroupDescription] VARCHAR(250) NULL,
            [ServiceLineNumber] VARCHAR(50) NULL,
            [Quantity2] FLOAT(53) NULL,
            [Price] FLOAT(53) NULL,
            [CostObject2] VARCHAR(20) NULL,
            [ServiceGroup] VARCHAR(50) NULL,
            [ShortText] VARCHAR(100) NULL,
            [ParentLineUOM] VARCHAR(50) NULL,
            [ServicesShortText] VARCHAR(50) NULL,
            [ServicesUOM] VARCHAR(50) NULL,
            [Plant] VARCHAR(15) NULL,
            [POItemCategory] TINYINT NULL,
            [EsActualizacion] BIT NULL,
            [UsuarioId] INT NULL,
            [ContratoId] INT NULL,
            [NumeroPrioridad] INT NULL
        );

        CREATE TABLE #TablaTemporalOrden
        (
            [NumeroFila] INT NULL,
            [NumeroPrioridad] INT NULL
        );

        INSERT INTO #TablaTemporalSAPPO
        (
            [NumeroFila],
            [VersionNumber],
            [SAPVendorNumber],
            [ItemNumber],
            [SAPMaterialNumber],
            [Quantity],
            [UnitPrice],
            [Currency],
            [Total],
            [DeliveryAddress],
            [SAPPONumber],
            [DeliveryDate],
            [Comments],
            [CostObject],
            [MaterialGroup],
            [MaterialGroupDescription],
            [ServiceLineNumber],
            [Quantity2],
            [Price],
            [CostObject2],
            [ServiceGroup],
            [ShortText],
            [ParentLineUOM],
            [ServicesShortText],
            [ServicesUOM],
            [Plant],
            [POItemCategory],
            [EsActualizacion],
            [UsuarioId],
            [ContratoId]
        )
        SELECT DISTINCT
            [NumeroFila],
            CAST([VersionNumber] AS TINYINT),
            RTRIM(LTRIM(ISNULL(CAST([SAPVendorNumber] AS VARCHAR(20)), ''))),
            CAST([ItemNumber] AS SMALLINT),
            RTRIM(LTRIM(ISNULL(CAST([SAPMaterialNumber] AS VARCHAR(50)), ''))),
            CAST([Quantity] AS FLOAT(53)),
            CAST([UnitPrice] AS FLOAT(53)),
            RTRIM(LTRIM(ISNULL(CAST([Currency] AS VARCHAR(50)), ''))),
            CAST([Total] AS FLOAT(53)),
            RTRIM(LTRIM(ISNULL(CAST([DeliveryAddress] AS VARCHAR(250)), ''))),
            RTRIM(LTRIM(ISNULL(CAST([SAPPONumber] AS VARCHAR(20)), ''))),
            RTRIM(LTRIM(ISNULL(CAST([DeliveryDate] AS VARCHAR(8)), ''))),
            RTRIM(LTRIM(ISNULL(CAST([Comments] AS VARCHAR(250)), ''))),
            RTRIM(LTRIM(ISNULL(CAST([CostObject] AS VARCHAR(20)), ''))),
            RTRIM(LTRIM(ISNULL(CAST([MaterialGroup] AS VARCHAR(50)), ''))),
            RTRIM(LTRIM(ISNULL(CAST([MaterialGroupDescription] AS VARCHAR(250)), ''))),
            RTRIM(LTRIM(ISNULL(CAST([ServiceLineNumber] AS VARCHAR(50)), ''))),
            CAST([Quantity2] AS FLOAT(53)),
            CAST([Price] AS FLOAT(53)),
            RTRIM(LTRIM(ISNULL(CAST([CostObject2] AS VARCHAR(20)), ''))),
            RTRIM(LTRIM(ISNULL(CAST([ServiceGroup] AS VARCHAR(50)), ''))),
            RTRIM(LTRIM(ISNULL(CAST([ShortText] AS VARCHAR(100)), ''))),
            RTRIM(LTRIM(ISNULL(CAST([ParentLineUOM] AS VARCHAR(50)), ''))),
            RTRIM(LTRIM(ISNULL(CAST([ServicesShortText] AS VARCHAR(50)), ''))),
            RTRIM(LTRIM(ISNULL(CAST([ServicesUOM] AS VARCHAR(50)), ''))),
            RTRIM(LTRIM(ISNULL(CAST([Plant] AS VARCHAR(15)), ''))),
            CAST([POItemCategory] AS TINYINT),
            [EsActualizacion],
            @UsuarioId,
            @ContratoId
        FROM @Table_CO_Type_SAPPO;

        INSERT INTO #TablaTemporalOrden
        (
            [NumeroFila],
            [NumeroPrioridad]
        )
        SELECT DISTINCT
            #TablaTemporalSAPPO.NumeroFila,
            ROW_NUMBER() OVER (PARTITION BY #TablaTemporalSAPPO.SAPPONumber,
                                            #TablaTemporalSAPPO.ItemNumber
                               ORDER BY #TablaTemporalSAPPO.NumeroFila DESC
                              ) NumeroPrioridad
        FROM #TablaTemporalSAPPO

        UPDATE #TablaTemporalSAPPO
        SET #TablaTemporalSAPPO.NumeroPrioridad = #TablaTemporalOrden.NumeroPrioridad
        FROM #TablaTemporalSAPPO
            JOIN #TablaTemporalOrden
                ON #TablaTemporalSAPPO.NumeroFila = #TablaTemporalOrden.NumeroFila

        UPDATE #TablaTemporalSAPPO
        SET #TablaTemporalSAPPO.EsActualizacion = 1
        FROM #TablaTemporalSAPPO
            JOIN CO_SAPPO
                ON #TablaTemporalSAPPO.SAPPONumber = CO_SAPPO.SAPPONumber
                   AND #TablaTemporalSAPPO.ItemNumber = CO_SAPPO.ItemNumber

        /*Inserción de POs*/
        INSERT INTO dbo.CO_SAPPO
        (
            IdContrato,
            SAPPONumber,
            ItemNumber,
            VersionNumber,
            SAPVendorNumber,
            SAPMaterialNumber,
            Quantity,
            UnitPrice,
            Currency,
            Total,
            Deliveryaddress,
            DeliveryDate,
            Comments,
            CostObject,
            MaterialGroup,
            MaterialGroupDescription,
            ServiceLineNumber,
            Quantity2,
            Price2,
            CostObject2,
            ServiceGroup,
            CreadoEl,
            CreadoPor,
            ShortText,
            ParentLineUOM,
            ServiceShortText,
            ServicesUOM,
            Plant,
            POItemCategory,
            POActivo
        )
        SELECT ContratoId,
               SAPPONumber,
               ItemNumber,
               VersionNumber,
               SAPVendorNumber,
               SAPMaterialNumber,
               Quantity,
               UnitPrice,
               Currency,
               Total,
               DeliveryAddress,
               DeliveryDate,
               Comments,
               CostObject,
               MaterialGroup,
               MaterialGroupDescription,
               ServiceLineNumber,
               Quantity2,
               Price,
               CostObject2,
               ServiceGroup,
               @FechaHoy,
               @UsuarioId,
               ShortText,
               ParentLineUOM,
               ServicesShortText,
               ServicesUOM,
               Plant,
               POItemCategory,
               1
        FROM #TablaTemporalSAPPO
        WHERE #TablaTemporalSAPPO.NumeroPrioridad = 1
              AND ISNULL(EsActualizacion, 0) = 0

        /*Actualización de POs*/
        UPDATE CO_SAPPO
        SET VersionNumber = #TablaTemporalSAPPO.VersionNumber,
            SAPVendorNumber = #TablaTemporalSAPPO.SAPVendorNumber,
            SAPMaterialNumber = #TablaTemporalSAPPO.SAPMaterialNumber,
            Quantity = #TablaTemporalSAPPO.Quantity,
            UnitPrice = #TablaTemporalSAPPO.UnitPrice,
            Currency = #TablaTemporalSAPPO.Currency,
            Total = #TablaTemporalSAPPO.Total,
            Deliveryaddress = #TablaTemporalSAPPO.Deliveryaddress,
            DeliveryDate = #TablaTemporalSAPPO.DeliveryDate,
            Comments = #TablaTemporalSAPPO.Comments,
            CostObject = #TablaTemporalSAPPO.CostObject,
            MaterialGroup = #TablaTemporalSAPPO.MaterialGroup,
            MaterialGroupDescription = #TablaTemporalSAPPO.MaterialGroupDescription,
            ServiceLineNumber = #TablaTemporalSAPPO.ServiceLineNumber,
            Quantity2 = #TablaTemporalSAPPO.Quantity2,
            Price2 = #TablaTemporalSAPPO.Price,
            CostObject2 = #TablaTemporalSAPPO.CostObject2,
            ServiceGroup = #TablaTemporalSAPPO.ServiceGroup,
            ModificadoEl = @FechaHoy,
            ShortText = #TablaTemporalSAPPO.ShortText,
            ParentLineUOM = #TablaTemporalSAPPO.ParentLineUOM,
            ServiceShortText = #TablaTemporalSAPPO.ServicesShortText,
            ServicesUOM = #TablaTemporalSAPPO.ServicesUOM,
            Plant = #TablaTemporalSAPPO.Plant,
            POItemCategory = #TablaTemporalSAPPO.POItemCategory,
            POActivo = CASE
                           WHEN POActivo IS NOT NULL THEN
                               POActivo
                           WHEN POActivo IS NULL THEN
                               1
                       END,
		CancaladoPor = CASE
                           WHEN POActivo IS NOT NULL THEN
                               CancaladoPor
                           WHEN POActivo IS NULL THEN
                               @UsuarioId
                       END,
		CancaladoEl =  CASE
                           WHEN POActivo IS NOT NULL THEN
                               CancaladoEl
                           WHEN POActivo IS NULL THEN
                               @FechaHoy
                       END
        FROM CO_SAPPO
            JOIN #TablaTemporalSAPPO
                ON CO_SAPPO.SAPPONumber = #TablaTemporalSAPPO.SAPPONumber
                   AND CO_SAPPO.ItemNumber = #TablaTemporalSAPPO.ItemNumber
                   AND CO_SAPPO.IdContrato = #TablaTemporalSAPPO.ContratoId
        WHERE #TablaTemporalSAPPO.NumeroPrioridad = 1
              AND ISNULL(#TablaTemporalSAPPO.EsActualizacion, 0) = 1;

        IF EXISTS
        (
            SELECT 1
            FROM CO_SAP_ImportMaxFila
            WHERE IdContratista = @IdContratista
        )
        BEGIN
            UPDATE CO_SAP_ImportMaxFila
            SET FilaMaxPO = @NumeroRegitros,
                ModificadoPor = @UsuarioId,
                ModificadoEl = @FechaHoy
            WHERE IdContratista = @IdContratista
        END
        ELSE
        BEGIN
            INSERT INTO CO_SAP_ImportMaxFila
            (
                IdContratista,
                FilaMaxSES,
                FilaMaxPO,
                FilaMaxGR,
                ModificadoPor,
                ModificadoEl
            )
            VALUES
            (@IdContratista, 0, @NumeroRegitros, 0, @UsuarioId, @FechaHoy)
        END

		SELECT '';
		 /*Se regresan los SAPPONumber y ItemNumber que son registros nuevos para el envió de correos*/
        SELECT #TablaTemporalSAPPO.SAPPONumber,
               #TablaTemporalSAPPO.ItemNumber
        FROM #TablaTemporalSAPPO
        WHERE ISNULL(#TablaTemporalSAPPO.EsActualizacion, 0) = 0
              AND #TablaTemporalSAPPO.NumeroPrioridad = 1
        GROUP BY #TablaTemporalSAPPO.SAPPONumber,
                 #TablaTemporalSAPPO.ItemNumber;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        SELECT @ErrorMessage = ERROR_MESSAGE()

        ROLLBACK TRAN

        RAISERROR(@ErrorMessage, 17, 1)
    END CATCH;
END