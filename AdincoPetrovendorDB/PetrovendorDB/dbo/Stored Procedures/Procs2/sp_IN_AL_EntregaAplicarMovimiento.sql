

create Proc [dbo].[sp_IN_AL_EntregaAplicarMovimiento]
@pIdAlmacen int,
@pIdMovimiento int,
@pIdMovimientoDetalle int,
@pCreadoPor int,
@pCustomError varchar(250) out
as


	
	declare @NoItem int,
			@IdMovimientoDetEntrega int,
			@IdAlmacen int,
			@pCantidad decimal(14,2),
			@CantidadProcesoRE decimal(14,2),
			@pIdMaterial int


			

	create table #tmpMovimientosRecepcion
	(
		IdMovimientoDetalle int,
		CantidadUtilizada decimal(14,2)
	)

	select @pCantidad = Cantidad,
		@CantidadProcesoRE = Cantidad,
		@pIdMaterial = IdMaterial
	from IN_AL_MovimientoDetalle
	where IdMovimientoDetalle = @pIdMovimientoDetalle

	begin tran


	--Eliminar todo lo relacionado al movimiento de entrega
	delete [IN_AL_EntregaRecepcion]
	where IdMovimientoDetEntrega = @pIdMovimientoDetalle

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	update IN_AL_MovimientoDetalle
	set Disponible = isnull(Cantidad,0) - (
													select isnull(sum(CantidadRecepcionDesc) ,0)
													from [IN_AL_EntregaRecepcion] st1 
													where st1.IdMovimientoDetRecepcion = md.idMovimientoDetalle and
													IsEliminado = 0
												)
	from IN_AL_MovimientoDetalle md
	inner join IN_AL_Movimiento m on m.IdMovimiento = md.IdMovimiento
	--inner join #tmpMovsRecepcion tmp on tmp.IdMovimiento = md.IdMovimiento
	where m.IdTipoMovimiento = 1--Recepciones
	and m.IdAlmacen = @IdAlmacen and
	m.isEliminado = 0


	if @@error <> 0
	begin
		rollback tran
		goto fin
	end


	--Obtener los movimientos de recepción que se utilizarán
	insert into #tmpMovimientosRecepcion(IdMovimientoDetalle,CantidadUtilizada)
	exec sp_IN_AL_ObtenerRecepcionesParaEntrega @IdAlmacen,@pIdMaterial,@CantidadProcesoRE out

	if @CantidadProcesoRE > 0 
	begin
		set @pCustomError = 'No es posible registrar la entrega ya que no hay material suficiente disponible en el almacén'
		rollback tran
		--RAISERROR ('No es posible registrar la entrega ya que no hay material suficiente disponible en el almacén',16,1)
		goto fin
	end


	--Por cada movimiento de entrega, registrar los movimientos de recepción afectados
	Insert Into [dbo].[IN_AL_EntregaRecepcion](IdMovimientoDetEntrega,IdMovimientoDetRecepcion,CantidadRecepcionDesc,CreadoPor,CreadoEl)
	select @pIdMovimientoDetalle,IdMovimientoDetalle,CantidadUtilizada,@pCreadoPor,getdate()
	from #tmpMovimientosRecepcion

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	
	 

	commit tran

	fin:

	

	
