
-- =============================================
CREATE PROCEDURE SP_DEA_ConsultarDetallePedidoPR
	-- Add the parameters for the stored procedure here
	@IdProveedor int, 
	@IdUsuario INT,
	@IdSolicitudPedido INT, 
	@IdPedido INT,
	@NoVersion INT 
	
AS
BEGIN
	

	SELECT ISNULL(PR.ID_PR,''), PG.IdPedido,  PG.IdTipoPedido, P.IdPedido
	FROM dbo.MM_Pedido P
	INNER JOIN dbo.MM_SolicitudPedido SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
	LEFT JOIN dbo.DEA_AdjuntoPR PR ON PR.IdSolicitudPedido=SP.IdSolicitudPedido
	LEFT JOIN dbo.MM_Pedidos PG ON PG.IdIdentificador=P.IdPedido AND P.IdProveedorCompras=PG.IdProveedorCliente
	WHERE 
	P.IdSolicitudPedido=@IdSolicitudPedido
	AND P.Version=@NoVersion
	 
	  
END
