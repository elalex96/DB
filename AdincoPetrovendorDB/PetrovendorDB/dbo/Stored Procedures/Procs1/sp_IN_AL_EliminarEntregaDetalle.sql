

-- sp_IN_AL_EliminarEntregaDetalle 2,12
Create Proc [dbo].[sp_IN_AL_EliminarEntregaDetalle]
@pIdAlmacen int,
@pIdMovimientoDetalle int
as


	declare @IdMovimiento int

	select @IdMovimiento = IdMovimiento
	from IN_AL_MovimientoDetalle 
	where IdMovimientoDetalle= @pIdMovimientoDetalle


	begin tran

	delete IN_AL_EntregaRecepcion
	where IdMovimientoDetEntrega = @pIdMovimientoDetalle

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

	--exec sp_IN_AL_ActualizarMaterialDisponible @pIdAlmacen,0


	--if @@error <> 0
	--begin
	--	rollback tran
	--	goto fin
	--end

	--exec sp_IN_AL_ActualizarPrecioMovimiento @IdMovimiento

	--if @@error <> 0
	--begin
	--	rollback tran
	--	goto fin
	--end

	commit tran

	fin:

	
