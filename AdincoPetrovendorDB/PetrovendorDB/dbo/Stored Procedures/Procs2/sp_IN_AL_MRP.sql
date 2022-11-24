
-- sp_IN_AL_MRP 1,2205,''
CREATE PROC [dbo].[sp_IN_AL_MRP]
@pIdAlmacen INT,
@pCreadoPor INT,
@pCustomError VARCHAR(250) out
AS


	Create Table #tmpTareaID
	(
		IdTarea int
	)
	Create Table #tmpSolicitudPedidoID
	(
		IdSolicitudPedido int
	)
	Create Table #tmpOperacionID
	(
		IOperacion int
	)	


	/****************REVISAR TODOS LOS MATERIALES QUE ESTEN EN EL MRP QUE YA SEA NECESARIO 
	LANZAR UNA SOLICITUD DE PEDIDO***************/

	SELECT i = IDENTITY(INT,1,1),
			mrp.IdAlmacen,
			mrp.IdMaterial,
			mrp.CantidadMinima,
			CantidadASolicitar = 0,
			CantidadVirtual = ISNULL(exs.CantidadLibre,0) + ISNULL(CantidadSolPed,0) + ISNULL(CantidadPed,0) +ISNULL(CantidadTra,0),
			IdLineaPresupuesto = ISNULL(mrp.IdLineaPresupuesto,AL.IdLineaPresupuestoMes),
			mrp.CantidadSobreMinimo,
			u.IdUnidad
	INTO #tmpMRPSolicitudMaterial
	FROM dbo.IN_AL_MRP mrp
	INNER JOIN dbo.vw_IN_AL_Existencias exs ON exs.IdMaterial = mrp.IdMaterial AND
									EXS.IdAlmacen = MRP.IdAlmacen
	INNER JOIN dbo.IN_Almacen al ON al.IdAlmacen = mrp.IdAlmacen
	inner JOIN MM_Maestro mat ON mat.IdMaestro = mrp.IdMaterial
	left JOIN dbo.MM_Unidad u ON u.IdUnidad = mat.IdUnidad
	WHERE mrp.IdAlmacen = @pIdAlmacen AND
    ISNULL(exs.CantidadLibre,0) + ISNULL(CantidadSolPed,0) + ISNULL(CantidadPed,0) +ISNULL(CantidadTra,0) <= mrp.CantidadMinima

	UPDATE #tmpMRPSolicitudMaterial
	SET CantidadASolicitar = (ISNULL(CantidadMinima,0) - ISNULL(CantidadVirtual,0) + CantidadSobreMinimo)


	SELECT * FROM  #tmpMRPSolicitudMaterial
	--RETURN 


	/*********INICIAR EL PROCESO PARA HACER LAS SOLICITUDDES DE PEDIDO PARA MRP*********/
	IF EXISTS (
		SELECT 1 
		FROM #tmpMRPSolicitudMaterial
	)
	BEGIN

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
				@IdTarea INT,
				@observaciones VARCHAR(550),
				@IdAux INT,
				@IdMovimientoDetalleReserva int,
				@CantidadCiclo decimal(14,2) ,
				@IdMaterialCiclo int,
				@IdAlmacen int


		/***********REALIZAR UNA SOLICITUD POR CADA LÍNEA DE PRESUPUESTO******/

		SELECT IdLineaPresupuesto
		INTO #TMPLineaPresupuestoSol
		FROM #tmpMRPSolicitudMaterial
		GROUP BY IdLineaPresupuesto

		SELECT @IdLineaPresupuestoMes = IdLineaPresupuesto
		FROM #tmpMRPSolicitudMaterial

		BEGIN TRAN

		WHILE @IdLineaPresupuestoMes IS NOT NULL
        BEGIN

			/*********Obtener
			@IdPresupuesto ,@IdPeriodo,	@IdLineaPresupuestoMes,@IdContrato,	@IdProveedor
			*********/

			SELECT @IdPresupuesto = P.IdPresupuesto,
				@IdPeriodo = pc.IdPeriodo,
				@IdLineaPresupuestoMes = lpm.IdLineaPresupuestoMes,
				@IdContrato = con.IdContrato,
				@IdProveedor = prov.IdProveedor,
				@observaciones = 'SOLICITUD REALIZADA DESDE MRP DE ALMACEN:' + AL.Nombre
			FROM Adinco.dbo.CO_LineaPresupuestoMes LPM
			inner join Adinco.dbo.CO_Presupuesto  p on p.IdPresupuesto = lPM.idPresupuesto
			inner join Adinco.dbo.CO_ProgramaActividad pa on pa.IdProgramaActividad = p.IdProgramaActividad
			inner join Adinco.dbo.CO_PeriodoContrato pc on pc.IdPeriodo = pa.IdPeriodoContrato
			inner join IN_Almacen al on al.IdAlmacen = @pIdAlmacen			
			inner join IN_ContratoAlmacen con on con.IdAlmacen = al.IdAlmacen		
			inner join Adinco.dbo.CO_Contrato con2 on con2.IdContrato = con.IdContrato
			inner join Adinco.dbo.CO_Contratista ctista on ctista.IdContratista = con2.IdContratista
			INNER join Adinco.dbo.PV_SubContratista subC on subC.IdSubContratista = ctista.IdProveedor
			INNER join S_Proveedor prov on prov.RFC  COLLATE DATABASE_DEFAULT = subC.RFC COLLATE DATABASE_DEFAULT
			WHERE LPM.IdLineaPresupuestoMes  = @IdLineaPresupuestoMes


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
			END
            
			DELETE #tmpSolicitudPedidoID

			if @@ERROR <> 0
			begin
				rollback tran
				goto fin
			end	
			

			/********Obtener el domicilio**********/
			SELECT @IdDomicilioEntrega = IdDomicilio
			FROM IN_AL_Domicilio dom
			where dom.IdAlmacen = @pIdAlmacen


			if(isnull(@IdDomicilioEntrega,0)=0)
			begin
				set @pCustomError = 'No fue posible obtener el Domicilio de Entrega para la solicitud de Pedido.'
				rollback tran
				goto fin
			END
            
			SELECT @IdAux = MIN(I)
			FROM #tmpMRPSolicitudMaterial
			WHERE IdLineaPresupuesto = @IdLineaPresupuestoMes

			/**************Recorrer cada material para insertarlo en el detalle********/
			set @IdMaterialCiclo = 0
			WHILE @IdAux IS NOT NULL
            BEGIN
				
				select @IdMaterialCiclo = IdMaterial,
				@CantidadCiclo = CantidadASolicitar,
				@IdUnidad = IdUnidad
				from  #tmpMRPSolicitudMaterial
				where I = @IdAux


				exec SP_MM_AgregarSolicitudPedidoDetalle @IdSolicitudPedido = @IdSolicitudPedido,		@IdMaterial = @IdMaterialCiclo,	
													@Cantidad = @CantidadCiclo,						@observaciones = @observaciones,
													@CreadoPor=@pCreadoPor,							@IdUnidad=@IdUnidad, 
													@IdDomicilioEntrega=@IdDomicilioEntrega,		@IdCentroCosto= @IdCentroCosto

				if @@ERROR <> 0
				begin
					rollback tran
					goto fin
				end	
			
				--Moverse al siguiente material
				SELECT @IdAux = MIN(I)
				FROM #tmpMRPSolicitudMaterial
				WHERE IdLineaPresupuesto = @IdLineaPresupuestoMes
				AND I > @IdAux

            END
            


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
			END	

			select @IdOperacion = IOperacion
			FROM #tmpOperacionID

			DELETE #tmpOperacionID

			if @@ERROR <> 0
			begin
				rollback tran
				goto fin
			END	
			/****************Insertar Aprobadores del Flujo de Tarea****************************/

		IF OBJECT_ID('tempdb..#tmpTA_Aprobador') IS NOT NULL DROP TABLE #tmpTA_Aprobador
		 
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
				EXEC sp_IN_AL_ProgCorreoAutReserva @IdAlmacen,@IdSolicitudPedido, @IdOperacion,@IdFlujoTarea,@pCreadoPor
	
		
			if @@ERROR <> 0
			begin
				rollback tran
				goto fin
			end	


			/**********Insertar relación MRP/SolicitudPedido*******/
			INSERT [dbo].[IN_AL_MRP_SolicitudPedido](IdAlmacen,IdSolicitudPedido,CreadoEl)
			VALUES(@pIdAlmacen,@IdSolicitudPedido,GETDATE())

			if @@ERROR <> 0
			begin
				rollback tran
				goto fin
			end	


			/******Moverse a la sig, linea de presupuesto*/

			SELECT @IdLineaPresupuestoMes = MIN(IdLineaPresupuesto)
			FROM #tmpMRPSolicitudMaterial
			WHERE IdLineaPresupuesto > @IdLineaPresupuestoMes


        END
                

		COMMIT TRAN
		FIN:


    END


