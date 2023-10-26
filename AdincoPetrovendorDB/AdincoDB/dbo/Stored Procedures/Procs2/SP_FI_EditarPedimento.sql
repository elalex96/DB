
IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'SP_FI_EditarPedimento'
    )
    DROP PROCEDURE SP_FI_EditarPedimento
GO
-- =============================================
-- Author:      Marcos Garcia
-- Create date: 15-01-2020
-- Description: Editar Pedimento
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_EditarPedimento]

@IdPedimentoComprobante     INT, 
@IdContrato                 INT, 
@NumeroPedimento            VARCHAR(5000), 
@ClavePedimento             INT, 
@FolioComprobante           VARCHAR(5000), 
@FechaPago                  DATE,
@Regimen                    VARCHAR(5000), 
@AduanaES                   VARCHAR(5000), 
@IdSubcontratistaExportador INT, 
@IdMoneda                   INT, 
@AcuseElectronico           VARCHAR(5000), 
@DescripcionMercancia       VARCHAR(5000), 
@SubTotal					MONEY, 
@IdUsuario                  INT, 
@CvTipoDoc                  INT, 
@DocumentoPDF               IMAGE, 
@IdFiscal                   VARCHAR(50), 
@RazonSocial                VARCHAR(5000), 
@ImporteInco                MONEY,
@CuentaBancaria             VARCHAR(500) = ''
AS
     BEGIN
         SET NOCOUNT ON;
         DECLARE @IdSubcontratistaImportador INT;
         DECLARE @Validacion INT;
         SET @Validacion = (DATALENGTH(@DocumentoPDF));
         /*PEDIMENTO*/
        
		--Obtener proveedor importador
         SELECT @IdSubcontratistaImportador = CO_Contratista.IdProveedor
         FROM CO_Contrato 	(NOLOCK)
              JOIN CO_Contratista ON CO_Contrato.IdContratista = CO_Contratista.IdContratista
         WHERE CO_Contratista.IdContrato = @IdContrato;
         BEGIN
 
            UPDATE dbo.FI_PedimentoComprobante
               SET 
                   NumeroPedimento = @NumeroPedimento, 
                   ClavePedimento = @ClavePedimento, 
                   FolioComprobante = @FolioComprobante, 
                   FechaPago = @FechaPago, 
                   Regimen = @Regimen, 
                   IdSubcontratistaImportador = @IdSubcontratistaImportador, 
                   AduanaES = @AduanaES, 
                   IdSubcontratistaExportador = @IdSubcontratistaExportador, 
                   IdMoneda = @IdMoneda, 
                   AcuseElectronico = @AcuseElectronico, 
                   CvTipoDocFacturacion = @CvTipoDoc, 
                   ModificadoPor = @IdUsuario, 
                   ModificadoEn = GETDATE(), 
                   IdFiscalP = @IdFiscal, 
                   RazonSocialP = @RazonSocial,
                   CuentaBancaria = @CuentaBancaria
             WHERE IdPedimentoComprobante = @IdPedimentoComprobante;
         END;
         --
         BEGIN
 
            UPDATE dbo.FI_PedimentoComprobanteDetalle
               SET 
                   DescripcionMercancia = @DescripcionMercancia, 
                   PrecioUnitario = @SubTotal, 
                   ModificadoPor = @IdUsuario, 
                   ModificadoEn = GETDATE(), 
                   ImporteTotal = @ImporteInco
             WHERE IdPedimentoComprobante = @IdPedimentoComprobante;
         END;
         BEGIN
             IF(@Validacion <> 0)
                 BEGIN
                     UPDATE dbo.FI_Documento
                       SET 
                           ModificadoPor = @IdUsuario, 
                           ModificadoEn = GETDATE()
                     WHERE IdPedimentoComprobante = @IdPedimentoComprobante;
                 END;
 
        END;
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj, 
                @IdPedimentoComprobante;
     END;


