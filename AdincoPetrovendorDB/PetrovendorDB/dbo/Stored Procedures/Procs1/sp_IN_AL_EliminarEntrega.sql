
create Proc [dbo].[sp_IN_AL_EliminarEntrega]
@pIdAlmacen int,
@pIdMovimiento int
as

	begin tran


	update IN_AL_EntregaRecepcion
	set IsEliminado = 1
	from IN_AL_EntregaRecepcion t1
	inner join IN_AL_MovimientoDetalle det on det.IdMovimientoDetalle = t1.IdMovimientoDetEntrega
	inner join IN_AL_Movimiento m on m.IdMovimiento = det.IdMovimiento
	where det.IdMovimiento = @pIdMovimiento and
	m.IdAlmacen = @pIdAlmacen and
	m.IdTipoMovimiento = 2  --RECEPCION

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	--update IN_AL_MovimientoDetalle
	--set IsEliminado = 1
	--from IN_AL_MovimientoDetalle det
	--inner join IN_AL_Movimiento m on m.IdMovimiento = det.IdMovimiento
	--where det.IdMovimiento = @pIdMovimiento and
	--m.IdAlmacen = @pIdAlmacen and
	--m.IdTipoMovimiento = 2  --RECEPCION

	--if @@error <> 0
	--begin
	--	rollback tran
	--	goto fin
	--end

	update IN_AL_Movimiento
	set isEliminado = 1
	where IdMovimiento = @pIdMovimiento and
	IdAlmacen = @pidAlmacen and
	idTipoMovimiento = 2 --RECEPCION

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end
	--aCTUALIZAR Cantidades

	exec sp_IN_AL_ActualizarMaterialDisponible @pIdAlmacen,0


	if @@error <> 0
	begin
		rollback tran
		goto fin
	end


	commit tran

	fin:
