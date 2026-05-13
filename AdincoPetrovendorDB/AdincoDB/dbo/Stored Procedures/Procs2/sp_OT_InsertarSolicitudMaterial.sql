CREATE Proc [dbo].[sp_OT_InsertarSolicitudMaterial]
@pIdOTSolicitudMaterial int out,
@pIdOTSolicitud int,
@pIdSCMaterial int,
@pCantidad decimal(14,2),
@pCreadoPor int,
@pIdServicio int=null,
@pFechaProgramaInicio datetime=null,
@pFechaProgramaFin datetime=null,
@pTipoUsuario int,
@pComentarios varchar(300)=null

as

	select @pIdOTSolicitudMaterial = isnull(max(IdOTSolicitudMaterial),0)+1		
	from OT_SolicitudMaterial


	Begin tran

	insert into OT_SolicitudMaterial(IdOTSolicitudMaterial,IdOTSolicitud,IdSCMaterial,Cantidad,
	CreadoPor,CreadoEl,IdServicio,FechaProgramaInicio,FechaProgramaFin,Comentarios)
	select @pIdOTSolicitudMaterial,@pIdOTSolicitud,@pIdSCMaterial,@pCantidad,@pCreadoPor,getdate(),@pIdServicio,
	@pFechaProgramaInicio,@pFechaProgramaFin,@pComentarios

	

	if @@error <> 0
	begin 
			rollback tran
			goto fin
	end

	update OT_Solicitud
	set PlazoEjecucion = isnull(Datediff(dd,FechaInicio,FechaFin),0)
	where IdOTSolicitud = @pIdOTSolicitud

	if @@error <> 0
	begin 
			rollback tran
			goto fin
	end

	/********Si se está realizando la edición en estatus Propuesta por Subcontratista, marcar estatus como Modificada Por Operador(Sin Confirmar)*/
	update OT_Solicitud
	set IdOTEstatus = 10,
	ModificadoPor = @pCreadoPor,
	ModificadoEl = getdate()
	where IdOTSolicitud = @pIdOTSolicitud and
	idOtEstatus = 3

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	END

	exec [dbo].[p_OT_SolicitudPrograma_Ajuste_Upd] @pIdOTSolicitud

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	END


	select
		@pFechaProgramaInicio = MIN(FechaProgramaInicio),
		@pFechaProgramaFin = MAX(FechaProgramaFin)
	from OT_SolicitudMaterial
	where IdOTSolicitud = @pIdOTSolicitud

	if @@error <> 0
	begin 
			rollback tran
		goto fin
	end

	update OT_Solicitud
	set FechaInicio = (select min (FechaProgramaInicio) from OT_SolicitudMaterial s1 where  s1.IdOTSolicitud = @pIdOTSolicitud ),
	FechaFin = (select max (FechaProgramaFin) from OT_SolicitudMaterial s1 where  s1.IdOTSolicitud = @pIdOTSolicitud )
	where IdOTSolicitud = @pIdOTSolicitud


	if @@error <> 0
	begin 
			rollback tran
		goto fin
	end

		commit tran

		fin:



