
-- sp_IN_AL_ActualizarPrecioMovimiento 13
create proc [dbo].[sp_IN_AL_ActualizarPrecioMovimiento]
@pIdMovimiento int
As

	DECLARE @IdTipoMovimiento int,
		@precioTotal decimal(14,2)

	select @IdTipoMovimiento = IdTipoMovimiento
	from IN_AL_Movimiento
	where IdMovimiento = @pIdMovimiento


	/*******SI ES RECEPCIÓN DE ALMACEN****************/
	if @IdTipoMovimiento = 1
	begin

		select @precioTotal = isnull(SUM(isnull(md.Cantidad,0) * isnull(pd.PrecioUnitario,0)),0)
		from IN_AL_MovimientoDetalle md
		inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = md.IdPedidoDetalle
		where md.IdMovimiento = @pIdMovimiento

		begin tran

		update IN_AL_Movimiento
		set PrecioTotal = @precioTotal
		where IdMovimiento = @pIdMovimiento

		if @@error <> 0
		begin

			rollback tran
			goto fin
		end

		update IN_AL_MovimientoDetalle
		set PrecioTotal = isnull(isnull(md.Cantidad,0) * isnull(pd.PrecioUnitario,0),0)
		from IN_AL_MovimientoDetalle md
		inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = md.IdPedidoDetalle
		where md.IdMovimiento = @pIdMovimiento

		
		if @@error <> 0
		begin

			rollback tran
			goto fin
		end

		commit tran


	end


	/*********SI ES ENTREGA DE ALMACEN****************/
	if @IdTipoMovimiento = 2 
	begin

		select @precioTotal = isnull(SUM(isnull(rel.CantidadRecepcionDesc,0) * isnull(pd.PrecioUnitario,0)),0)
		from IN_AL_MovimientoDetalle md
		inner join IN_AL_EntregaRecepcion rel on rel.IdMovimientoDetEntrega = md.IdMovimientoDetalle
		inner join IN_AL_MovimientoDetalle rec on rec.IdMovimientoDetalle = rel.IdMovimientoDetRecepcion
		inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = md.IdPedidoDetalle
		where md.IdMovimiento = @pIdMovimiento


		begin tran

		update IN_AL_Movimiento
		set PrecioTotal = @precioTotal
		where IdMovimiento = @pIdMovimiento

		if @@error <> 0
		begin

			rollback tran
			goto fin
		end

		update IN_AL_MovimientoDetalle
		set PrecioTotal = (
							SELECT isnull(SUM(isnull(rel.CantidadRecepcionDesc,0) * isnull(pd.PrecioUnitario,0)),0)
							from IN_AL_MovimientoDetalle md
							inner join IN_AL_EntregaRecepcion rel on rel.IdMovimientoDetEntrega = md.IdMovimientoDetalle
							inner join IN_AL_MovimientoDetalle rec on rec.IdMovimientoDetalle = rel.IdMovimientoDetRecepcion
							inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = md.IdPedidoDetalle
							where md.IdMovimiento = @pIdMovimiento	 AND
							MD.IdMovimientoDetalle = 	t1.IdMovimientoDetalle
							)
		from IN_AL_MovimientoDetalle t1
		WHERE t1.IdMovimiento = @pIdMovimiento

		
		if @@error <> 0
		begin

			rollback tran
			goto fin
		end

		commit tran
		
	end


	/**********SI ES REINGRESO DE ALMACEN*****************/	
	if @IdTipoMovimiento = 3 
	begin

		select @precioTotal = isnull(SUM(isnull(rel.CantidadMovimiento,0) * isnull(pd.PrecioUnitario,0)),0)
		from IN_AL_MovimientoDetalle md
		inner join IN_AL_RecepcionReingreso rel on rel.IdMovimientoDetReingreso = md.IdMovimientoDetalle
		inner join IN_AL_MovimientoDetalle rec on rec.IdMovimientoDetalle = rel.IdMovimientoDetRecepcion
		inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = rec.IdPedidoDetalle
		where md.IdMovimiento = @pIdMovimiento


		begin tran

		update IN_AL_Movimiento
		set PrecioTotal = @precioTotal
		where IdMovimiento = @pIdMovimiento

		if @@error <> 0
		begin

			rollback tran
			goto fin
		end

		update IN_AL_MovimientoDetalle
		set PrecioTotal = (
							SELECT SUM(isnull(rel.CantidadMovimiento,0) * isnull(pd.PrecioUnitario,0))
							from IN_AL_MovimientoDetalle md
							inner join IN_AL_RecepcionReingreso rel on rel.IdMovimientoDetReingreso = md.IdMovimientoDetalle
							inner join IN_AL_MovimientoDetalle rec on rec.IdMovimientoDetalle = rel.IdMovimientoDetRecepcion
							inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = md.IdPedidoDetalle
							where md.IdMovimiento = @pIdMovimiento	 AND
							MD.IdMovimientoDetalle = 	t1.IdMovimientoDetalle
							)
		from IN_AL_MovimientoDetalle t1
		WHERE t1.IdMovimiento = @pIdMovimiento

		
		if @@error <> 0
		begin

			rollback tran
			goto fin
		end

		commit tran
		
	end





	fin:
