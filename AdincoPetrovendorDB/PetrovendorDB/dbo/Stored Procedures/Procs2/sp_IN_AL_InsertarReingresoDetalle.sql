
create Proc [dbo].[sp_IN_AL_InsertarReingresoDetalle]
@pIdMovimientoDetalle	int,
@pIdMovimiento	int,
@pIdPedidoDetalle	int,
@pMovimientoEntregaDetalle int,
@pNoItem	int,
@pCantidad	decimal(14,2),
@pCreadoPor	int,
@pCustomError varchar(250) out
as

	DECLARE @IdMovimientoDetRecepcionaUX INT,
			@CantDisCiclo decimal(14,2) = 0,
			@CantMatXRepartirCiclo decimal(14,2) = @pCantidad


	select @pIdMovimientoDetalle = isnull(max(IdMovimientoDetalle),0)+1
	from IN_AL_MovimientoDetalle 

	select @pNoItem = isnull(max(NoItem),0) + 1
	from IN_AL_MovimientoDetalle
	where IdMovimiento = @pIdMovimiento

	begin tran

	insert into IN_AL_MovimientoDetalle(
		IdMovimientoDetalle,IdMovimiento,	IdPedidoDetalle,	NoItem,
		Cantidad,			Disponible,		CreadoPor,			CreadoEl,
		ModificadoPor,		ModificadoEl,	PrecioTotal	)
	values(
		@pIdMovimientoDetalle,@pIdMovimiento,null,				@pNoItem,
			@pCantidad,		null,		@pCreadoPor,		getdate(),
			null,			null,			null		
	)

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	/********Insertar la relación de recepción y entrega previos********************/

	if exists(
		select 1
		from IN_AL_MovimientoDetalle md
		inner join [dbo].[IN_AL_EntregaRecepcion] rel on rel.IdMovimientoDetEntrega = md.IdMovimientoDetalle
		where md.IdMovimientoDetalle = @pMovimientoEntregaDetalle
	)
	begin

		--insert into [dbo].[IN_AL_RecepcionReingreso](
		--	IdMovimientoDetReingreso,		IdMovimientoDetRecepcion,	IdMovimientoDetEntrega,		CreadoPor,		CreadoEl, CantidadMovimiento
		--)
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
		
			select @CantDisCiclo = Disponible
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
					where IdMovimientoDetalle = @IdMovimientoDetRecepcionaUX


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


		


	end
	Else
	begin

		/*******Asegurarse que se hayan generado los movimientos de referencia enla tabla [IN_AL_RecepcionReingreso]**************/
		set @pCustomError = 'Ocurrió un error al generar los movimientos de reingreso, no fue posible obtener la referencia de Recepción y Entrega'

		RAISERROR (@pCustomError, -- Message text.  
               16, -- Severity.  
               1 -- State.  
               );  
	End

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end
	
	
	commit tran

	


	fin:
