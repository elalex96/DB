create proc p_OT_SolicituAdicional_Aprobada
@pIdOTSolicitudAdicional int,
@pUsuarioId int,
@pError varchar(250) out
as

	begin try
		declare @IdOTBitacora int,
			@IdOTSolicitudMaterial int,
			@IdOTSolicitud int


		select @IdOTSolicitud = IdOTSolicitud
		from OT_SolicitudAdicional
		where IdOTSolicitudAdicional = @pIdOTSolicitudAdicional
			

		begin tran
		
		--Registrar en bitácora cada movimiento
		select @IdOTBitacora = isnull(max(IdOTBitacora),0) 
		from OT_SolicitudBitacora
		insert into OT_SolicitudBitacora(
			IdOTBitacora,IdOTSolicitud,FlujoAprobacionTareaId,Descripcion,CreadoEl,UsuarioAdincoId,UsuarioPetroId,IdTipoMovimiento
		)
		select @IdOTBitacora + ROW_NUMBER() OVER(ORDER BY sam.IdOTSolicitudAdicional ASC) ,sm.IdOTSolicitud,NULL,
			'Se aplicaron cambios de [solicitud-adicional]:'+cast(sam.IdOTSolicitudAdicional as varchar)
			+',[concepto]:'+isnull(mat.Concepto,'')+',[cantidad-ant]:'+cast(isnull(sm.Cantidad,0) as varchar)+'[cantidad-nueva]:'+cast(isnull(sam.Cantidad,0) as varchar),
			getdate(),@pUsuarioId,null,10
		from OT_SolicitudMaterial sm
		INNER JOIN OT_SolicitudAdicional sa on sa.IdOTSolicitud = sm.IdOTSolicitud
		inner join OT_SolicitudAdicionalMaterial  sam on sam.IdOTSolicitudAdicional = sa.IdOTSolicitudAdicional and
													sam.IdSCMaterial = sm.IdSCMaterial
		INNER JOIN SC_Materiales mat on mat.IdSCMaterial = sam.IdSCMaterial
		where sam.IdOTSolicitudAdicional = @pIdOTSolicitudAdicional


		--Actualiazar servicios ya existentes
		update OT_SolicitudMaterial
		SET Cantidad = sam.Cantidad,
			FechaProgramaInicio = sam.FechaProgramaInicio,
			FechaProgramaFin = sam.FechaProgramaFin
		from OT_SolicitudMaterial sm
		INNER JOIN OT_SolicitudAdicional sa on sa.IdOTSolicitud = sm.IdOTSolicitud
		inner join OT_SolicitudAdicionalMaterial  sam on sam.IdOTSolicitudAdicional = sa.IdOTSolicitudAdicional and
													sam.IdSCMaterial = sm.IdSCMaterial
		where sam.IdOTSolicitudAdicional = @pIdOTSolicitudAdicional

		select @IdOTSolicitudMaterial = isnull(max(IdOTSolicitudMaterial),0)
		from OT_SolicitudMaterial


		--Registrar en bitácora cada movimiento
		select @IdOTBitacora = isnull(max(IdOTBitacora),0) 
		from OT_SolicitudBitacora

		insert into OT_SolicitudBitacora(
			IdOTBitacora,IdOTSolicitud,FlujoAprobacionTareaId,Descripcion,CreadoEl,UsuarioAdincoId,UsuarioPetroId,IdTipoMovimiento
		)
		select @IdOTBitacora + ROW_NUMBER() OVER(ORDER BY sam.IdOTSolicitudAdicional ASC) ,sa.IdOTSolicitud,NULL,
			'Se aplicaron cambios de [solicitud-adicional]:'+cast(sam.IdOTSolicitudAdicional as varchar)
			+',[concepto]:'+isnull(mat.Concepto,'')+',[cantidad-nueva]:'+cast(isnull(sam.Cantidad,0) as varchar),
			getdate(),@pUsuarioId,null,10
		from OT_SolicitudAdicional sa 
		inner join OT_SolicitudAdicionalMaterial  sam on sam.IdOTSolicitudAdicional = sa.IdOTSolicitudAdicional 
		INNER JOIN SC_Materiales mat on mat.IdSCMaterial = sam.IdSCMaterial
		where sam.IdOTSolicitudAdicional = @pIdOTSolicitudAdicional
		and not exists (
			select 1
			from OT_SolicitudMaterial s1
			where s1.IdOTSolicitud = sa.IdOTSolicitud AND
			s1.IdSCMaterial = sam.IdSCMaterial
		)

		--Insertar registros existentes
		insert into OT_SolicitudMaterial(
			IdOTSolicitudMaterial,IdOTSolicitud,IdSCMaterial,Cantidad,CreadoPor,
			CreadoEl,ModificadoPor,ModificadoEl,IdServicio,FechaProgramaInicio,
			FechaProgramaFin,Comentarios
		)
		select @IdOTSolicitudMaterial+ROW_NUMBER() OVER(ORDER BY sam.IdOTSolicitudAdicional ASC),sa.IdOTSolicitud,sam.IdSCMaterial,sam.Cantidad,@pUsuarioId,
		getdate(),null,null,null,sam.FechaProgramaInicio,sam.FechaProgramaFin,'Cambios aplicados automáticamente por [solicitud-adicional]:'+ cast(sa.IdOTSolicitudAdicional as varchar) 
		from OT_SolicitudAdicional sa 
		inner join OT_SolicitudAdicionalMaterial  sam on sam.IdOTSolicitudAdicional = sa.IdOTSolicitudAdicional 
		where sam.IdOTSolicitudAdicional = @pIdOTSolicitudAdicional
		and not exists (
			select 1
			from OT_SolicitudMaterial s1
			where s1.IdOTSolicitud = sa.IdOTSolicitud AND
			s1.IdSCMaterial = sam.IdSCMaterial
		)

		exec p_OT_SolicitudPrograma_Ajuste_Upd  @IdOTSolicitud

		commit tran
	end try
	begin catch
		rollback tran
		set @pError = ERROR_MESSAGE()
	end catch