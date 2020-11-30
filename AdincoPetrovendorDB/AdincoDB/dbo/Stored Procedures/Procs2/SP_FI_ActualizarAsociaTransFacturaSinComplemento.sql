CREATE PROCEDURE [dbo].[SP_FI_ActualizarAsociaTransFacturaSinComplemento] 
-- SET NOCOUNT ON added to prevent extra result sets from
@trans              INT, 
@factura            INT, 
@tipoDocFacturacion INT, 
@IdUsuario          INT, 
@MontoPagado        DECIMAL(18, 6)  = 0, 
@IdContrato         INT            = 0
AS
     BEGIN
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         -- =============================================
         -- Author:			Marcos Garcia
         -- Create date:	03-12-2019
         -- Description:	Asocia una transferencia a una factura sin complemento de pago.
         -- =============================================
       
         -- Insert statements for procedure here
         /**/

         IF (@tipoDocFacturacion = 1)
             BEGIN
                 INSERT INTO [dbo].[FI_TransferFactura]
                 ([IdTransfer], 
                  [IdFactura], 
                  [CvTipoDocFacturacion], 
                  [CreadoPor], 
                  [CreadoEn], 
                  [MontoPagado]
                 )
                 VALUES
                 (@trans, 
                  @factura, 
                  @tipoDocFacturacion, 
                  @IdUsuario, 
                  GETDATE(), 
                  @MontoPagado
                 );               

                 --
                 INSERT INTO dbo.FI_AprobacionFactura
                 (IdFactura, 
                  IdContrato, 
                  IdUsuarioAprobador, 
                  IdEstatus
                 )
                 VALUES
                 (@factura, -- IdFactura - int
                  @IdContrato, -- IdContrato - int
                  @IdUsuario, -- IdUsuarioAprobador - int
                  10003	  -- Pago Aprobado - int
                 );
             END;
         

         /**/

         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;

             /**/

     END;