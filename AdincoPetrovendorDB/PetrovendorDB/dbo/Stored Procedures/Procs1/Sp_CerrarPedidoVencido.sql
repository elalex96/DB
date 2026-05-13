

-- =============================================
-- Author:		Pedro Acuña
-- Create date: 26 Junio 2019
-- Description:	Store para cerrar el (los) pedidos vencidos que alertan al usuario al hacer la carga del carrito
-- =============================================

CREATE PROCEDURE Sp_CerrarPedidoVencido @IdPedidoDetalle INT
AS
    BEGIN
        DECLARE @IdPedido INT


        SELECT @IdPedido = IdPedido
        FROM
               dbo.MM_PedidoDetalle
        WHERE
               IdPedidoDetalle = @IdPedidoDetalle


        UPDATE dbo.MM_Pedido SET Cerrado = 1 WHERE IdPedido = @IdPedido
    END