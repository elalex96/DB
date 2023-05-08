-- =============================================
-- Author:      Marcos Garcia
-- Create date: 15-01-2020
-- Description: Editar Pedimento
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_EditarPedimento]
-- Add the parameters for the stored procedure here
@IdPedimentoComprobante     INT, 
@IdContrato                 INT, 
@NumeroPedimento            NVARCHAR(MAX), 
@ClavePedimento             INT, 
@FolioComprobante           NVARCHAR(MAX), 
@FechaPago                  DATE, 
@Regimen                    NVARCHAR(MAX), 
@AduanaES                   NVARCHAR(MAX), 
@IdSubcontratistaExportador INT, 
@IdMoneda                   INT, 
@AcuseElectronico           NVARCHAR(MAX), 
@DescripcionMercancia       NVARCHAR(MAX), 
@SubTotal                   MONEY, 
@IdUsuario                  INT, 
@CvTipoDoc                  INT, 
@DocumentoPDF               IMAGE, 
@IdFiscal                   NVARCHAR(50), 
@RazonSocial                NVARCHAR(MAX), 
@ImporteInco                MONEY,
@CuentaBancaria             NVARCHAR(500) = ''
AS
     BEGIN
         SET NOCOUNT ON;
         DECLARE @IdSubcontratistaImportador INT;
         DECLARE @Validacion INT;
         SET @Validacion = (DATALENGTH(@DocumentoPDF));
         /*PEDIMENTO*/
         --Obtener proveedor importador
         SELECT @IdSubcontratistaImportador = CC.IdProveedor
         FROM CO_Contrato C
              JOIN CO_Contratista CC ON C.IdContratista = CC.IdContratista
         WHERE C.IdContrato = @IdContrato;
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
