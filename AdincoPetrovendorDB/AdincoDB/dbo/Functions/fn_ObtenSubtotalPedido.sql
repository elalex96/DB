-- =============================================
-- Author:		Luis David De La Cruz Bautista
-- Create date: 29/21/2021
-- Description:	Función para obtener el subtotal para issue 1489(Petrovendor)
-- =============================================
CREATE FUNCTION [dbo].[fn_ObtenSubtotalPedido]
(
    @Moneda INT,
    @IdPedido INT,
    @IdContrato INT = NULL
)
RETURNS FLOAT
BEGIN
    DECLARE @Subtotal FLOAT = 0;

    IF @Moneda = 1
    BEGIN
        SET @Subtotal =
        (
            SELECT ISNULL(SUM(Petrovendor.dbo.MM_PedidoDetalle.Subtotal), 0)
            FROM Petrovendor.dbo.MM_PedidoDetalle (NOLOCK)
                JOIN Petrovendor.dbo.MM_Pedido (NOLOCK)
                    ON Petrovendor.dbo.MM_PedidoDetalle.IdPedido = Petrovendor.dbo.MM_Pedido.IdPedido
            WHERE Petrovendor.dbo.MM_PedidoDetalle.IdPedido = @IdPedido
                  AND Petrovendor.dbo.MM_Pedido.IdContrato = @IdContrato
        )
    END

    RETURN @Subtotal
END