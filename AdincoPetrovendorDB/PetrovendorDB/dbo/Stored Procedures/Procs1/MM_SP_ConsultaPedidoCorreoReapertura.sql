
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <12-07-2018>
-- Description:	<Se consultan datos para correo que solicita la reapertura de un pedido>
-- =============================================

CREATE procedure MM_SP_ConsultaPedidoCorreoReapertura
	@IdPedido INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT pg.IdPedido,
			u.Nombre,
			pg.IdTipoPedido,
			u.Correo
	FROM dbo.MM_Pedido p
	INNER JOIN MM_pedidos pg ON pg.IdIdentificador = p.IdPedido
	INNER JOIN dbo.MM_HistorialCierrePedido hcp ON hcp.IdPedido = p.IdPedido
	INNER JOIN dbo.S_Usuario u ON u.IdUsuario = hcp.CambiadoPor AND hcp.UltimoCierre = 1
	WHERE p.IdPedido = @IdPedido
END


