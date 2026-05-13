Create Proc [dbo].[sp_IN_AL_EliminarReingresoDetalle]
@pIdMovimientoDetalle int
as

	begin tran

	--Eliminar la relación de los movimientos de reingreso

	delete [dbo].[IN_AL_RecepcionReingreso]
	where IdMovimientoDetReingreso = @pIdMovimientoDetalle

	
	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	delete IN_AL_MovimientoDetalle
	where IdMovimientoDetalle = @pIdMovimientoDetalle

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	commit tran

	fin:


	
