

-- sp_IN_AL_AutorizarReserva 12,2326,''
create Proc [dbo].[sp_IN_AL_AutorizarReserva]
@pIdMovimientoReserva int,
@pCreadoPor int,
@pCustomError varchar(250) out
as


	if not exists (
		select 1
		from IN_AL_movimientoDetalle 
		where IdMovimiento = @pIdMovimientoReserva
	)
	begin 
		set @pCustomError = 'No es posible Autorizar un movimiento ID:'+cast(@pIdMovimientoReserva as varchar)+' sin materiales'
		return
	end

	IF EXISTS (
		SELECT 1
		FROM IN_AL_Movimiento
		where IdMovimiento = @pIdMovimientoReserva and IdUsuarioAutorizo > 0
	)
	begin
		set @pCustomError = 'No es posible volver a autorizar el movimiento'
		return
	end

	DECLARE @IdMovimientoDetalleReserva int,
			@CantidadCiclo decimal(14,2) ,
			@IdMaterialCiclo int,
			@IdAlmacen int,
			@IdAux int=0,
			@observaciones VARCHAR(550)

	select @IdAlmacen  =IdAlmacen,
		@observaciones =  Comentarios
	from IN_AL_Movimiento
	where IdMovimiento = @pIdMovimientoReserva

	create Table #tmpTareaID
	(
		IdTarea int
	)
	create Table #tmpSolicitudPedidoID
	(
		IdSolicitudPedido int
	)
	create Table #tmpOperacionID
	(
		IOperacion int
	)

	create Table #tmpSolicitudMaterial
	(
		IdMovmientoDetReserva int,
		IdMaterial int,
		CantidadPedido decimal(14,2),
		IdUnidad int null
	)

	create Table #tmpReservaRecepcion
	(
		IdMovimientoDetReserva int,
		IdMovimientoDetRecepcion int,
		CantidadReserva decimal(14,2)
	)


	create Table #tmpRecepcionesNecesarias
	(
		IdMovimientoDetalle int,
		Utilizado decimal(14,2)
	)


	/***********Buscar las recepciones que se afectarán*****************************/
	/**********Obtener el detalle de Movimientos de la reserva**********************/
	select IdMovimientoDetalle,
			IdMovimiento,
			IdPedidoDetalle,			
			Cantidad,
			Disponible,
			CreadoPor,			
			IdMaterial
	into #tmpDetalleReserva
	from IN_AL_MovimientoDetalle
	where IdMovimiento = @pIdMovimientoReserva


	/*************Por cada movimiento del detalle, obtener que movimientos de recepción se afectarán*****************/

	select @IdMovimientoDetalleReserva = min(IdMovimientoDetalle)
	from #tmpDetalleReserva

	

	while @IdMovimientoDetalleReserva is not null
	begin
		
		select @CantidadCiclo = Cantidad,
			@IdMaterialCiclo = IdMaterial
		from #tmpDetalleReserva
		where IdMovimientoDetalle = @IdMovimientoDetalleReserva
		
		insert into #tmpRecepcionesNecesarias(IdMovimientoDetalle,Utilizado)
		exec [sp_IN_AL_ObtenerRecepcionesParaEntrega] @IdAlmacen,@IdMaterialCiclo,@CantidadCiclo out

		/*******Ir guardando el detalle de la reserva/recepcion***********/
		if exists (
			select 1 from #tmpRecepcionesNecesarias
		)
		begin
			insert into #tmpReservaRecepcion(IdMovimientoDetReserva,IdMovimientoDetRecepcion,CantidadReserva)
			select @IdMovimientoDetalleReserva,IdMovimientoDetalle,Utilizado
			from #tmpRecepcionesNecesarias
		end
		Else
		Begin
			insert into #tmpReservaRecepcion(IdMovimientoDetReserva,IdMovimientoDetRecepcion,CantidadReserva)
			select @IdMovimientoDetalleReserva,null,0
		End

		--Preparar la solicitud de material si no fue posible reservar todo
		if(@CantidadCiclo > 0)
		begin
			insert into #tmpSolicitudMaterial(IdMovmientoDetReserva,IdMaterial,CantidadPedido,IdUnidad)
			select @IdMovimientoDetalleReserva,@IdMaterialCiclo,@CantidadCiclo,IdUnidad
			from MM_Material
			where IdMaterial = @IdMaterialCiclo
			
		end


		--Limpiar temporal
		delete #tmpRecepcionesNecesarias


		--Mover al siguiente
		select @IdMovimientoDetalleReserva = min(IdMovimientoDetalle)
		from #tmpDetalleReserva
		where IdMovimientoDetalle > @IdMovimientoDetalleReserva



	end



	begin tran

	--Marcar como autorizada la reserva

	update IN_AL_Movimiento
	set IdUsuarioAutorizo = @pCreadoPor,
		FechaAutoriza=getdate(),
		ModificadoPor = @pCreadoPor,
		ModificadoEl = getdate()
	where IdMovimiento = @pIdMovimientoReserva

	if @@ERROR <> 0
	begin
		rollback tran
		goto fin
	end

	--Insertar EL DETALLE DE Reserva/Recepcion
	insert into [dbo].[IN_AL_ReservaDetalle](IdMovimientoDetReserva,IdMovimientoDetRecepcion,CantidadReserva,CreadoPor,CreadoEl)
	select IdMovimientoDetReserva,IdMovimientoDetRecepcion,CantidadReserva,@pCreadoPor,getdate()
	from #tmpReservaRecepcion

	if @@ERROR <> 0
	begin
		rollback tran
		goto fin
	end	

	--Actualizar la disponibilidad del los movimientos de recepcion
	Update IN_AL_MovimientoDetalle
	set Disponible = case when (isnull(Disponible,0) - CantidadReserva) <0 then 0 else (isnull(Disponible,0) - CantidadReserva) End
	from IN_AL_MovimientoDetalle md
	inner join #tmpReservaRecepcion rd on rd.IdMovimientoDetRecepcion = md.IdMovimientoDetalle
	

	if @@ERROR <> 0
	begin
		rollback tran
		goto fin
	end	




	/****************REALIZAR LA SOLICITUD DE MATERIALES SIN EXISTENCIA*********************/
	/**
		1.SP_MM_AgregarSolicitudPedido
		2.SP_MM_AgregarSolicitudPedidoDetalle
		3.SP_MM_AgregarArchivoPorMaterialSolPed
		4.SP_TA_ConsultarFlujoTarea
		5.SP_TA_AgregarOperacion
		6.SP_TA_ConsultarFlujoTareaAprobadores
		7.SP_TA_AgregarTarea
		8.SP_TA_AgregarRelacionOperacionTarea
	**/
	if exists (
		select 1
		from #tmpSolicitudMaterial
		
	)
	begin

	 /************Variables para proceso de solicitud**************/
	 declare @FechaEntregaRequerida DATETIME= DATEADD(day,7,GETDATE()),
				@FechaEntregaFinRequerida datetime= DATEADD(day,7,GETDATE()),
				@IdPeriodo int,
				@IdPresupuesto int,
				@IdLineaPresupuestoMes int,
				@IdContrato int,
				@IdProveedor int,
				@IdSolicitudPedido int,
				@IdUnidad int,
				@IdDomicilioEntrega int,
				@IdCentroCosto int=32, --NOTA. Esto se debe de calcular en base a la línea de Presupuesto,
				@IdFlujoTarea int=1226, --NOTA. Falta determinar si el usuario lo capturará o si será calculado,
				@IdTipoOPeracion int,
				@IdAsignador int,
				@IdUsuarioAprobadorTarea int,
				@NSecuenciaFlujoT int,
				@NombreFlujoT varchar(200),
				@IdOperacion int,
				@IdTarea int

			


		/**********Obtener Info del movimiento*******************************/
		SELECT 
			@IdPresupuesto = l.IdPresupuesto,
			@IdPeriodo = pc.IdPeriodo,
			@IdLineaPresupuestoMes = l.IdLineaPresupuestoMes,
			@IdContrato = con.IdContrato,
			@IdProveedor = prov.IdProveedor
		from IN_AL_Movimiento m
		inner join Adinco.dbo.CO_LineaPresupuestoMes l on  l.IdLineaPresupuestoMes = m.IdLineaPresupuestoMes
		inner join Adinco.dbo.CO_Presupuesto  p on p.IdPresupuesto = l.idPresupuesto

		inner join Adinco.dbo.CO_ProgramaActividad pa on pa.IdProgramaActividad = p.IdProgramaActividad

		inner join Adinco.dbo.CO_PeriodoContrato pc on pc.IdPeriodo = pa.IdPeriodoContrato
		inner join IN_Almacen al on al.IdAlmacen = m.IdAlmacen		
		inner join IN_ContratoAlmacen con on con.IdAlmacen = al.IdAlmacen
		inner join Adinco.dbo.CO_Contrato con2 on con2.IdContrato = con.IdContrato
		inner join Adinco.dbo.CO_Contratista ctista on ctista.IdContratista = con2.IdContratista
		inner join Adinco.dbo.PV_SubContratista subC on subC.IdSubContratista = ctista.IdProveedor
		inner join S_Proveedor prov on prov.RFC  COLLATE DATABASE_DEFAULT = subC.RFC COLLATE DATABASE_DEFAULT
		where m.IdMovimiento = @pIdMovimientoReserva
		

		insert into #tmpSolicitudPedidoID(IdSolicitudPedido)
		exec [dbo].[SP_MM_AgregarSolicitudPedido]		@IdTipoSolicitudPedido = 10000 /*Materiales*/,		@IdProveedor =@IdProveedor /*PEND*/,	@IdUsuarioSolicitante = @pCreadoPor, @AdjudicableParcialmente = 0,
		@IdPrioridad = 10002 /*ALTA*/,					@MotivoUrgencia =@observaciones,					@VisitaRequerida=0,						@JuntaAclaracionesRequerida =0,      @UnaSolaEntregaRequerida =0,
        @Activo= 1,										@FechaEntregaRequerida =@FechaEntregaRequerida, 	@FechaEntregaFinRequerida=@FechaEntregaFinRequerida,@EntregasParciales=0, 	 @IdPeriodo=@IdPeriodo, 
		@IdPresupuesto =@IdPresupuesto, 				@IdLineaPresupuesto =@IdLineaPresupuestoMes, 		@IdCentroCosto=@IdCentroCosto/*PEND*/,			@IdTipoGasto =null /*PEND*/, 		 @IdTerminosInternacionales =null, 
		@EntregaUnicoDomicilio=1, 						@IdDomiclioEntrega=null, 							@IdContrato=@IdContrato,				@Fianza =0,							 @Controlados =0

		if @@ERROR <> 0
		begin
			rollback tran
			goto fin
		end	

		select @IdSolicitudPedido = isnull(IdSolicitudPedido,0)
		from #tmpSolicitudPedidoID

		if(isnull(@IdSolicitudPedido,0) = 0)
		begin

			set @pCustomError = 'No fue posible completar el registro de la solicitud de Pedido'
			rollback tran			
			goto fin
		end


		/**************Insertar la solicitud por cada Material*************************/
		/*
			create Table #tmpSolicitudMaterial
			(
				IdMovmientoDetReserva int,
				IdMaterial int,
				CantidadPedido decimal(14,2)
			)

		*/

		

		select @IdAux = min(IdMovmientoDetReserva)
		from #tmpSolicitudMaterial

		set @IdMaterialCiclo = 0
		while @IdAux is not null
		begin
			
			select @IdMaterialCiclo = IdMaterial,
				@CantidadCiclo = CantidadPedido,
				@IdUnidad = IdUnidad
			from  #tmpSolicitudMaterial
			where IdMovmientoDetReserva = @IdAux

			/***********Obtener datos adicionales***************/
			SELECT @IdDomicilioEntrega = IdDomicilio
			FROM IN_AL_Domicilio dom
			where dom.IdAlmacen = @IdAlmacen
			

			if(isnull(@IdDomicilioEntrega,0)=0)
			begin
				set @pCustomError = 'No fue posible obtener el Domicilio de Entrega para la solicitud de Pedido.'
				rollback tran
				goto fin
			end

			set @observaciones = 'SOLICITUD DE RESERVA PARA ALMACÉN: ' + isnull(@observaciones,'')
			exec SP_MM_AgregarSolicitudPedidoDetalle @IdSolicitudPedido = @IdSolicitudPedido,		@IdMaterial = @IdMaterialCiclo,	
													@Cantidad = @CantidadCiclo,						@observaciones = @observaciones,
													@CreadoPor=@pCreadoPor,							@IdUnidad=@IdUnidad, 
													@IdDomicilioEntrega=@IdDomicilioEntrega,		@IdCentroCosto= @IdCentroCosto

			if @@ERROR <> 0
			begin
				rollback tran
				goto fin
			end	

			select @IdAux = min(IdMovmientoDetReserva)
			from #tmpSolicitudMaterial
			where IdMovmientoDetReserva > @IdAux
			
		end


		/*************Insertar el Flujo de Tarea******************/
		 SELECT  @IdTipoOPeracion = TO_.IdTipoOperacion, 
			@IdAsignador = CreadorPor,
			@NombreFlujoT=FT.Descripcion
		 FROM TA_FlujoTarea AS FT
		 INNER JOIN TA_TipoOperacion AS TO_ ON TO_.IdTipoOperacion = FT.IdTipoOperacion
		 WHERE IdFlujoTarea = @IdFlujoTarea;


		 insert into #tmpOperacionID(IOperacion)
		 exec SP_TA_AgregarOperacion @IdDocumento=@IdSolicitudPedido,		@IdTipoOperacion=@IdTipoOPeracion,		@IdFlujoTarea=@IdFlujoTarea,		@IdProveedor=@IdProveedor,
		 @IdEstatusOperacion=1,		@IdEstadoFlujo=1,						@IdAsignador=@IdAsignador,				@Descripcion='SOLICITUD DE RESERVA DE ALMACÉN',		@IdVigencia = 1 /***FALTARIA DEFINIR CUAL SERÍA LA VIGENCIA PARA ESTA SOLICITUD**/,
		 @IdPrioridad=2

		if @@ERROR <> 0
		begin
			rollback tran
			goto fin
		end	

		select @IdOperacion = IOperacion
		from #tmpOperacionID

		/****************Insertar Aprobadores del Flujo de Tarea****************************/
		 
		SELECT A.IdUsuario,NoSecuencia
		into #tmpTA_Aprobador
		FROM TA_Aprobador AS A
		INNER JOIN S_Usuario AS U on U.IdUsuario = A.IdUsuario
		WHERE A.IdFlujoTarea = @IdFlujoTarea
		ORDER BY  NoSecuencia ASC


		select @NSecuenciaFlujoT = min(NoSecuencia)
		from #tmpTA_Aprobador

		while @NSecuenciaFlujoT is not null
		begin
			

			select @IdUsuarioAprobadorTarea = IdUsuario
			from #tmpTA_Aprobador
			where NoSecuencia = @NSecuenciaFlujoT

			insert into #tmpTareaID(IdTarea)
			exec SP_TA_AgregarTarea @NombreTarea=@NombreFlujoT,@IdEstatus=1,@IdAprobador=@IdUsuarioAprobadorTarea,@Visto=0,@NoSecuencia=@NSecuenciaFlujoT,@IdOperacion=@IdOperacion

			if @@ERROR <> 0
			begin
				rollback tran
				goto fin
			end	

			select @IdTarea = IdTarea
			from #tmpTareaID

			delete #tmpTareaID

			if @IdTarea > 0
			begin 
				exec SP_TA_AgregarRelacionOperacionTarea @IdOperacion,@IdTarea

				if @@ERROR <> 0
				begin
					rollback tran
					goto fin
				end	
			end
			Else
			begin
				set @pCustomError = 'No fue posible obtener la relación Operacion/Tarea'
				rollback tran
				goto fin
			end


			select @NSecuenciaFlujoT = min(NoSecuencia)
			from #tmpTA_Aprobador
			where NoSecuencia > @NSecuenciaFlujoT
		end
		

	
		/*********Programar las notificaciones*******************/		
	--	EXEC sp_IN_AL_ProgCorreoAutReserva @IdAlmacen,@IdSolicitudPedido, @IdOperacion,@IdFlujoTarea,@pCreadoPor
	
		
		if @@ERROR <> 0
		begin
			rollback tran
			goto fin
		end	
		
		--ACTUALIZAR EL MOVIMIENTO CON LA SOLICITUD DE PEDIDO
		update IN_AL_Movimiento
		set IdSolicitudPedido = @IdSolicitudPedido
		where IdMovimiento = @pIdMovimientoReserva


		if @@ERROR <> 0
		begin
			rollback tran
			goto fin
		end	

	end


	commit tran

	fin:


