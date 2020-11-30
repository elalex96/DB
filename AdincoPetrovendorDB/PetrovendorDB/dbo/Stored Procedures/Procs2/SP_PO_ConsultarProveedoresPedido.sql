CREATE PROCEDURE SP_PO_ConsultarProveedoresPedido @IdSolicitudPedido INT, @Version INT, @IdPedido INT
AS
BEGIN
	
	SELECT PR.IdProveedor, (SELECT TOP 1 RazonSocial +' '+ RegimenCapital from s_proveedor where IdProveedor= P.IdProveedorCompras) AS Proveedor, U.IdUsuario,  U.Nombre, U.Correo, P.IdPedido,H.HorasVigencia, PG.IdPedido AS IdPedidoGeneral
	FROM MM_Pedido AS P 
	INNER JOIN S_Proveedor AS PR ON PR.IdProveedor = P.IdSubcontratista
    INNER JOIN S_UsuarioProveedor AS UP ON UP.IdProveedor = PR.IdProveedor
	INNER JOIN S_Usuario AS U ON U.IdUsuario = UP.IdUsuario 
	INNER JOIN MM_HorasVigenciaPedido AS H ON H.IdPedido =P.IdPedido 
	INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdTipoPedido = 2 AND PG.IdProveedorCliente = P.IdProveedorCompras
	WHERE P.IdSolicitudPedido = @IdSolicitudPedido AND P.Version = @Version AND (U.IdTipoUsuario = 4 OR U.IdTipoUsuario = 3) AND PG.IdPedido = @IdPedido
	ORDER BY P.IdPedido

END
