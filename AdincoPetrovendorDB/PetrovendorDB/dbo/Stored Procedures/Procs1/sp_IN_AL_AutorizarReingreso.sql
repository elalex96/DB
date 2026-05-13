
CREATE Proc [dbo].[sp_IN_AL_AutorizarReingreso]
@pIdAlmacen int,
@pIdMovimiento int,
@pCreadoPor int,
@pCustomError varchar(250) out
as


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
	set IdUsuarioAutorizo = @pCreadoPor,
		FechaAutoriza = getdate()
	from IN_AL_Movimiento
	where IdMovimiento = @pIdMovimiento and
	IdAlmacen = @pIdAlmacen and
	idTipoMovimiento = 3 --RTeingreso

	if @@ERROR <> 0
	Begin
		rollback tran
		goto fin
	End

	/**********Aplicar movimientos de reingreso***********************/
	SELECT movs.IdMovimientoDetRecepcion,movs.CantidadMovimiento
	into #tmpAplicar
	FROM [IN_AL_RecepcionReingreso] movs
	inner join IN_AL_MovimientoDetalle rd on rd.idMovimientoDetalle = movs.IdMovimientoDetReingreso
	inner join IN_AL_Movimiento m on m.idMovimiento = rd.idMovimiento
	where m.IdMovimiento = @pIdMovimiento and
	m.IdAlmacen = @pIdAlmacen and
	m.IdUsuarioAutorizo > 0 and
	idTipoMovimiento = 3 --Reingreso


	if @@ERROR <> 0
	Begin
		rollback tran
		goto fin
	End

	update IN_AL_MovimientoDetalle
	set Disponible = isnull(t1.Disponible,0) + isnull(t2.CantidadMovimiento,0)
	from IN_AL_MovimientoDetalle t1
	inner join #tmpAplicar t2 on t2.IdMovimientoDetRecepcion = t1.IdMovimientoDetalle
	where t2.CantidadMovimiento > 0


	if @@ERROR <> 0
	Begin
		rollback tran
		goto fin
	End

	exec sp_IN_AL_ActualizarPrecioMovimiento @pIdMovimiento

	if @@ERROR <> 0
	Begin
		rollback tran
		goto fin
	End

	commit tran


	fin:

	