

create Proc [dbo].[sp_IN_AL_InsertarEntregaDetalle]
@pIdMovimiento int,
@pIdMovimientoDetalle int out,
@pIdMaterial int,
@pIdPedidoDetalle int out,		
@pCantidad float,					
@pDisponible float out,			
@pCreadoPor int,
@pIdSegundaUnidad int,
@pCantSegundaUnidad	float,
@pCustomError varchar(250) OUT
as 

	declare @NoItem int,
			@IdMovimientoDetEntrega int,
			@IdAlmacen int,
			@CantidadProcesoRE float = @pCantidad,
			@equivPrimeraUnidad DECIMAL(9,3)

	create table #tmpMovimientosRecepcion
	(
		IdMovimientoDetalle int,
		CantidadUtilizada float
	)


	/***********Si se capturó una segunda unidad, hacer la conversión de l cantidad*******/
	IF(ISNULL(@pIdSegundaUnidad,0) > 0)
	BEGIN

		SELECT @equivPrimeraUnidad = mu.EquivUnidadMaestro
		FROM dbo.IN_AL_MaterialUnidad mu
		WHERE mu.IdMaterial = @pIdMaterial AND
		MU.IdUnidad = @pIdSegundaUnidad

		if ISNULL(@equivPrimeraUnidad,0) = 0
		begin
			RAISERROR ('No fue posible obtener la equivalencia ',16,1)
			return
		END
        
		set @pCantidad = @pCantSegundaUnidad * @equivPrimeraUnidad
		SET @CantidadProcesoRE = @pCantidad

    END
	ELSE
		SET @pIdSegundaUnidad = null
    

	/************REALIZAR VALIDACIONES*******************/
	select @pCustomError = dbo.fn_IN_AL_ValidarEntrega(@pIdMovimiento,@pIdMovimientoDetalle,@pIdMaterial,@pCantidad)

	if(@pCustomError<> '')
		goto fin


	select @pIdMovimientoDetalle = isnull(max(IdMovimientoDetalle),0) + 1
	from IN_AL_MovimientoDetalle

	select @NoItem = isnull(max(NoItem),0) + 1
	from IN_AL_MovimientoDetalle
	where IdMovimiento =@pIdMovimiento 

	select @IdAlmacen = IdAlmacen
	from IN_AL_Movimiento
	where IdMovimiento = @pIdMovimiento

	--Obtener los movimientos de recepción que se utilizarán
	insert into #tmpMovimientosRecepcion(IdMovimientoDetalle,CantidadUtilizada)
	exec sp_IN_AL_ObtenerRecepcionesParaEntrega @IdAlmacen,@pIdMaterial,@CantidadProcesoRE out

	--select *,@CantidadProcesoRE from #tmpMovimientosRecepcion

	if @CantidadProcesoRE > 0
	begin
		RAISERROR ('No es posible registrar la entrega ya que no hay material suficiente disponible en el almacén',16,1)
		return
	end


	
	

	begin tran

	select @pIdPedidoDetalle = min(pd.IdPedidoDetalle)
	from #tmpMovimientosRecepcion mr
	inner join IN_AL_MovimientoDetalle md on md.IdMovimientoDetalle = mr.IdMovimientoDetalle
	inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = md.IdPedidoDetalle

	insert into IN_AL_MovimientoDetalle(
		IdMovimientoDetalle,		IdMovimiento,		IdPedidoDetalle,		NoItem,
		Cantidad,					Disponible,			CreadoPor,				CreadoEl,	
		ModificadoPor,				ModificadoEl,		IdMaterial,				IdSegundaUnidad,
		CantSegundaUnidad			
	)
	values(
		@pIdMovimientoDetalle,		@pIdMovimiento,		@pIdPedidoDetalle,		@NoItem,
		@pCantidad,					@pDisponible,		@pCreadoPor,		getdate(),	
		null,						null		,		@pIdMaterial	,		@pIdSegundaUnidad,
		@pCantSegundaUnidad				
		
	)

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	--Eliminar todo lo relacionado al movimiento de entrega
	--delete [IN_AL_EntregaRecepcion]
	--where IdMovimientoDetEntrega = @pIdMovimientoDetalle

	--if @@error <> 0
	--begin
	--	rollback tran
	--	goto fin
	--end

	

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
