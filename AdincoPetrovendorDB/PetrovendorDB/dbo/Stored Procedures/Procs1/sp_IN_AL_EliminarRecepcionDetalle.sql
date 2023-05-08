
Create Proc [dbo].[sp_IN_AL_EliminarRecepcionDetalle]
@pIdMovimiento int,
@pIdMovimientoDetalle int,
@pModificadoPor int
As

	begin tran 
	
	delete IN_AL_MovimientoDetalleDoc
	from IN_AL_MovimientoDetalleDoc t1
	inner join IN_AL_MovimientoDetalle t2 on t2.IdMovimientoDetalle = t1.IdMovimientoDetalle
	inner join IN_AL_Movimiento mov on mov.IdMovimiento = t2.IdMovimiento
	where t2.IdMovimientoDetalle = @pIdMovimientoDetalle and
	t2.IdMovimiento = @pIdMovimiento and
	mov.IdTipoMovimiento = 1

	if @@error <> 0
	begin
		rollback tran
		goto fin		
	end

	delete IN_AL_MovimientoDetalle
	from IN_AL_MovimientoDetalle t1	
	inner join IN_AL_Movimiento mov on mov.IdMovimiento = t1.IdMovimiento
	where t1.IdMovimientoDetalle = @pIdMovimientoDetalle and
	t1.IdMovimiento = @pIdMovimiento  and
	mov.IdTipoMovimiento = 1

	if @@error <> 0
	begin
		rollback tran
		goto fin		
	end


	commit tran
	fin:
