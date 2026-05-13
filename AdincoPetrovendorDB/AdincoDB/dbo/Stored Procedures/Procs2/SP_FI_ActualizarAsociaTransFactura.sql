CREATE PROCEDURE [dbo].[SP_FI_ActualizarAsociaTransFactura] 
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
         -- Author:		Josue Gonzalez
         -- Create date: 25/05/2017
         -- Description:	Asocia una transferencia a una factura
         -- =============================================
         -- DECLARE @IdContrato INT;
         -- Insert statements for procedure here
         /**/

         IF(@tipoDocFacturacion IN(1, 6))
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
                 --  SE INSERTA LA FACTURA COMO APROBADA PARA PAGOS, PARA YA QUE NO APAREZCA EN LA PANTALLA DE APROBACION DE FACTURAS COMO PENDIENTE
                 /*SELECT @IdContrato = IdContrato
                 FROM dbo.FI_Factura
                 WHERE IdFactura = @factura;*/

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
         IF(@tipoDocFacturacion IN(2, 3))
             BEGIN
                 INSERT INTO [dbo].[FI_TransferFactura]
                 ([IdTransfer], 
                  [IdPedimentoComprobante], 
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
             END;

         /**/

         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;

             /**/

     END;