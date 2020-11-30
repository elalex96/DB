CREATE PROCEDURE ObtenerInfoSolped
@IdSolicitudPedido INT,
@IdProveedor INT
AS
BEGIN

    SELECT p.RazonSocial, sp.FechaAlta, sp.IdPeriodo, sp.IdPresupuesto, sp.MotivoUrgencia,
	 spd.IdMaterial, spd.Cantidad, spd.IdDomicilioEntrega, spd.IdUnidad, spd.observaciones,
	 spdl.IdCentroCosto, spdl.IdInstalacion, spdl.IdLineaPresupuesto, spd.IdSolicitudPedidoDetalle, per.NombrePeriodo, CONCAT(pres.Nombre, ' [ ',pres.IdPresupuestoCNH,' ]') AS Presupuesto,
	 e.Nombre AS Estatus, sp.PeticionEnviada
	FROM dbo.MM_SolicitudPedido sp 
	INNER JOIN dbo.MM_SolicitudPedidoDetalle spd ON spd.IdSolicitudPedido = sp.IdSolicitudPedido
	INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdl ON spdl.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
	INNER JOIN dbo.TA_Operacion tao ON tao.IdDocumento = @IdSolicitudPedido AND tao.IdTipoOperacion = 2
	LEFT JOIN dbo.S_Proveedor p ON p.IdProveedor = sp.IdProveedor
	LEFT JOIN Adinco.dbo.CO_PeriodoContrato per ON per.IdPeriodo = sp.IdPeriodo
	LEFT JOIN Adinco.dbo.CO_Presupuesto pres ON pres.IdPresupuesto = sp.IdPresupuesto
	LEFT JOIN dbo.TA_Estatus e ON e.IdEstatus = tao.IdEstatusOperacion
	WHERE sp.IdSolicitudPedido = @IdSolicitudPedido AND sp.IdProveedor = @IdProveedor
END


