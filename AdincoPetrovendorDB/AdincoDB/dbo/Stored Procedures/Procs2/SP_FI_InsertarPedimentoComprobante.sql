IF OBJECT_ID('[dbo].[SP_FI_InsertarPedimentoComprobante]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[SP_FI_InsertarPedimentoComprobante];
GO

CREATE PROCEDURE [dbo].[SP_FI_InsertarPedimentoComprobante]
    @IdContrato                   INT,
    @NumeroPedimento             VARCHAR(3000),
    @ClavePedimento              INT,
    @FolioComprobante            VARCHAR(3000),
    @FechaPago                   DATE,
    @Regimen                     VARCHAR(3000),
    @AduanaES                    VARCHAR(3000),
    @IdSubcontratistaExportador INT,
    @IdMoneda                    INT,
    @AcuseElectronico           VARCHAR(3000),
    @DescripcionMercancia       VARCHAR(5000),
    @SubTotal                   MONEY,
    @IdUsuario                  INT,
    @CvTipoDoc                  INT,
    @DocumentoPDF               IMAGE,
    @IdFiscal                   VARCHAR(50),
    @RazonSocial                VARCHAR(3000),
    @ImporteInco                MONEY,
    @CuentaBancaria             VARCHAR(500) = '',
    @EsNotaCredito              BIT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idped INT;
    DECLARE @IdSubcontratistaImportador INT;
    DECLARE @IdTipoDocumentoPI INT = 4;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Obtener proveedor importador
        SELECT 
            @IdSubcontratistaImportador = CO_Contratista.IdProveedor
        FROM CO_Contrato (NOLOCK)
        INNER JOIN CO_Contratista (NOLOCK)
            ON CO_Contrato.IdContratista = CO_Contratista.IdContratista
        WHERE CO_Contrato.IdContrato = @IdContrato;

        -- Insertar encabezado del pedimento
        INSERT INTO [dbo].[FI_PedimentoComprobante]
        (
            [IdContrato],
            [NumeroPedimento],
            [ClavePedimento],
            [FolioComprobante],
            [FechaPago],
            [Regimen],
            [IdSubcontratistaImportador],
            [AduanaES],
            [IdSubcontratistaExportador],
            [IdMoneda],
            [AcuseElectronico],
            [CvTipoDocFacturacion],
            [CreadoPor],
            [CreadoEn],
            [IdFiscalP],
            [RazonSocialP],
            [CuentaBancaria],
            [EsNotaCredito]
        )
        VALUES
        (
            @IdContrato,
            @NumeroPedimento,
            @ClavePedimento,
            @FolioComprobante,
            @FechaPago,
            @Regimen,
            @IdSubcontratistaImportador,
            @AduanaES,
            @IdSubcontratistaExportador,
            @IdMoneda,
            @AcuseElectronico,
            @CvTipoDoc,
            @IdUsuario,
            GETDATE(),
            @IdFiscal,
            @RazonSocial,
            @CuentaBancaria,
            @EsNotaCredito
        );

        SET @idped = SCOPE_IDENTITY();

        -- Insertar detalle del pedimento
        INSERT INTO [dbo].[FI_PedimentoComprobanteDetalle]
        (
            [IdPedimentoComprobante],
            [DescripcionMercancia],
            [PrecioUnitario],
            [CreadoPor],
            [CreadoEn],
            [ImporteTotal]
        )
        VALUES
        (
            @idped,
            @DescripcionMercancia,
            @SubTotal,
            @IdUsuario,
            GETDATE(),
            @ImporteInco
        );

        -- Insertar documento PDF
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
            @IdTipoDocumentoPI,
            @idped,
            CONCAT('PI_', @idped, '.pdf'),
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
            'Error en SP [SP_FI_InsertarPedimentoComprobante]: ',
            ERROR_MESSAGE()
        );

        -- Lanzar mensaje personalizado con nombre del SP
        THROW 51000, @msg, 1;
    END CATCH
END;
GO
