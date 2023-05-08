-- =============================================
-- Author:		Daniel AC
-- Create date: 24-06-17
-- Description:	CONSULTA Recepcion Pedido
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaAceptacionRecepcionPedido]
	-- Add the parameters for the stored procedure here
	@IdPedidoDetalle int
 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT ISNULL(RecepcionPedido,0) AS RecepcionPedido
	FROM MM_PedidoDetalle
	WHERE IdPedidoDetalle = @IdPedidoDetalle


END

