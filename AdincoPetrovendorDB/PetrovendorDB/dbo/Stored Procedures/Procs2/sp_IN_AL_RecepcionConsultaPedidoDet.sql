
-- sp_IN_AL_RecepcionConsultaPedidoDet 1,1148,1
CREATE Proc sp_IN_AL_RecepcionConsultaPedidoDet
@pIdAlmacen int,
@pIdPedido int,
@pIdMovimiento int
As

	
	select pd.IdPedido,IdMaterial =pd.IdMaterial,CantidadRecibida = Sum(md.Cantidad)
	into #tmpRecepcionesAnt
	from IN_AL_MovimientoDetalle md
	inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = md.IdPedidoDetalle
	inner join IN_AL_Movimiento m on m.IdMovimiento = md.IdMovimiento
	where pd.IdPedido = @pIdPedido AND
	m.IsEliminado = 0 AND
	m.IdUsuarioAutorizo > 0
	group by  pd.IdPedido,pd.IdMaterial


	--select * from #tmpRecepcionesAnt

	select 
		ROW_NUMBER() OVER(ORDER BY p.IdPedido ASC) AS ID_ROW,
		IdMovimientoDetalle = isnull(md.IdMovimientoDetalle,0),
		p.IdPedido,
		pd.IdPedidoDetalle,		
		IdMaterial = m.IdMaestro,
		DescripcionCorta = m.DescripcionCorta,
		Unidad = isnull(u.Unidad,'SIN ESPECIFICAR'),
		pd.IdPeticionOfertaDetalle,
		Posicion = isnull(pd.Posicion,0),
		pd.PrecioUnitario,
		CantidadTotalPedido=isnull(pd.Cantidad,0) ,		
		CantidadFaltanteRecibir= case when (isnull(pd.Cantidad,0) - isnull(recAnt.CantidadRecibida,0)) <0 then 0 else  (isnull(pd.Cantidad,0) - isnull(recAnt.CantidadRecibida,0)) end,		
		CantidadRecepcion = isnull(md.cantidad,0),
		PrecioTotalRecepcion = isnull(PrecioTotal,0),
		pd.PorcentajeIVA,
		pd.Subtotal,
		pd.Activo,
		pd.ComentariosCompras,
		pd.Entregado,
		pd.AceptacionServicio,
		pd.RecepcionPedido,
		pd.FechaAceptacionServicio,
		pd.IdUsuarioAceptacionServicio,
		pd.FechaRecepcionPedido,
		pd.IdUsuarioRecepcionServicio,
		pd.ComentarioAceptacionServicio,
		pd.PorcentajeContenidoNacional,
		pd.PorcentajeContenidoExtranjero,
		pd.IsBienServicioNacional,		
		pd.IdMoneda,
		pd.IdMaterial,
		Files = '', --Columna tonta para poder usar el GetEditor de JavaScript,
		PermitirCapturaDeci= cast(0 as bit) --Falta definir como obtener este valor


	from MM_Pedido p
	inner join MM_PedidoDetalle pd on pd.idPedido = p.idPedido
	inner join MM_Material m on m.IdMaterial = pd.IdMaterial
	left join [PV_MM_MaterialUnidad] u on u.IdUnidad = m.IdUnidad
	left join #tmpRecepcionesAnt recAnt on recAnt.IdMaterial =  pd.IdMaterial
	left join IN_AL_MovimientoDetalle md on md.IdMovimiento = @pIdMovimiento and
									md.IdPedidoDetalle = pd.IdPedidoDetalle
	where p.IdPedido = @pIdPedido
	order by p.IdPedido,pd.Posicion


