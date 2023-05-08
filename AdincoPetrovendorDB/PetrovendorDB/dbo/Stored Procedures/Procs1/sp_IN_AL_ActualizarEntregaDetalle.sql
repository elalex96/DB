

create Proc [dbo].[sp_IN_AL_ActualizarEntregaDetalle]
@pIdMovimiento int,
@pIdMovimientoDetalle int out,
@pIdMaterial int,
@pIdPedidoDetalle int out,		
@pCantidad decimal(14,2),					
@pDisponible decimal(14,2) out,			
@pCreadoPor int,
@pCustomError varchar(250) out
as 

	declare @NoItem int,
			@IdMovimientoDetEntrega int,
			@IdAlmacen int,
			@CantidadProcesoRE decimal(14,2) = @pCantidad
			

	create table #tmpMovimientosRecepcion
	(
		IdMovimientoDetalle int,
		CantidadUtilizada decimal(14,2)
	)


	/************REALIZAR VALIDACIONES*******************/
	select @pCustomError = dbo.fn_IN_AL_ValidarEntrega(@pIdMovimiento,@pIdMovimientoDetalle,@pIdMaterial,@pCantidad)

	if(@pCustomError<> '')
		goto fin


	select @IdAlmacen = IdAlmacen
	from IN_AL_Movimiento
	where IdMovimiento = @pIdMovimiento



	begin tran


	--Eliminar todo lo relacionado al movimiento de entrega
	delete [IN_AL_EntregaRecepcion]
	where IdMovimientoDetEntrega = @pIdMovimientoDetalle

	if @@error <> 0
	begin
		rollback tran 
		goto fin
	end


	--Actualizar las cantidades disponibles	
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

	
	if @@error <> 0
	begin
		rollback tran 
		goto fin
	end
	
	
	if @CantidadProcesoRE > 0 
	begin
		
		set @pCustomError = '**********No es posible registrar la entrega ya que no hay material suficiente disponible en el almacén*********'
		RAISERROR (@pCustomError,16,1)		

		rollback tran 
		goto fin

				
	end

	
	

	update IN_AL_MovimientoDetalle
	set Cantidad = @pCantidad,
		ModificadoPor = @pCreadoPor,
		ModificadoEl = getdate(),
		IdMaterial = @pIdMaterial
	where IdMovimientoDetalle = @pIdMovimientoDetalle

	if @@error <> 0
	begin
		rollback tran 
		goto fin
	end

	

	--Por cada movimiento de entrega, registrar los movimientos de recepción afectados
	--Insert Into [dbo].[IN_AL_EntregaRecepcion](IdMovimientoDetEntrega,IdMovimientoDetRecepcion,CantidadRecepcionDesc,CreadoPor,CreadoEl)
	--select @pIdMovimientoDetalle,IdMovimientoDetalle,CantidadUtilizada,@pCreadoPor,getdate()
	--from #tmpMovimientosRecepcion


	--if @@error <> 0
	--begin
	--	rollback tran
	--	goto fin
	--end

	--Actualizar las cantidades disponibles
	--exec sp_IN_AL_ActualizarMaterialDisponible @IdAlmacen,@pIdMovimiento


	--if @@error <> 0
	--begin
	--	rollback tran
	--	goto fin
	--end

	--exec sp_IN_AL_ActualizarPrecioMovimiento @pIdMovimiento

	--if @@error <> 0
	--begin
	--	rollback tran
	--	goto fin
	--end
	 

	commit tran

	fin:
