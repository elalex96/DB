-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Actualizar confirmación de Surtido de pedido detalle
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ActualizarConfirmacionSurtidoPedidoDetalle]
	-- Add the parameters for the stored procedure here
	@IdsPedidoDetalle nvarchar(MAX),
	--@PorcentajeContenidoNacional float,
	@IdProveedor int,
	@Recepcionservicio bit,
	@IdUsuario int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	   UPDATE MM_PedidoDetalle
	   SET RecepcionPedido = @Recepcionservicio, 
	   FechaRecepcionPedido = GETDATE(),
	   IdUsuarioRecepcionServicio = @IdUsuario
	   --PorcentajeContenidoNacional = @PorcentajeContenidoNacional
	   WHERE IdPedidoDetalle in (SELECT value FROM dbo.Split(@IdsPedidoDetalle, ',')) 

END


