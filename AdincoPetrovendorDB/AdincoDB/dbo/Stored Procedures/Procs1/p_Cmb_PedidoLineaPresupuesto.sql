-- p_Cmb_PedidoLineaPresupuesto 1176
Create Proc p_Cmb_PedidoLineaPresupuesto
@pIdPedido int
as

	select sp.IdSolicitudPedido,
			lp.IdLineaPresupuesto
	from Petrovendor.dbo.MM_Pedido p
	inner join Petrovendor.dbo.MM_SolicitudPedido sp on sp.IdSolicitudPedido = p.IdSolicitudPedido
	inner join Petrovendor.dbo.MM_SolicitudPedidoDetalle spd on spd.IdSolicitudPedido = sp.IdSolicitudPedido	
	inner join Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto lp on lp.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
	where p.IdPedido = @pIdPedido
	group by sp.IdSolicitudPedido,
			lp.IdLineaPresupuesto
