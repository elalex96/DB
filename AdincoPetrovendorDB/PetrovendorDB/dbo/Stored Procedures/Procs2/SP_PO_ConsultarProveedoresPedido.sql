-- DAC- No retornar usuarios inactivos 
CREATE PROCEDURE [dbo].[SP_PO_ConsultarProveedoresPedido] 
@IdSolicitudPedido 
INT, @Version INT, 
@IdPedido INT
AS
BEGIN
	
	SELECT PR.IdProveedor, 
	(ISNULL(PC.RazonSocial,'') +' '+ ISNULL(PC.RegimenCapital,'')) AS Proveedor,
	U.IdUsuario,
	U.Nombre,
	U.Correo,
	P.IdPedido,
	H.HorasVigencia,
	PG.IdPedido AS IdPedidoGeneral
	FROM MM_Pedido AS P (NOLOCK)
	INNER JOIN S_Proveedor AS PR  (NOLOCK)
		ON P.IdSubcontratista = PR.IdProveedor 
	INNER JOIN S_Proveedor PC
		ON P.IdProveedorCompras = PC.IdProveedor
    INNER JOIN S_UsuarioProveedor AS UP  (NOLOCK)
		ON PR.IdProveedor = UP.IdProveedor 
	INNER JOIN S_Usuario AS U  (NOLOCK)
		ON UP.IdUsuario  = U.IdUsuario 
	INNER JOIN MM_HorasVigenciaPedido AS H  (NOLOCK)
		ON P.IdPedido  = H.IdPedido 
	INNER JOIN MM_Pedidos AS PG  (NOLOCK)
		ON P.IdPedido = PG.IdIdentificador 
		AND P.IdProveedorCompras = PG.IdProveedorCliente 
		AND PG.IdTipoPedido IN (2,4,6) --> CTES MER, DIRECTA, ORDEN 		
	WHERE P.IdSolicitudPedido = @IdSolicitudPedido 
	AND P.Version = @Version 
	AND PG.IdPedido = @IdPedido
	AND (U.IdTipoUsuario = 4 OR U.IdTipoUsuario = 3) 	
	AND U.Activo = 1 --> Solo usuarios activos
	ORDER BY P.IdPedido

END
