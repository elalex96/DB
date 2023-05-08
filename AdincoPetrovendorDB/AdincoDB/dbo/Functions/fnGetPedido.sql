CREATE FUNCTION fnGetPedido(@IdDocumento INT ,@NoVersion INT, @IdTipo INT = NULL)
RETURNS INT
AS
BEGIN
	DECLARE @Rtn INT;
	IF	@IdTipo = 9
	BEGIN
		SET @Rtn=(SELECT 
		TOP 1
		ps.IdPedido
		FROM Petrovendor.dbo.TA_Operacion ta
		LEFT JOIN Petrovendor.dbo.MM_Pedido p ON ta.IdDocumento=p.IdSolicitudPedido
		LEFT JOIN Petrovendor.dbo.MM_Pedidos ps ON ps.IdIdentificador=p.IdPedido
		AND p.IdProveedorCompras=ps.IdProveedorCliente
		WHERE 
		IdDocumento=@IdDocumento 
		AND NoVersion=@NoVersion
		AND ta.IdTipoOperacion=9)
	--AND p.IdProveedorCompras=420
	END
 --SET @Rtn=(
	--	SELECT 
	--	sp.IdSolicitudPedido
	--	FROM Petrovendor.dbo.TA_Operacion ta
	--	LEFT JOIN Petrovendor.dbo.MM_Pedido p ON ta.IdDocumento=p.IdSolicitudPedido
	--	LEFT JOIN Petrovendor.dbo.MM_SolicitudPedido AS sp ON sp.IdSolicitudPedido = p.IdSolicitudPedido
	--	LEFT JOIN Petrovendor.dbo.MM_Pedidos ps ON ps.IdIdentificador=p.IdPedido
	--	AND p.IdProveedorCompras=ps.IdProveedorCliente
	--	WHERE 
	--	IdDocumento=14861 
	--	AND ta.IdTipoOperacion=2
	--	)
	RETURN @Rtn;
END