-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <07-11-2019>
-- Description:	<obtener el pedido y version filtrando por el provedor y el pedido gral>
-- =============================================

CREATE PROCEDURE SP_ConsultaPedidoxDocumento @IdDocumento INT, @TipoDocumento INT 
AS
	BEGIN
		IF(@TipoDocumento = 10)
		BEGIN
			SELECT doc.IdPedido FROM dbo.DocumentosPedido doc WHERE doc.Id = @IdDocumento
		END	
	END
