IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_INS_UPD_CO_SAPMaterial'
)
    DROP PROCEDURE USP_INS_UPD_CO_SAPMaterial;
GO

CREATE PROCEDURE USP_INS_UPD_CO_SAPMaterial
    @Table_CO_Type_SAPMaterial CO_Type_SAPMaterial READONLY,
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
                @IdBitacora INT = 0;

        CREATE TABLE #TablaTemporalSAPMaterial
        (
            [NumeroFila] INT NULL,
            [MaterialDescription] VARCHAR(150) NULL,
            [MaterialLongText] VARCHAR(500) NULL,
            [BaseUnitOfMeasure] VARCHAR(50) NULL,
            [SAPMaterialNumber] VARCHAR(20) NULL,
            [Plant] VARCHAR(15) NULL,
            [KeyLastImport] VARCHAR(50) NULL,
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

        INSERT INTO #TablaTemporalSAPMaterial
        (
            [NumeroFila],
            [MaterialDescription],
            [MaterialLongText],
            [BaseUnitOfMeasure],
            [SAPMaterialNumber],
            [Plant],
            [KeyLastImport],
            [EsActualizacion],
            [UsuarioId],
            [ContratoId]
        )
        SELECT DISTINCT
            [NumeroFila],
            RTRIM(LTRIM(ISNULL([MaterialDescription], ''))),
            RTRIM(LTRIM(ISNULL([MaterialLongText], ''))),
            RTRIM(LTRIM(ISNULL([BaseUnitOfMeasure], ''))),
            RTRIM(LTRIM(ISNULL([SAPMaterialNumber], ''))),
            RTRIM(LTRIM(ISNULL([Plant], ''))),
            RTRIM(LTRIM(ISNULL([KeyLastImport], ''))),
            0,
            @UsuarioId,
            @ContratoId
        FROM @Table_CO_Type_SAPMaterial;

        INSERT INTO #TablaTemporalOrden
        (
            [NumeroFila],
            [NumeroPrioridad]
        )
        SELECT DISTINCT
            #TablaTemporalSAPMaterial.NumeroFila,
            ROW_NUMBER() OVER (PARTITION BY #TablaTemporalSAPMaterial.SAPMaterialNumber
                               ORDER BY #TablaTemporalSAPMaterial.NumeroFila DESC
                              ) NumeroPrioridad
        FROM #TablaTemporalSAPMaterial

        UPDATE #TablaTemporalSAPMaterial
        SET #TablaTemporalSAPMaterial.NumeroPrioridad = #TablaTemporalOrden.NumeroPrioridad
        FROM #TablaTemporalSAPMaterial
            JOIN #TablaTemporalOrden
                ON #TablaTemporalSAPMaterial.NumeroFila = #TablaTemporalOrden.NumeroFila

        UPDATE #TablaTemporalSAPMaterial
        SET #TablaTemporalSAPMaterial.EsActualizacion = 1
        FROM #TablaTemporalSAPMaterial
            JOIN CO_SAPMaterial
                ON #TablaTemporalSAPMaterial.SAPMaterialNumber = CO_SAPMaterial.SAPMaterialNumber
                   AND #TablaTemporalSAPMaterial.ContratoId = CO_SAPMaterial.IdContrato

        /*Insercion de Materiales*/
        INSERT INTO CO_SAPMaterial
        (
            IdContrato,
            SAPMaterialNumber,
            MaterialDescription,
            MaterialLongText,
            Unit,
            CreadoEl,
            CreadoPor,
            Plant,
            Activo,
            KeyLastImport
        )
        SELECT ContratoId,
               SAPMaterialNumber,
               MaterialDescription,
               MaterialLongText,
               BaseUnitOfMeasure,
               @FechaHoy,
               UsuarioId,
               Plant,
               1,
               KeyLastImport
        FROM #TablaTemporalSAPMaterial
        WHERE #TablaTemporalSAPMaterial.NumeroPrioridad = 1
              AND ISNULL(EsActualizacion, 0) = 0

        /*Actualizacion de Materiales*/
        UPDATE CO_SAPMaterial
        SET MaterialDescription = #TablaTemporalSAPMaterial.MaterialDescription,
            MaterialLongText = #TablaTemporalSAPMaterial.MaterialLongText,
            Unit = #TablaTemporalSAPMaterial.BaseUnitOfMeasure,
            Plant = #TablaTemporalSAPMaterial.Plant,
            Activo = 1,
            KeyLastImport = #TablaTemporalSAPMaterial.KeyLastImport
        FROM CO_SAPMaterial
            JOIN #TablaTemporalSAPMaterial
                ON CO_SAPMaterial.SAPMaterialNumber = #TablaTemporalSAPMaterial.SAPMaterialNumber
                   AND CO_SAPMaterial.IdContrato = #TablaTemporalSAPMaterial.ContratoId
        WHERE #TablaTemporalSAPMaterial.NumeroPrioridad = 1
              AND ISNULL(#TablaTemporalSAPMaterial.EsActualizacion, 0) = 1;

		SELECT '';

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        SELECT @ErrorMessage = ERROR_MESSAGE()

        ROLLBACK TRAN

        RAISERROR(@ErrorMessage, 17, 1)
    END CATCH;
END