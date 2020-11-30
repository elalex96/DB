-- =============================================
-- Author:		JG
-- Create date: 250719
-- Description:	Devuelve el numero de pedido a partir del numero de OCD (IdFactura)
-- =============================================
CREATE PROCEDURE MM_SP_ConsultaIdNoOCD
	
	@IdFactura VARCHAR(30)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   ---MM_TipoPedido (1 = CompraDirecta)
	SELECT PS.IdPedido FROM dbo.MM_Pedidos PS WHERE PS.IdIdentificador = @IdFactura AND PS.IdTipoPedido = 1
	

END
