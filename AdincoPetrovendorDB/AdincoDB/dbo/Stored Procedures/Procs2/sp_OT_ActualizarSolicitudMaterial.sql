---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE Proc sp_OT_ActualizarSolicitudMaterial
@pIdOTSolicitudMaterial int ,
@pIdSCMaterial int,
@pCantidad decimal(14,2),
@pModificadoPor int,
@pFechaProgramaInicio datetime=null,
@pFechaProgramaFin datetime=NULL,
@pComentarios varchar(300)=null,
@pTipoUsuario int
as

	/*********Obtener la fecha de inicio y fin original antes de actualizar****************/
	declare @fechaProgIni datetime,
		@fechaProgFin datetime,
		@idOTSolicitud int


	select @fechaProgIni =FechaProgramaInicio,
		@fechaProgFin=FechaProgramaFin,
		@idOTSolicitud = IdOTSolicitud
	from OT_SolicitudMaterial
	where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial

	Begin tran

	/***SI ES SUBCONTRATISTA**********/
	if(@pTipoUsuario in( 1,2))
	begin
		delete OT_SolicitudPrograma
		where IdOTSolicitudPrograma = @pIdOTSolicitudMaterial

		if @@error <> 0
		begin 
			rollback tran
			goto fin
		END
	END

	/********Si la fecha cambió en cuanto a meses, eliminar la programación para el material**************/
	--if(
	--	(datepart(mm,@fechaProgIni) <> datepart(mm,@pFechaProgramaInicio)) OR
	
	--	(datepart(mm,@fechaProgFin) <> datepart(mm,@pFechaProgramaFin))
	--)
	--begin 

	--	delete OT_SolicitudPrograma
	--	WHERE IdOTSolicitudMaterial= @pIdOTSolicitudMaterial

	--	if @@error <> 0
	--	begin 
	--		rollback tran
	--		goto fin
	--	end
	--end

	
		delete OT_SolicitudPrograma
		WHERE IdOTSolicitudMaterial= @pIdOTSolicitudMaterial

		if @@error <> 0
		begin 
			rollback tran
			goto fin
		end

	update OT_SolicitudMaterial
	set cantidad = @pCantidad,
		IdSCMaterial = @pIdSCMaterial,
		ModificadoPor = @pModificadoPor,
		ModificadoEl = getdate(),		
		FechaProgramaInicio =@pFechaProgramaInicio,
		FechaProgramaFin =@pFechaProgramaFin,
		Comentarios = @pComentarios
	where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	/***********Actualizar encabezado de la OT******************************/
	--update OT_Solicitud
	--set FechaInicio = (select min (FechaProgramaInicio) from OT_SolicitudMaterial s1 where  s1.IdOTSolicitud = @IdOTSolicitud ),
	--FechaFin = (select max (FechaProgramaFin) from OT_SolicitudMaterial s1 where  s1.IdOTSolicitud = @IdOTSolicitud )
	--where IdOTSolicitud = @IdOTSolicitud

	--if @@error <> 0
	--begin 
	--	rollback tran
	--	goto fin
	--end

	/***************Actualizar plazo ejecución**************/
	--update OT_Solicitud
	--set PlazoEjecucion = isnull(Datediff(dd,FechaInicio,FechaFin),0)
	--where IdOTSolicitud = @IdOTSolicitud

	--if @@error <> 0
	--begin 
	--	rollback tran
	--	goto fin
	--END

	/***********SI captura fechas de programación de rango de un mes, insertar automáticamente la programación**************/
	if(
		@pFechaProgramaInicio is not null  and
		@pTipoUsuario in( 1,2) and --Subcontratista
		datepart(yy,@pFechaProgramaInicio) = datepart(yy,@pFechaProgramaFin) AND
		datepart(mm,@pFechaProgramaInicio) = datepart(mm,@pFechaProgramaFin)
	)
	begin

		declare @idAux int = 0

		select @idAux = isnull(max(IdOTSolicitudPrograma),0) + 1
		from OT_SolicitudPrograma

		insert into OT_SolicitudPrograma(IdOTSolicitudPrograma,IdOTSolicitudMaterial,Anio,Mes,Cantidad,
		CreadoPor,CreadoEl,ModificadoPor,ModificadoEl)
		select @idAux,@pIdOTSolicitudMaterial,datepart(yy,@pFechaProgramaInicio) ,datepart(mm,@pFechaProgramaInicio),@pCantidad,
		@pModificadoPor,getdate(),null,null

		if @@error <> 0
		begin 
			rollback tran
			goto fin
		END
		
	end
    
	/************Guardar el cambio en la bitacora***********/

	DECLARE @IdOTBitacoraId INT

	SELECT @IdOTBitacoraId = ISNULL(MAX(IdOTBitacoraId),0)+1
	FROM OT_SolicitudMaterialBitacora

	INSERT INTO dbo.OT_SolicitudMaterialBitacora
	(
	    IdOTBitacoraId,
	    IdOTSolicitudMaterial,
	    Cantidad,
	    FechaProgramacionInicio,
	    FechaProgramacionFin,
	    CreadoPor,
	    CreadoEl,
		IdTipoUsuario
	)
	VALUES
	(   @IdOTBitacoraId,         -- IdOTBitacoraId - int
	    @pIdOTSolicitudMaterial,         -- IdOTSolicitudMaterial - int
	    @pCantidad,      -- Cantidad - decimal(14, 2)
	    @pFechaProgramaInicio, -- FechaProgramacionInicio - datetime
	    @pFechaProgramaFin, -- FechaProgramacionFin - datetime
	    @pModificadoPor,         -- CreadoPor - int
	    GETDATE() , -- CreadoEl - datetime
		@pTipoUsuario
	 )



	if @@error <> 0
	begin 
		rollback tran
		goto fin
	END

	/********Si se está realizando la edición en estatus Propuesta por Subcontratista, marcar estatus como Modificada Por Operador(Sin Confirmar)*/
	update OT_Solicitud
	set IdOTEstatus = 10,
	ModificadoPor = @pModificadoPor,
	ModificadoEl = getdate()
	where IdOTSolicitud = @idOTSolicitud and
	idOtEstatus = 3

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	END

	
	exec [dbo].[p_OT_SolicitudPrograma_Ajuste_Upd] @idOTSolicitud
	
    if @@error <> 0
	begin 
		rollback tran
		goto fin
	END

	commit tran

	fin:




