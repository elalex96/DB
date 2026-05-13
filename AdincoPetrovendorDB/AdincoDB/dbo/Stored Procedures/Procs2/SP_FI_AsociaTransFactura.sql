-- =============================================
-- Author:		Josue Gonzalez
-- Create date: 25/05/2017
-- Description:	Asocia una transferencia a una factura
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_AsociaTransFactura] 
-- SET NOCOUNT ON added to prevent extra result sets from
@trans              INT,
@factura            INT,
@tipoDocFacturacion INT,
@IdUsuario          INT
AS
         BEGIN
-- interfering with SELECT statements.
             SET NOCOUNT ON;

-- Insert statements for procedure here
             IF(@tipoDocFacturacion = 1)
                 BEGIN
                     INSERT INTO [dbo].[FI_TransferFactura]
				([IdTransfer],
				 [IdFactura],
				 [CvTipoDocFacturacion],
				 [CreadoPor],
				 [CreadoEn]
				)
                     VALUES
				(@trans,
				 @factura,
				 @tipoDocFacturacion,
				 @IdUsuario,
				 GETDATE()
				);
                 END;
             IF(@tipoDocFacturacion = 2
                OR @tipoDocFacturacion = 3)
                 BEGIN
                     INSERT INTO [dbo].[FI_TransferFactura]
				([IdTransfer],
				 [IdPedimentoComprobante],
				 [CvTipoDocFacturacion],
				 [CreadoPor],
				 [CreadoEn]
				)
                     VALUES
				(@trans,
				 @factura,
				 @tipoDocFacturacion,
				 @IdUsuario,
				 GETDATE()
				);
                 END;
             IF @@ERROR <> 0
                 SELECT 'false' AS msj;
                 ELSE
             SELECT 'true' AS msj;
         END;
