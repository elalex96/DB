-- =============================================
-- Author:		Luis David De La Cruz Bautista
-- Create date: 29/21/2021
-- Description:	Función para obtener el subtotal para issue 1489(Petrovendor)
-- =============================================
CREATE FUNCTION fn_ObtenSubtotalPedido
(
	@Moneda int,
	@IdPedido int ,
	@IdContrato int = NULL
)
returns VARCHAR(MAX)
begin 
DECLARE @Subtotal varchar(max) = FORMAT(0, '#,#0.000'); --SELECT DBO.fn_ObtenSubtotalPedido(1,24339,10047) AS SUBTOTAL
	IF @Moneda = 1
	BEGIN
		set @Subtotal = (SELECT  
		FORMAT(SUM(PD.Subtotal), '#,#0.000') AS SUBTOTAL
		FROM Petrovendor.dbo.MM_PedidoDetalle PD 
		JOIN Petrovendor.dbo.MM_Pedido AS P   
		ON PD.IdPedido = P.IdPedido  
		WHERE pd.IdPedido = @IdPedido AND
		P.IdContrato = @IdContrato)
	END
	return @Subtotal
end