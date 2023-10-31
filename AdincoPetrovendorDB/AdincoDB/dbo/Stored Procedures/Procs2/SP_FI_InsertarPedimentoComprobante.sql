IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'SP_FI_InsertarPedimentoComprobante'
    )
    DROP PROCEDURE SP_FI_InsertarPedimentoComprobante
GO
-- =============================================
-- Author:		Manuel CD
-- Create date: 04-10-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_InsertarPedimentoComprobante]
    @IdContrato                 INT,
    @NumeroPedimento            VARCHAR(3000),
    @ClavePedimento             INT,
    @FolioComprobante           VARCHAR(3000),
    @FechaPago                  DATE,
    @Regimen                    VARCHAR(3000),
    @AduanaES                   VARCHAR(3000),
    @IdSubcontratistaExportador INT,
    @IdMoneda                   INT,
    @AcuseElectronico           VARCHAR(3000),
    @DescripcionMercancia       VARCHAR(5000),
    @SubTotal                   MONEY,
    @IdUsuario                  INT,
    @CvTipoDoc                  INT,
    @DocumentoPDF               IMAGE,
    @IdFiscal                   VARCHAR(50),
    @RazonSocial                VARCHAR(3000),
    @ImporteInco                MONEY,
    @CuentaBancaria             VARCHAR(500) = ''
AS
    BEGIN

        SET NOCOUNT ON;
        DECLARE @idped INT;
        DECLARE @IdSubcontratistaImportador INT;
		DECLARE @IdTipoDocumento INT = 4;
        /*PEDIMENTO*/

        --Obtener proveedor importador
        SELECT
            @IdSubcontratistaImportador = CO_Contratista.IdProveedor
        FROM
            CO_Contrato (NOLOCK)
            JOIN
                CO_Contratista (NOLOCK)
                    ON CO_Contrato.IdContratista = CO_Contratista.IdContratista
        WHERE
            CO_Contrato.IdContrato = @IdContrato;

        BEGIN
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
                    CuentaBancaria
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
                    @CuentaBancaria
                );
        END;
        SET @idped = @@IDENTITY;
        --
        BEGIN
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
                    @idped, @DescripcionMercancia, @SubTotal, @IdUsuario, GETDATE(), @ImporteInco
                );
        END;
        --
        BEGIN
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
                    @IdTipoDocumento, @idped, CONCAT('PI_', @idped, '.pdf'), @IdUsuario, GETDATE(), 0, @DocumentoPDF
                );
        END;
        IF @@ERROR <> 0
            SELECT
                'false' AS msj;
        ELSE
            SELECT
                'true' AS msj,
                @idped;
    END;
