
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- p_OT_ActualizarSolicitud 1,5,1
CREATE PROC p_OT_ActualizarSolicitud
@pIdOTSolicitud INT,
@pIdOTEstatus INT,
@pCreadoPor INT,
@pEsProveedor bit=0,
@pMotivoRechazo varchar(250) = ''
AS

	DECLARE @pError VARCHAR(250)='',
		@esExcedida bit=0,
		@idAux int ,
		@progIniProv bit=0,
		@IdOTEstatusAct int=0,
		--
		@CreadorOT bit=0,
		@enviarAprobador bit=0,
		@AprobadorOT bit=0,
		@ValidadorCantOT bit=0,
		@GeneradorEstimacion bit=0,
		@AceptacionServicioOT bit=0,
		@pFlujoAprobacionTareaId int,
		@IdOTEstatusAnt int,
		@descripcionBitacora varchar(150),
		@permitirConvenios bit

	select @IdOTEstatusAct = IdOTEstatus,
		@progIniProv= isnull(ProgIniPorProveedor,0),
		@permitirConvenios = isnull(conf.PermitirConvenios,0)
	from OT_Solicitud sol
	inner join SC_Subcontrato sc on sc.IdSubcontrato = sol.IdSubcontrato
	left join OT_Configurador conf on conf.IdContrato = sc.IdContrato
	where sol.IdOTSolicitud = @pIdOTSolicitud

	--Si el programa inicial es por el proveedor
	--if @progIniProv = 0
	--begin
	
	--	--Enviar a aprobador interno
	--	if @IdOTEstatusAct = 1 and @CreadorOT=1
	--	begin
	--		set @pIdOTEstatus = 11
	--	end

	--end

	/**********Verificar si el contrato tiene cantidades excedidas******************/
	if	(dbo.fn_SC_ExcedidoSiNo(@pIdOTSolicitud)=1 and  @permitirConvenios = 1 and @pIdOTEstatus not in (7,8,12))
	begin
		set @esExcedida = 1
		set @pIdOTEstatus = 9 --Requiere convenio
	end
	if	(dbo.fn_SC_ExcedidoSiNo(@pIdOTSolicitud)=1 and  @permitirConvenios = 0 and @pIdOTEstatus not in (7,8,12))
	begin
		RAISERROR (15600,-1,-1, 'No es posible continuar, el contrato está excedido'); 
		return
	end


	BEGIN TRAN

	


	if @esExcedida = 1 --SI EL SUBCONTRATO SE EXCEDE CON LAS CANTIDADES DE LA NUEVA OT
	begin

		

		select @idAux=isnull(max(IdOTConvenio),0) + 1
		from OT_Convenio

		INsert into OT_Convenio(
			IdOTConvenio,	IdOTSolicitud,	Aprobada,	FechaRegistro,	
			CreadoPor,		AprobadaPor,	FechaAprobacion
		)
		select @idAux,@pIdOTSolicitud, 0, getdate(),
		@pCreadoPor,		null,			null

		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRAN
			GOTO fin
		END

		UPDATE dbo.OT_Solicitud
		SET ModificadoPor = @pCreadoPor,
			ModificadoEl = GETDATE(),
			IdOTEstatusAnt = IdOTEstatus,
			IdOTEstatus = @pIdOTEstatus --Requiere convenio
		WHERE IdOTSolicitud = @pIdOTSolicitud

		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRAN
			GOTO fin
		END

		set @descripcionBitacora = 'Enviada a Aprobador Interno - Se detectó que requiere convenio'

		if @pEsProveedor = 0
		begin
			exec p_OT_SolicitudBitacora_ins @pIdOTSolicitud,null,@descripcionBitacora,@pCreadoPor,null
		end
		if @pEsProveedor = 1
		begin
			exec p_OT_SolicitudBitacora_ins @pIdOTSolicitud,null,@descripcionBitacora,null,@pCreadoPor
		end


		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRAN
			GOTO fin
		END

		/********Enviar correo para el proceso de OT*******/
			EXEC p_OT_CorreoProgramacion_Flujo @pIdOTSolicitud,1,@pError OUT,@pIdOTEstatus
        
			IF @pError <> '' OR @@ERROR <> 0
			BEGIN
				ROLLBACK TRAN
				RAISERROR (15600,-1,-1, @pError); 
				GOTO fin 
			end
			
		
	end
	Else
	Begin

		UPDATE dbo.OT_Solicitud
		SET ModificadoPor = @pCreadoPor,
			ModificadoEl = GETDATE(),
			IdOTEstatusAnt = IdOTEstatus,
			IdOTEstatus = @pIdOTEstatus
		WHERE IdOTSolicitud = @pIdOTSolicitud

		
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRAN
			GOTO fin
		END

		select @descripcionBitacora =Descripcion
		from OT_Estatus
		where IdOtEstatus = @pIdOTEstatus
		
		if @pEsProveedor = 0
		begin
			

			if(@pIdOTEstatus in (7))
			begin
				exec p_OT_SolicitudBitacora_ins @pIdOTSolicitud,null,@pMotivoRechazo,@pCreadoPor,null,8

			end
			else
			begin
				exec p_OT_SolicitudBitacora_ins @pIdOTSolicitud,null,@descripcionBitacora,@pCreadoPor,null
			end
		end
		if @pEsProveedor = 1
		begin
			

			if(@pIdOTEstatus in (8))
			begin
				exec p_OT_SolicitudBitacora_ins @pIdOTSolicitud,null,@pMotivoRechazo,null,@pCreadoPor,9

			end
			else
			begin 
				exec p_OT_SolicitudBitacora_ins @pIdOTSolicitud,null,@descripcionBitacora,null,@pCreadoPor
			end
		end

		if( @@ERROR <> 0)
		begin
				ROLLBACK TRAN
				GOTO fin
		end

		  
		IF @pIdOTEstatus IN(2,3,4,5,6,7,8,9,11) 
		BEGIN
			/********Enviar correo para el proceso de OT*******/
			EXEC p_OT_CorreoProgramacion_Flujo @pIdOTSolicitud,1,@pError OUT,@pIdOTEstatus
        
			IF @pError <> ''
			BEGIN
				ROLLBACK TRAN
				RAISERROR (15600,-1,-1, @pError); 
				GOTO fin 
			end
		END

		if( @@ERROR <> 0)
		begin
				ROLLBACK TRAN
				GOTO fin
		end

	End



	EXEC p_OT_SolicitudPrograma_Ajuste_Upd @pIdOTSolicitud

	fin:

	COMMIT TRAN







