-- =============================================
-- Author:		DANIEL AC
-- Create date: 06/12/2017
-- Description:	CONSULTAR ID PEDIDO DE MM_PEDIDO MERCADEO
-- Author:		DANIEL AC
-- Update date: 07/02/2018
-- Description:	BUSCA EL ID PEDIDO DE CUALQUIER TIPO DE PEDIDO, YA QUE EL PEDIDO GENERAL ES UNICO POR PROVEEDOR
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarIdPedidoMercadeo]    
@IdPedidoGeneral INT,
@IdTipoPedido INT,
@IdProveedor INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	 DECLARE @IdPedidoMercadeo INT = 0; 

	SET @IdPedidoMercadeo = (SELECT IdIdentificador FROM dbo.MM_Pedidos
	WHERE IdPedido=@IdPedidoGeneral AND IdProveedorCliente=@IdProveedor AND IdTipoPedido IN (2,4, 6))
	--WHERE IdPedido=@IdPedidoGeneral AND IdProveedorCliente=@IdProveedor AND IdTipoPedido=@IdTipoPedido)

	SELECT ISNULL(@IdPedidoMercadeo,0)

END


