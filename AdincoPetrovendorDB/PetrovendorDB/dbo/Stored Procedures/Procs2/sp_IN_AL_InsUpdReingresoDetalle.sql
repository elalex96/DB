
create Proc [dbo].[sp_IN_AL_InsUpdReingresoDetalle]
@pIdMovimientoDetalle	int,
@pIdMovimiento	int,
@pIdPedidoDetalle	int,
@pIdMaterial int,
@pMovimientoEntregaDetalle int,
@pNoItem	int,
@pCantidad	float,
@pCreadoPor	int,
@pCustomError varchar(250) out,
@pInsUpd int --1Insertar 2. Actualizar
as

	DECLARE @IdMovimientoDetRecepcionaUX INT,
			@CantDisCiclo float = 0,
			@CantMatXRepartirCiclo float = @pCantidad,
			@IdAlmacen int,
			@ueps  bit,
			@IdMovimientoSinRef int

	select @IdAlmacen = IdAlmacen
	from IN_AL_Movimiento
	where IdMovimiento = @pIdMovimiento

	/********SIN REFERENCIA**************/
	if(@pMovimientoEntregaDetalle = -1)
		set @pMovimientoEntregaDetalle = null


	select @pCustomError = dbo.fn_IN_AL_ValidarReingreso(@pIdMovimiento,@pIdMovimientoDetalle,@pMovimientoEntregaDetalle,@pCantidad)

	if(@pCustomError <> '')
	begin
		goto fin
	end
	

	begin tran



	/*********INSERTAR************************/
	if @pInsUpd = 1
	begin

		select @pIdMovimientoDetalle = isnull(max(IdMovimientoDetalle),0)+1
		from IN_AL_MovimientoDetalle 

		select @pNoItem = isnull(max(NoItem),0) + 1
		from IN_AL_MovimientoDetalle
		where IdMovimiento = @pIdMovimiento

		insert into IN_AL_MovimientoDetalle(
		IdMovimientoDetalle,IdMovimiento,	IdPedidoDetalle,	NoItem,
		Cantidad,			Disponible,		CreadoPor,			CreadoEl,
		ModificadoPor,		ModificadoEl,	PrecioTotal,		IdMaterial	)
		values(
			@pIdMovimientoDetalle,@pIdMovimiento,null,				@pNoItem,
				@pCantidad,		null,		@pCreadoPor,		getdate(),
				null,			null,			null,			@pIdMaterial
		)

		if @@error <> 0
		begin 
			rollback tran
			goto fin
		end
	End


	/************ACTUALIZAR*******************/

	if @pInsUpd = 2
	begin
		
		update IN_AL_MovimientoDetalle
		set Cantidad = @pCantidad,
			ModificadoPor = @pCreadoPor,
			ModificadoEl = getdate()
		where IdMovimientoDetalle = @pIdMovimientoDetalle

		if @@error <> 0
		begin 
			rollback tran
			goto fin
		end

		delete [IN_AL_RecepcionReingreso]
		where IdMovimientoDetReingreso = @pIdMovimientoDetalle

		if @@error <> 0
		begin 
			rollback tran
			goto fin
		end
	End

	/********Insertar la relación de recepción y entrega previos********************/

	if exists(
		select 1
		from IN_AL_MovimientoDetalle md
		inner join [dbo].[IN_AL_EntregaRecepcion] rel on rel.IdMovimientoDetEntrega = md.IdMovimientoDetalle
		where md.IdMovimientoDetalle = @pMovimientoEntregaDetalle
	)
	and isnull(@pMovimientoEntregaDetalle,0) > 0 --SE HAYA CAPTURADO UN MOVIMIENTO DE ENTREGA
	begin
	
		select IdMovimientoDetReingreso=@pIdMovimientoDetalle,
				IdMovimientoDetRecepcion = rel.IdMovimientoDetRecepcion,
				IdMovimientoEntregaDetall = @pMovimientoEntregaDetalle,		
				CreadoPor = @pCreadoPor,  
				CreadoEl = getdate(), 
				CantidadMovimiento =cast( 0.00 as decimal(14,2))
		into #tmpReferenciasMovs
		from IN_AL_MovimientoDetalle md
		inner join [dbo].[IN_AL_EntregaRecepcion] rel on rel.IdMovimientoDetEntrega = md.IdMovimientoDetalle
		where md.IdMovimientoDetalle = @pMovimientoEntregaDetalle

		if @@error <> 0
		begin 
			rollback tran
			goto fin
		end

		/**********Calcular la cantidad que se repartirá entre cada movimiento**************************/
		SELECT @IdMovimientoDetRecepcionaUX = MAX(IdMovimientoDetRecepcion)
		FROM #tmpReferenciasMovs 
		WHERE IdMovimientoDetReingreso = @pIdMovimientoDetalle

		while @IdMovimientoDetRecepcionaUX is not null and	isnull(@CantMatXRepartirCiclo,0) >0
		Begin
		
			select @CantDisCiclo =Cantidad- Disponible
			from IN_AL_MovimientoDetalle
			where IdMovimientoDetalle = @IdMovimientoDetRecepcionaUX 	

			

			if(@CantDisCiclo >= @CantMatXRepartirCiclo)
			begin
					update #tmpReferenciasMovs
					set CantidadMovimiento = @CantMatXRepartirCiclo
					where IdMovimientoDetRecepcion = @IdMovimientoDetRecepcionaUX


					if @@error <> 0
					begin 
						rollback tran
						goto fin
					end

					set @CantMatXRepartirCiclo = 0

			end
			Else
			Begin
					update #tmpReferenciasMovs
					set CantidadMovimiento = @CantDisCiclo
					where IdMovimientoDetRecepcion = @IdMovimientoDetRecepcionaUX


					set @CantMatXRepartirCiclo = @CantMatXRepartirCiclo - @CantDisCiclo
			End

			SELECT @IdMovimientoDetRecepcionaUX = MAX(IdMovimientoDetRecepcion)
			FROM #tmpReferenciasMovs 
			WHERE IdMovimientoDetReingreso = @pIdMovimientoDetalle
			and IdMovimientoDetRecepcion < @IdMovimientoDetRecepcionaUX

		End


		insert into [dbo].[IN_AL_RecepcionReingreso](
			IdMovimientoDetReingreso,		IdMovimientoDetRecepcion,	IdMovimientoDetEntrega,		CreadoPor,		CreadoEl, CantidadMovimiento
		)
		select IdMovimientoDetReingreso,
				IdMovimientoDetRecepcion ,
				IdMovimientoEntregaDetall ,		
				CreadoPor ,  
				CreadoEl , 
				CantidadMovimiento 	
		from #tmpReferenciasMovs

		if @@error <> 0
		begin 
			rollback tran
			goto fin
		end



	end
	Else
	begin



		/****************Intentar obtener los movimientos de recepción en base al hostorial de recepciones*****************/
		--/**********Obtener primero UEPS o PEPS********************************/
		--select @ueps = UEPS
		--from IN_Almacen
		--where idAlmacen = @IdAlmacen

		--/**************Si es UEPS obtener el ultimo movimiento de recepcion para asignarle el reingreso, Sino obtener el ultimo movimiento********************/
		--if @ueps = 1
		--begin

		--	select top 1 @IdMovimientoDetRecepcionaUX = IdMovimientoDetalle
		--	from IN_AL_MovimientoDetalle md
		--	inner Join IN_AL_Movimiento m on m.IdMovimiento = md.IdMovimiento
		--	inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = md.IdPedidoDetalle
		--	where IdAlmacen = @IdAlmacen and
		--	md.IdEstatus = 1 And--Libre
		--	m.IsEliminado = 0 And
		--	pd.IdMaterialVendedor = @pIdMaterial
		--	order by m.FechaMovimiento desc

		--End
		--Else
		--Begin
		--	select top 1 @IdMovimientoDetRecepcionaUX = IdMovimientoDetalle
		--	from IN_AL_MovimientoDetalle md
		--	inner Join IN_AL_Movimiento m on m.IdMovimiento = md.IdMovimiento
		--	inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = md.IdPedidoDetalle
		--	where IdAlmacen = @IdAlmacen and
		--	md.IdEstatus = 1 And--Libre
		--	m.IsEliminado = 0 And
		--	pd.IdMaterialVendedor = @pIdMaterial
		--	order by m.FechaMovimiento asc
		--End

		--Intentar Obtener una recepción sin referencia
		select @IdMovimientoSinRef = isnull(max(IdMovimiento),0)
		from IN_AL_Movimiento mov		
		where mov.IsEliminado = 0 and
		mov.IdUsuarioAutorizo > 0 and
		mov.IdTipoMovimiento = 4  and--Movimiento Sin Referencia		
		mov.IdAlmacen = IdAlmacen

		

		--Intentar Obtener una recepción sin referencia
		select @IdMovimientoDetRecepcionaUX = isnull(max(IdMovimientoDetalle),0)
		from IN_AL_Movimiento mov
		inner join IN_AL_MovimientoDetalle md on md.IdMovimiento = mov.IdMovimiento
		where mov.IsEliminado = 0 and
		mov.IdUsuarioAutorizo > 0 and
		mov.IdTipoMovimiento = 4  and--Movimiento Sin Referencia
		md.IdMaterial = @pIdMaterial and
		mov.IdAlmacen = @IdAlmacen

		/*************Si no se obtuvo un resultado, Generar el movimiento*********************/

		if isnull(@IdMovimientoDetRecepcionaUX,0) = 0
		begin

			declare @idAux int
			
			if isnull(@IdMovimientoSinRef,0) = 0
			begin

				

				select @idAux  =isnull(max(IdMovimiento),0) + 1
				from IN_AL_Movimiento

				insert into IN_AL_Movimiento(
						IdMovimiento,		IdAlmacen,		IdPedido,	Folio,				IdTipoMovimiento,	FechaMovimiento,
						HoraMovimiento,		RecibidoEn,		EntregadoEn,IdUsuarioAtendio,	Comentarios,		PrecioTotal,
						IdUsuarioAutorizo,	FechaAutoriza,	CreadoPor,	CreadoEl,			ModificadoPor,		ModificadoEl,
						IsEliminado,		EntregadoA)
				values	(
					@idAux,					@IdAlmacen,	null,			 0,				4,					getdate(),
					CONVERT(TIME(0),GETDATE()),'',			null,		@pCreadoPor,		'RECEPCIÓN SIN REFERENCIA',	0,
						@pCreadoPor,		GETDATE(),		@pCreadoPor,GETDATE(),		NULL,					NULL,
						0,					NULL									
				)

				If @@error <> 0
				begin 
					rollback tran
					goto fin
				end

				SET @IdMovimientoSinRef = @idAux


			end


			/*************Insertar el detalle DEL Movimiento sin Referencia******************/

			select @idAux = isnull(max(IdMovimientoDetalle),0) + 1
			from IN_AL_MovimientoDetalle

			insert into IN_AL_MovimientoDetalle(
			IdMovimientoDetalle,		IdMovimiento,		IdPedidoDetalle,		NoItem,			Cantidad,
			Disponible,					CreadoPor,			CreadoEl,				ModificadoPor,	ModificadoEl,
			PrecioTotal,				IdMaterial)
			values(
			@idAux,						@IdMovimientoSinRef,null,					1,				0,
			0,							@pCreadoPor,		getdate(),				null,			null,
			0,							@pIdMaterial)

			If @@error <> 0
			begin 
					rollback tran
					goto fin
			end

			set @IdMovimientoDetRecepcionaUX = @idAux

			

		end

		


		if @IdMovimientoDetRecepcionaUX > 0
		begin 

			insert into [dbo].[IN_AL_RecepcionReingreso](
				IdMovimientoDetReingreso,		IdMovimientoDetRecepcion,	IdMovimientoDetEntrega,		CreadoPor,		CreadoEl, CantidadMovimiento
			)
			select @pIdMovimientoDetalle,
					@IdMovimientoDetRecepcionaUX ,
					null ,		
					@pCreadoPor ,  
					getdate() , 
					@pCantidad 	
			

			
		End
		Else
		Begin
			
			/*******Asegurarse que se hayan generado los movimientos de referencia enla tabla [IN_AL_RecepcionReingreso]**************/
			set @pCustomError = 'Ocurrió un error al generar los movimientos de reingreso, no fue posible obtener la referencia de Recepción y Entrega'

			RAISERROR (@pCustomError, -- Message text.  
				   16, -- Severity.  
				   1 -- State.  
				   );  
		End
	




	End

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end


	
	
	
	commit tran

	


	fin:
