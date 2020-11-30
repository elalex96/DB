
-- sp_IN_AL_ActualizarMaterialDisponible 1,0
create Proc [dbo].[sp_IN_AL_ActualizarMaterialDisponible]
@pIdAlmacen int,
@pIdMovimiento int
as

	--Obtener los movimientos de recepción que ha afectado el movimeinto de entrada
	select rec.IdMovimiento
	into #tmpMovsRecepcion
	from IN_AL_Movimiento m
	inner join IN_AL_MovimientoDetalle md on md.IdMovimiento = m.IdMovimiento
	inner join [IN_AL_EntregaRecepcion] rel on rel.IdMovimientoDetEntrega = md.IdMovimientoDetalle
	inner join IN_AL_MovimientoDetalle rec on rec.IdMovimientoDetalle = rel.IdMovimientoDetRecepcion
	inner join IN_AL_Movimiento mrec on mrec.idmovimiento = rec.IdMovimiento
	where m.IdMovimiento = @pIdMovimiento	and
	m.IsEliminado = 0 and
	mrec.IsEliminado = 0



	if exists(
		select 1
		from #tmpMovsRecepcion
	)
	begin
	

		--Actualizar las cantidades disponibles de cada movimiento
		update IN_AL_MovimientoDetalle
		set Disponible = isnull(Cantidad,0) - (
													select isnull(sum(CantidadRecepcionDesc) ,0)
													from [IN_AL_EntregaRecepcion] st1 
													where st1.IdMovimientoDetRecepcion = md.idMovimientoDetalle and
													st1.IsEliminado=0
												)
		from IN_AL_MovimientoDetalle md
		inner join IN_AL_Movimiento m on m.IdMovimiento = md.IdMovimiento
		inner join #tmpMovsRecepcion tmp on tmp.IdMovimiento = md.IdMovimiento
		where m.IdTipoMovimiento = 1--Recepciones
		and m.IsEliminado = 0
	
	end

	Else
	Begin
		--Actualizar las cantidades disponibles de cada movimiento
		update IN_AL_MovimientoDetalle
		set Disponible = isnull(Cantidad,0) - (
													select isnull(sum(CantidadRecepcionDesc) ,0)
													from [IN_AL_EntregaRecepcion] st1 
													where st1.IdMovimientoDetRecepcion = md.idMovimientoDetalle and
													st1.IsEliminado=0
												)
		from IN_AL_MovimientoDetalle md
		inner join IN_AL_Movimiento m on m.IdMovimiento = md.IdMovimiento
		--inner join #tmpMovsRecepcion tmp on tmp.IdMovimiento = md.IdMovimiento
		where m.IdTipoMovimiento = 1--Recepciones
		and m.IdAlmacen = @pIdAlmacen
		and m.IsEliminado = 0
	End

	
