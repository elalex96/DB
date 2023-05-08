-- p_SC_PedidoLineaPresupuesto 1
CREATE Proc [dbo].[p_SC_PedidoLineaPresupuesto]
@pIdSubContrato int
as

	/***********SI TIENE PEDIDO ORIGEN**************/

	select sp.IdSolicitudPedido,
			lp.IdLineaPresupuesto,
			NombreInstalacion = isnull(i.NombreInstalacion,'SIN INSTALACIÓN ASIGNADA'),
			ac.NombreActividad,
			Tarea = tp.TareaPetrolera
	into #tmpResult
	from Petrovendor.dbo.MM_Pedido p
	inner join Petrovendor.dbo.MM_SolicitudPedido sp on sp.IdSolicitudPedido = p.IdSolicitudPedido
	inner join Petrovendor.dbo.MM_SolicitudPedidoDetalle spd on spd.IdSolicitudPedido = sp.IdSolicitudPedido	
	inner join Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto lp on lp.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
	inner join SC_Subcontrato sc on @pIdSubContrato in ( sc.idSubcontrato) and
								sc.IdPedido = p.IdPedido
	inner join [dbo].[CO_LineaPresupuestoMes] lpm on lpm.IdLineaPresupuestoMes = lp.IdLineaPresupuesto
	left join CO_Instalacion i on i.IdInstalacion = lpm.IdInstalacion	
	LEFT JOIN CO_ActividadCIEP ac on ac.IdActividad = lpm.IdActividad
	left join CO_TareaPetrolera  tp on tp.IdTareaPetrolera = lpm.IdTareaPetrolera
	group by sp.IdSolicitudPedido,
			lp.IdLineaPresupuesto,
			i.NombreInstalacion,
			ac.NombreActividad,
			tp.TareaPetrolera


	/***********SI NO TIENE PEDIDO ORIGEN**************/
	if not exists (
		select 1
		from #tmpResult
	)
	begin

		insert into #tmpResult
		select distinct IdSolicitudPedido = 0,
			IdLineaPresupuesto = lpm.IdLineaPresupuestoMes,
			NombreInstalacion = isnull(i.NombreInstalacion,'SIN INSTALACIÓN ASIGNADA'),
			ac.NombreActividad,
			Tarea = tp.TareaPetrolera
		from SC_Presupuesto p
		inner join [dbo].[CO_LineaPresupuestoMes] lpm on lpm.IdPresupuesto = p.IdPresupuesto
		left join CO_Instalacion i on i.IdInstalacion = lpm.IdInstalacion	
		LEFT JOIN CO_ActividadCIEP ac on ac.IdActividad = lpm.IdActividad
		left join CO_TareaPetrolera  tp on tp.IdTareaPetrolera = lpm.IdTareaPetrolera
		where IdSubcontrato = @pIdSubContrato
	end

	select * from #tmpResult

