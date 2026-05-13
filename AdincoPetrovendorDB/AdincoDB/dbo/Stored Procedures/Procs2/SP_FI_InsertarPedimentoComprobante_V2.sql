IF OBJECT_ID('[dbo].[SP_FI_InsertarPedimentoComprobante_V2]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[SP_FI_InsertarPedimentoComprobante_V2];
GO

CREATE PROCEDURE [dbo].[SP_FI_InsertarPedimentoComprobante_V2]   
    @IdContrato                 INT, 
    @FolioComprobante           VARCHAR(500), 
    @FechaPago                  DATE, 
    @IdSubcontratistaExportador INT, 
    @IdMoneda                   INT, 
    @IdUnidadMedida             INT, 
    @NumFac                     VARCHAR(50), 
    @ClaseBienServicio          VARCHAR(1000), 
    @Subtotal                   MONEY, 
    @IdUsuario                  INT, 
    @CvTipoDoc                  INT, 
    @DocumentoPDF               IMAGE,  
    @EsNotaCredito              BIT 
AS
BEGIN  
    SET NOCOUNT ON;

    DECLARE @idped INT;
	DECLARE @IdTipoDocumentoPE INT = 5;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insertar cabecera del comprobante
        INSERT INTO [dbo].[FI_PedimentoComprobante]
        (
            [IdContrato], 
            [FolioComprobante], 
            [FechaPago], 
            [IdSubcontratistaExportador], 
            [IdMoneda], 
            [CvTipoDocFacturacion], 
            [CreadoPor], 
            [CreadoEn], 
            [NumFacturaC], 
            [EsNotaCredito]
        )
        VALUES
        (
            @IdContrato, 
            @FolioComprobante, 
            @FechaPago, 
            @IdSubcontratistaExportador, 
            @IdMoneda, 
            @CvTipoDoc, 
            @IdUsuario, 
            GETDATE(), 
            @NumFac, 
            @EsNotaCredito
        );

        SET @idped = SCOPE_IDENTITY();

        -- Insertar detalle del comprobante
        INSERT INTO [dbo].[FI_PedimentoComprobanteDetalle]
        (
            [IdPedimentoComprobante], 
            [IdUnidadMedida], 
            [ClaseBienServicio], 
            [PrecioUnitario], 
            [CreadoPor], 
            [CreadoEn]
        )
        VALUES
        (
            @idped, 
            @IdUnidadMedida, 
            @ClaseBienServicio, 
            @Subtotal, 
            @IdUsuario, 
            GETDATE()
        );

        -- Insertar documento PDF asociado
        INSERT INTO [dbo].[FI_Documento]
        (
            [IdTipoDocumento], 
            [IdPedimentoComprobante], 
            [NombreExtensionArchivo], 
            [IdUsuario], 
            [FechaCarga], 
            [IsEliminado], 
            [DocumentoByte]
        )
        VALUES
        (
            @IdTipoDocumentoPE, 
            @idped, 
            CONCAT('PE_', @idped, '.pdf'), 
            @IdUsuario, 
            GETDATE(), 
            0, 
            @DocumentoPDF
        );

        COMMIT;

        SELECT 'true' AS Resultado, @idped AS IdPedimento;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @msg NVARCHAR(MAX);
        SET @msg = CONCAT(
            'Error en SP [SP_FI_InsertarPedimentoComprobante_V2]: ',
            ERROR_MESSAGE()
        );

        -- Lanzar mensaje personalizado con nombre del SP
        THROW 51000, @msg, 1;
    END CATCH
END;
GO
