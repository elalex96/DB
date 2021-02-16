-- Author:		Luis David De La Cruz Bautista
-- Create date: 03/02/2021
-- Description:	Optimización por issue 955
-- =============================================
CREATE PROCEDURE SP_PO_ConsultarProveedoresPedido @IdSolicitudPedido INT, @Version INT, @IdPedido INT
AS
BEGIN
	
	SELECT PR.IdProveedor, (SELECT TOP 1 RazonSocial +' '+ RegimenCapital from s_proveedor where IdProveedor= P.IdProveedorCompras) AS Proveedor, U.IdUsuario,  U.Nombre, U.Correo, P.IdPedido,H.HorasVigencia, PG.IdPedido AS IdPedidoGeneral
	FROM MM_Pedido AS P 
	INNER JOIN S_Proveedor AS PR 
		ON P.IdSubcontratista = PR.IdProveedor 
    INNER JOIN S_UsuarioProveedor AS UP 
		ON PR.IdProveedor = UP.IdProveedor 
	INNER JOIN S_Usuario AS U 
		ON UP.IdUsuario = U.IdUsuario 
	INNER JOIN MM_HorasVigenciaPedido AS H 
		ON P.IdPedido = H.IdPedido
	INNER JOIN MM_Pedidos AS PG 
		ON P.IdPedido = PG.IdIdentificador 
		AND PG.IdTipoPedido = 2 
		AND P.IdProveedorCompras = PG.IdProveedorCliente 
	WHERE P.IdSolicitudPedido = @IdSolicitudPedido AND P.Version = @Version AND (U.IdTipoUsuario = 4 OR U.IdTipoUsuario = 3) AND PG.IdPedido = @IdPedido
	ORDER BY P.IdPedido

END