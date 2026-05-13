
Create Proc [dbo].[sp_IN_AL_AutorizarEntrega]
@pIdMovimiento int,
@pIdUsuario int,
@pCustomError varchar(250) out
as	


	declare @IdAlmacen int

	select @IdAlmacen=IdAlmacen
	from IN_AL_Movimiento
	where IdMovimiento = @pIdMovimiento



	
	/************VALIDACIONES******************/
	if not exists (
		select 1
		from IN_AL_movimientoDetalle 
		where IdMovimiento = @pIdMovimiento
	)
	begin 
		set @pCustomError = 'No es posible Autorizar un movimiento ID:'+cast(@pIdMovimiento as varchar)+' sin materiales'
		return
	end
	if  exists (
		select 1
		from IN_AL_movimiento
		where IdMovimiento = @pIdMovimiento and
		IdUsuarioAutorizo > 0
	)
	begin 
		set @pCustomError = 'El movimiento ya está autorizado'
		return
	end

	Begin Tran

	update IN_AL_Movimiento
	set IdUsuarioAutorizo = @pIdUsuario,
		FechaAutoriza = getdate()
	where IdMovimiento =@pIdMovimiento and
	IdTipoMovimiento = 2--Entrega

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end


	/****************Realizar ciclo para aplicar cada movimiento detalle*******************/
	declare	@cIdMovimientoDetalle int,			
			@cCustomError varchar(250)

	SELECT md.IdMovimientoDetalle,
		md.IdMovimiento,
		md.Cantidad,
		md.Disponible
	into #tmpMovsDetalle
	FROM IN_AL_MovimientoDetalle md
	inner join IN_AL_Movimiento m on m.IdMovimiento = md.IdMovimiento
	where m.IdMovimiento = @pIdMovimiento



	select @cIdMovimientoDetalle = min(IdMovimientoDetalle)
	from #tmpMovsDetalle

	while @cIdMovimientoDetalle is not null
	Begin


		exec sp_IN_AL_EntregaAplicarMovimiento @IdAlmacen,@pIdMovimiento,@cIdMovimientoDetalle,@pIdUsuario,@cCustomError out

		if isnull(@cCustomError,'') <> ''
		begin
			RAISERROR (@cCustomError,16,1)
		End

		if @@error <> 0
		begin
			rollback tran
			goto fin
		end

		select @cIdMovimientoDetalle = min(IdMovimientoDetalle)
		from #tmpMovsDetalle
		where IdMovimientoDetalle > @cIdMovimientoDetalle
		
	End


	--Actualizar las cantidades disponibles
	exec sp_IN_AL_ActualizarMaterialDisponible @IdAlmacen,@pIdMovimiento


	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	exec sp_IN_AL_ActualizarPrecioMovimiento @pIdMovimiento

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end


	commit tran


	fin:

	
