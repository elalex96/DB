
create Proc [dbo].[sp_IN_AL_EliminarRecepcion]
@pIdAlmacen int,
@pIdMovimiento int
as

	begin tran

	delete IN_AL_MovimientoDetalleDoc
	from IN_AL_MovimientoDetalleDoc f
	inner join IN_AL_MovimientoDetalle d on d.IdMovimientoDetalle = f.IdMovimientoDetalle
	where d.IdMovimiento = @pIdMovimiento

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	delete IN_AL_MovimientoDetalle
	where IdMovimiento = @pIdMovimiento

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	delete IN_AL_Movimiento
	where IdMovimiento = @pIdMovimiento and
	IdAlmacen = @pidAlmacen and
	idTipoMovimiento = 1 --RECEPCION

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end


	commit tran

	fin:
