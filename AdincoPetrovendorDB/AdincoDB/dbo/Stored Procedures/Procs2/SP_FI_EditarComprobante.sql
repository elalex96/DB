-- =============================================
-- Author:		Marcos Garcia
-- Create date: 15-01-2020
-- Description:	Editar Mediante IdPedimentoComprobante
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_EditarComprobante] 
-- Add the parameters for the stored procedure here
@IdPedimentoComprobante     INT, 
@IdContrato                 INT, 
@FolioComprobante           NVARCHAR(MAX), 
@FechaPago                  DATE, 
@IdSubcontratistaExportador INT, 
@IdMoneda                   INT, 
@IdUnidadMedida             INT, 
@NumFac                     NVARCHAR(50), 
@ClaseBienServicio          NVARCHAR(MAX), 
@Subtotal                   MONEY, 
@IdUsuario                  INT, 
@CvTipoDoc                  INT, 
@IsNotaCredito				BIT,
@DocumentoPDF               IMAGE
AS
     BEGIN
         SET NOCOUNT ON;

         /*COMPROBANTE*/

         DECLARE @Validacion INT;
         SET @Validacion = (DATALENGTH(@DocumentoPDF));
         BEGIN
             UPDATE dbo.FI_PedimentoComprobante
               SET 
                   FolioComprobante = @FolioComprobante, 
                   FechaPago = @FechaPago, 
                   IdSubcontratistaExportador = @IdSubcontratistaExportador, 
                   IdMoneda = @IdMoneda, 
                   CvTipoDocFacturacion = @CvTipoDoc, 
                   ModificadoPor = @IdUsuario, 
                   ModificadoEn = GETDATE(), 
                   NumFacturaC = @NumFac,
				   EsnotaCredito = @IsNotaCredito
             WHERE IdPedimentoComprobante = @IdPedimentoComprobante;
         END;
         BEGIN
             UPDATE dbo.FI_PedimentoComprobanteDetalle
               SET 
                   IdUnidadMedida = @IdUnidadMedida, 
                   ClaseBienServicio = @ClaseBienServicio, 
                   PrecioUnitario = @Subtotal, 
                   ModificadoPor = @IdUsuario, 
                   ModificadoEn = GETDATE()
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