
-- =============================================
CREATE PROCEDURE SP_DEA_ConsultarUsuarioNotificiacion88
	-- Add the parameters for the stored procedure here
	@IdProveedor int, 
	@IdUsuario INT,
	@IdSolicitudPedido INT
AS
BEGIN
	---OBTENER LOS USUARIOS RELACIONADOS A LOS CENTROS DE COSTO DE LA REQUISICIÓN ACTUAL
	 CREATE TABLE #CentroCosto(IdCentroCosto INT)
		
	INSERT INTO #CentroCosto
	(IdCentroCosto)
		
	SELECT SPLP.IdCentroCosto
	FROM dbo.MM_SolicitudPedidoDetalle SPD
	INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPLP 
		ON SPLP.IdSolicitudPedidoDetalle=SPD.IdSolicitudPedidoDetalle
	INNER JOIN dbo.CC_CentroCosto CC ON CC.IdCentroCosto=SPLP.IdCentroCosto		
	WHERE SPD.IdSolicitudPedido=@IdSolicitudPedido
	GROUP BY SPLP.IdCentroCosto

	SELECT U.IdUsuario, U.Nombre, U.Correo,UN.TipoNotificacion
	FROM dbo.DEA_UsuariosNotificar UN
	INNER JOIN dbo.S_Usuario U ON UN.IdUsuario=U.IdUsuario
	INNER JOIN #CentroCosto CC ON CC.IdCentroCosto = UN.IdCentroCosto
	WHERE UN.TipoNotificacion='SOLITAR_RELACION_PRPO'
	AND UN.Activo=1 
	AND U.Activo=1
	AND UN.IdProveedor=@IdProveedor 
	 
	  
END

