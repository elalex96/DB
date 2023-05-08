-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarIdPedidoGeneral]  
@IdIdentificador INT,
@IdTipoPedido INT,
@IdProveedor INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	 DECLARE @IdPedidoGeneral INT = 0; 

	SET @IdPedidoGeneral = (SELECT IdPedido FROM dbo.MM_Pedidos
	WHERE IdIdentificador=@IdIdentificador AND IdProveedorCliente=@IdProveedor AND IdTipoPedido=@IdTipoPedido)

	SELECT @IdPedidoGeneral

END
