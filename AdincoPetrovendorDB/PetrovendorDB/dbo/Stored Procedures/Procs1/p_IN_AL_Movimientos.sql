
-- p_IN_AL_Movimientos 2,0,3
create proc p_IN_AL_Movimientos
@pIdAlmacen int,
@pIdMaterial int,
@pIdEstatus int -- 1. Libres, 2.Reserva , 0.Todos
as

	/**************TOTAL DISPONIBLE DE ALMACEN*******************/
	WITH tTotalesAlmacen(IdAlmacen,IdMaterial,DisponibleTotal,Reserva)
	as
	(
		select	m.IdAlmacen,
				IdMaterial=md.IdMaterial,
				Sum(isnull(md.Disponible,0)),
				Reserva = SUM(CantidadReserva)
		from 	IN_AL_MovimientoDetalle md 
		inner join IN_AL_Movimiento m on m.idMovimiento = md.idMovimiento
		left join MM_PedidoDetalle pd on pd.IdPedidoDetalle = md.IdPedidoDetalle
		left join IN_AL_ReservaDetalle res on res.[IdMovimientoDetRecepcion] = md.IdMovimientoDetalle
		where m.IsEliminado = 0 and
		m.IdUsuarioAutorizo > 0 and--solo autorizada
		m.IdTipoMovimiento in( 1,4) --Recepcion y Recepción sin Referencia
		and m.IdAlmacen = @pIdAlmacen 
		and @pIdMaterial in (0,md.IdMaterial)
		group by  m.IdAlmacen,md.IdMaterial
	)


	/**********RECEPCIONES******************/
	select m.IdMovimiento,
			m.IdAlmacen,
			Almacen = a.Nombre,
			m.IdPedido,
			m.Folio,
			m.IdTipoMovimiento,
			Tipo = tm.Nombre,
			m.FechaMovimiento,
			m.HoraMovimiento,
			m.RecibidoEn,
			m.EntregadoEn,
			m.EntregadoA,
			m.IdUsuarioAtendio,
			Atendio = uAtendio.Nombre,
			m.Comentarios,
			m.PrecioTotal,
			m.IdUsuarioAutorizo,
			Autorizo = uAutorizo.Nombre,
			m.FechaAutoriza,
			--DETALLE
			md.IdMovimientoDetalle,
			IdMaterial = pd.IdMaterial,
			MaterialDes=mat.DescripcionCorta,
			MaterialDesLarga=mat.DescripcionLarga,
			mat.IdUnidad,
			Unidad = isnull(u.Unidad,'SIN ESPECIFICAR'),
			pd.PrecioUnitario,
			md.Cantidad,
			PrecioMovimiento = md.PrecioTotal,
			md.Disponible,
			ExistenciaAlMov = md.Existencia,
			md.CostoPromedio,
			md.CostoUltimaCompra,
			IdMovimientoEntregaDetalle = null,
			DisponibleTotalAlmacen = isnull(tot.DisponibleTotal,0)/*-isnull(tot.Reserva,0) */,
			Reserva = isnull(tot.Reserva,0),
			TotalMaterial = isnull(tot.DisponibleTotal,0),
			IdSolicitudPedido = m.IdSolicitudPedido,
			EsReingresoSinRef = cast(0 as bit),
			Entrada = CASE WHEN TM.EsEntrada = 1 then md.Cantidad else 0 END,
			Salida = CASE WHEN TM.EsSalida = 1 then md.Cantidad else 0 END
	from IN_AL_Movimiento m
	inner join IN_Almacen a on a.IdAlmacen = m.IdAlmacen
	inner join IN_AL_MovimientoDetalle md on md.IdMovimiento = m.IdMovimiento
	inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = md.idPedidoDetalle
	inner join MM_Material mat on mat.IdMaterial = pd.IdMaterial
	left join [PV_MM_MaterialUnidad] u on u.IdUnidad = mat.IdUnidad
	inner join IN_AL_TipoMovimiento tm on tm.IdTipoMovimiento = m.IdTipoMovimiento
	left join tTotalesAlmacen tot on tot.IdMaterial = pd.IdMaterial
	inner join S_Usuario uAtendio on uAtendio.IdUsuario = m.IdUsuarioAtendio
	left join S_Usuario uAutorizo on uAutorizo.IdUsuario = m.IdUsuarioAutorizo
	where m.IsEliminado = 0 and
	m.IdTipoMovimiento = 1
	and m.IdAlmacen = @pIdAlmacen 
	and @pIdMaterial in (0,md.IdMaterial)
	AND (
		(IdUsuarioAutorizo > 0 and @pIdEstatus = 0)
		OR
		(@pIdEstatus = 1 and m.IdTipoMovimiento <> 5  AND IdUsuarioAutorizo > 0)
		OR
		(@pIdEstatus = 2 and IdUsuarioAutorizo > 0  AND m.IdTipoMovimiento = 5)
	)

	/**********ENTREGAS******************/
	union 
	select m.IdMovimiento,
			m.IdAlmacen,
			Almacen = a.Nombre,
			m.IdPedido,
			m.Folio,
			m.IdTipoMovimiento,
			Tipo = tm.Nombre,
			m.FechaMovimiento,
			m.HoraMovimiento,
			m.RecibidoEn,
			m.EntregadoEn,
			m.EntregadoA,
			m.IdUsuarioAtendio,
			Atendio = uAtendio.Nombre,
			m.Comentarios,
			m.PrecioTotal,
			m.IdUsuarioAutorizo,
			Autorizo = uAutorizo.Nombre,
			m.FechaAutoriza,
			--DETALLE
			md.IdMovimientoDetalle,
			IdMaterial = pd.IdMaterial,
			MaterialDes=mat.DescripcionCorta,
			MaterialDesLarga=mat.DescripcionLarga,
			mat.IdUnidad,
			Unidad = isnull(u.Unidad,'SIN ESPECIFICAR'),
			pd.PrecioUnitario,
			md.Cantidad,
			PrecioMovimiento = md.PrecioTotal,
			Disponible = null,
			ExistenciaAlMov = md.Existencia,
			md.CostoPromedio,
			md.CostoUltimaCompra,
			IdMovimientoEntregaDetalle = null,
			DisponibleTotalAlmacen = isnull(tot.DisponibleTotal,0)/*-isnull(tot.Reserva,0) */,
			Reserva = isnull(tot.Reserva,0),
			TotalMaterial = isnull(tot.DisponibleTotal,0),
			IdSolicitudPedido = m.IdSolicitudPedido,
			EsReingresoSinRef = cast(0 as bit),
			Entrada = CASE WHEN TM.EsEntrada = 1 then md.Cantidad else 0 END,
			Salida = CASE WHEN TM.EsSalida = 1 then md.Cantidad else 0 END
	from IN_AL_Movimiento m
	inner join IN_Almacen a on a.IdAlmacen = m.IdAlmacen
	inner join IN_AL_MovimientoDetalle md on md.IdMovimiento = m.IdMovimiento
	inner join IN_AL_EntregaRecepcion rel on rel.IdMovimientoDetEntrega = md.IdMovimientoDetalle
	inner join IN_AL_MovimientoDetalle rec on rec.IdMovimientoDetalle = rel.IdMovimientoDetRecepcion
	inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = rec.idPedidoDetalle
	inner join MM_Material mat on mat.IdMaterial = pd.IdMaterial
	left join [PV_MM_MaterialUnidad] u on u.IdUnidad = mat.IdUnidad
	inner join IN_AL_TipoMovimiento tm on tm.IdTipoMovimiento = m.IdTipoMovimiento
	left join tTotalesAlmacen tot on tot.IdMaterial = pd.IdMaterial
	inner join S_Usuario uAtendio on uAtendio.IdUsuario = m.IdUsuarioAtendio
	left join S_Usuario uAutorizo on uAutorizo.IdUsuario = m.IdUsuarioAutorizo
	where m.IsEliminado = 0 and
	m.IdTipoMovimiento = 2 --ENTREGA
	and m.IdAlmacen = @pIdAlmacen 
		and @pIdMaterial in (0,md.IdMaterial)
		AND (
		(IdUsuarioAutorizo > 0 and @pIdEstatus = 0)
		OR
		(@pIdEstatus = 1 and m.IdTipoMovimiento <> 5  AND IdUsuarioAutorizo > 0)
		OR
		(@pIdEstatus = 2 and IdUsuarioAutorizo > 0  AND m.IdTipoMovimiento = 5)
	)


	/**********REINGRESOS******************/
	union 
	select m.IdMovimiento,
			m.IdAlmacen,
			Almacen = a.Nombre,
			m.IdPedido,
			m.Folio,
			m.IdTipoMovimiento,
			Tipo = tm.Nombre,
			m.FechaMovimiento,
			m.HoraMovimiento,
			m.RecibidoEn,
			m.EntregadoEn,
			m.EntregadoA,
			m.IdUsuarioAtendio,
			Atendio = uAtendio.Nombre,
			m.Comentarios,
			m.PrecioTotal,
			m.IdUsuarioAutorizo,
			Autorizo = uAutorizo.Nombre,
			m.FechaAutoriza,
			--DETALLE
			md.IdMovimientoDetalle,
			IdMaterial = pd.IdMaterial,
			MaterialDes=mat.DescripcionCorta,
			MaterialDesLarga=mat.DescripcionLarga,
			mat.IdUnidad,
			Unidad = isnull(u.Unidad,'SIN ESPECIFICAR'),
			pd.PrecioUnitario,
			md.Cantidad,
			PrecioMovimiento = md.PrecioTotal,
			Disponible = null,
			ExistenciaAlMov = md.Existencia,
			md.CostoPromedio,
			md.CostoUltimaCompra,
			IdMovimientoEntregaDetalle = isnull(rel.IdMovimientoDetEntrega,-1),
			DisponibleTotalAlmacen = isnull(tot.DisponibleTotal,0)/*-isnull(tot.Reserva,0) */,
			Reserva = isnull(tot.Reserva,0),
			TotalMaterial = isnull(tot.DisponibleTotal,0),
			IdSolicitudPedido = m.IdSolicitudPedido,
			EsReingresoSinRef = cast(0 as bit),
			Entrada = CASE WHEN TM.EsEntrada = 1 then md.Cantidad else 0 END,
			Salida = CASE WHEN TM.EsSalida = 1 then md.Cantidad else 0 END
	from IN_AL_Movimiento m
	inner join IN_Almacen a on a.IdAlmacen = m.IdAlmacen
	inner join IN_AL_MovimientoDetalle md on md.IdMovimiento = m.IdMovimiento
	inner join IN_AL_RecepcionReingreso rel on rel.IdMovimientoDetReingreso = md.IdMovimientoDetalle
	inner join IN_AL_MovimientoDetalle rec on rec.IdMovimientoDetalle = rel.IdMovimientoDetRecepcion
	inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = rec.idPedidoDetalle
	inner join MM_Material mat on mat.IdMaterial = pd.IdMaterial
	left join [PV_MM_MaterialUnidad] u on u.IdUnidad = mat.IdUnidad
	inner join S_Usuario uAtendio on uAtendio.IdUsuario = m.IdUsuarioAtendio	
	inner join IN_AL_TipoMovimiento tm on tm.IdTipoMovimiento = m.IdTipoMovimiento
	left join tTotalesAlmacen tot on tot.IdMaterial = pd.IdMaterial	
	left join S_Usuario uAutorizo on uAutorizo.IdUsuario = m.IdUsuarioAutorizo
	where m.IsEliminado = 0 and
	m.IdTipoMovimiento = 3 --ENTREGA
	and m.IdAlmacen = @pIdAlmacen 
		and @pIdMaterial in (0,md.IdMaterial)
		AND (
		(IdUsuarioAutorizo > 0 and @pIdEstatus = 0)
		OR
		(@pIdEstatus = 1 and m.IdTipoMovimiento <> 5  AND IdUsuarioAutorizo > 0)
		OR
		(@pIdEstatus = 2 and IdUsuarioAutorizo > 0  AND m.IdTipoMovimiento = 5)
	)


	/**********REINGRESOS SIN REFERENCIA******************/
	union 
	select m.IdMovimiento,
			m.IdAlmacen,
			Almacen = a.Nombre,
			m.IdPedido,
			m.Folio,
			m.IdTipoMovimiento,
			Tipo = tm.Nombre,
			m.FechaMovimiento,
			m.HoraMovimiento,
			m.RecibidoEn,
			m.EntregadoEn,
			m.EntregadoA,
			m.IdUsuarioAtendio,
			Atendio = uAtendio.Nombre,
			m.Comentarios,
			m.PrecioTotal,
			m.IdUsuarioAutorizo,
			Autorizo = uAutorizo.Nombre,
			m.FechaAutoriza,
			--DETALLE
			md.IdMovimientoDetalle,
			IdMaterial = rec.IdMaterial,
			MaterialDes=mat.DescripcionCorta,
			MaterialDesLarga=mat.DescripcionLarga,
			mat.IdUnidad,
			Unidad = isnull(u.Unidad,'SIN ESPECIFICAR'),
			PrecioUnitario = 0,
			md.Cantidad,
			PrecioMovimiento = md.PrecioTotal,
			Disponible = null,
			ExistenciaAlMov = md.Existencia,
			md.CostoPromedio,
			md.CostoUltimaCompra,
			IdMovimientoEntregaDetalle = isnull(rel.IdMovimientoDetEntrega,-1),
			DisponibleTotalAlmacen = isnull(tot.DisponibleTotal,0)/*-isnull(tot.Reserva,0) */,
			Reserva = isnull(tot.Reserva,0),
			TotalMaterial = isnull(tot.DisponibleTotal,0),
			IdSolicitudPedido = m.IdSolicitudPedido,
			EsReingresoSinRef = cast(1 as bit),
			Entrada = CASE WHEN TM.EsEntrada = 1 then md.Cantidad else 0 END,
			Salida = CASE WHEN TM.EsSalida = 1 then md.Cantidad else 0 END
	from IN_AL_Movimiento m
	inner join IN_Almacen a on a.IdAlmacen = m.IdAlmacen
	inner join IN_AL_MovimientoDetalle md on md.IdMovimiento = m.IdMovimiento
	inner join IN_AL_RecepcionReingreso rel on rel.IdMovimientoDetReingreso = md.IdMovimientoDetalle and rel.IdMovimientoDetEntrega is null
	inner join IN_AL_MovimientoDetalle rec on rec.IdMovimientoDetalle = rel.IdMovimientoDetRecepcion 
	INNER JOIN IN_AL_Movimiento mov2 on mov2.IdMovimiento = rec.IdMovimiento													 
	--inner join IN_AL_Movimiento movSinRef on movSinRef.IdPedido is null 					
												
	--inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = rec.idPedidoDetalle
	inner join MM_Material mat on mat.IdMaterial = md.IdMaterial
	left join [PV_MM_MaterialUnidad] u on u.IdUnidad = mat.IdUnidad
	inner join S_Usuario uAtendio on uAtendio.IdUsuario = m.IdUsuarioAtendio
	
	inner join IN_AL_TipoMovimiento tm on tm.IdTipoMovimiento = m.IdTipoMovimiento
	left join tTotalesAlmacen tot on tot.IdMaterial =rec.idMaterial
	left join S_Usuario uAutorizo on uAutorizo.IdUsuario = m.IdUsuarioAutorizo
	where m.IsEliminado = 0 and
	mov2.IdTipoMovimiento = 4 --ENTREGA
	and m.IdAlmacen = @pIdAlmacen 
		and @pIdMaterial in (0,md.IdMaterial)
		AND (
		(m.IdUsuarioAutorizo > 0 and @pIdEstatus = 0)
		OR
		(@pIdEstatus = 1 and m.IdTipoMovimiento <> 5  AND m.IdUsuarioAutorizo > 0)
		OR
		(@pIdEstatus = 2 and m.IdUsuarioAutorizo > 0  AND m.IdTipoMovimiento = 5)
	)


	union

	/**********RESERVAS******************/
	
	select m.IdMovimiento,
			m.IdAlmacen,
			Almacen = a.Nombre,
			m.IdPedido,
			m.Folio,
			m.IdTipoMovimiento,
			Tipo = tm.Nombre,
			m.FechaMovimiento,
			m.HoraMovimiento,
			m.RecibidoEn,
			m.EntregadoEn,
			m.EntregadoA,
			m.IdUsuarioAtendio,
			Atendio = uAtendio.Nombre,
			m.Comentarios,
			m.PrecioTotal,
			m.IdUsuarioAutorizo,
			Autorizo = uAutorizo.Nombre,
			m.FechaAutoriza,
			--DETALLE
			md.IdMovimientoDetalle,
			IdMaterial = MD.IdMaterial,
			MaterialDes=mat.DescripcionCorta,
			MaterialDesLarga=mat.DescripcionLarga,
			mat.IdUnidad,
			Unidad = isnull(u.Unidad,'SIN ESPECIFICAR'),
			PrecioUnitario = 0,
			md.Cantidad,
			PrecioMovimiento = md.PrecioTotal,
			Disponible = null,
			ExistenciaAlMov = md.Existencia,
			md.CostoPromedio,
			md.CostoUltimaCompra,
			IdMovimientoEntregaDetalle =NULL,
			DisponibleTotalAlmacen = isnull(tot.DisponibleTotal,0)/*-isnull(tot.Reserva,0) */,
			Reserva = isnull(tot.Reserva,0),
			TotalMaterial = isnull(tot.DisponibleTotal,0),
			IdSolicitudPedido = m.IdSolicitudPedido,
			EsReingresoSinRef = cast(0 as bit),
			Entrada = CASE WHEN TM.EsEntrada = 1 then md.Cantidad else 0 END,
			Salida = CASE WHEN TM.EsSalida = 1 then md.Cantidad else 0 END
	from IN_AL_Movimiento m
	inner join IN_Almacen a on a.IdAlmacen = m.IdAlmacen
	inner join IN_AL_MovimientoDetalle md on md.IdMovimiento = m.IdMovimiento
	--inner join IN_AL_RecepcionReingreso rel on rel.IdMovimientoDetReingreso = md.IdMovimientoDetalle
	--inner join IN_AL_MovimientoDetalle rec on rec.IdMovimientoDetalle = rel.IdMovimientoDetRecepcion 
	inner join IN_AL_Movimiento movSinRef on movSinRef.IdPedido is null 					
												
	--inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = rec.idPedidoDetalle
	inner join MM_Material mat on mat.IdMaterial = md.IdMaterial
	left join [PV_MM_MaterialUnidad] u on u.IdUnidad = mat.IdUnidad
	inner join S_Usuario uAtendio on uAtendio.IdUsuario = m.IdUsuarioAtendio
	
	inner join IN_AL_TipoMovimiento tm on tm.IdTipoMovimiento = m.IdTipoMovimiento
	left join tTotalesAlmacen tot on tot.IdMaterial =md.idMaterial
	left join S_Usuario uAutorizo on uAutorizo.IdUsuario = m.IdUsuarioAutorizo
	where m.IsEliminado = 0 and
	m.IdTipoMovimiento = 5 --reserva
	and m.IdAlmacen = @pIdAlmacen 
		and @pIdMaterial in (0,md.IdMaterial)
		AND (
		(m.IdUsuarioAutorizo > 0 and @pIdEstatus = 0)
		OR
		(@pIdEstatus = 1 and m.IdTipoMovimiento <> 5  AND m.IdUsuarioAutorizo > 0)
		OR
		(@pIdEstatus = 2 and m.IdUsuarioAutorizo > 0  AND m.IdTipoMovimiento = 5)
	)
	order by FechaAutoriza desc


