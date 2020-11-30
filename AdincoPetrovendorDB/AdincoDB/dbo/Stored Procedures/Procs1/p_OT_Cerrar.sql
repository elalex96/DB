CREATE PROC p_OT_Cerrar
	@pIdOTSolicitud int,
	@pUsuarioId		int,
	@pIdContrato	int,
	@pComentario varchar(max) = null
as
begin

	declare @descripcion varchar(150)
	
	create table #tmp
	(
		CreadorOT				int,
		AprobadorOT				int,
		ValidadorCantOT			int,
		GeneradorEstimacion		int,
		AceptacionServicioOT	int,
		AdmonContratos				int
	)

	insert into #tmp
	exec p_OT_FlujoAprobacion_Acceso 1,@pIdContrato,@pUsuarioId,@pIdOTSolicitud

	if exists(select AprobadorOT, CreadorOT from #tmp where AprobadorOT =1 and CreadorOT = 1)
	begin
		select @descripcion = Descripcion
		from OT_Estatus
		where IdOtEstatus = 12

		BEGIN TRY  

			begin tran
			update OT_Solicitud
			set IdOTEstatusAnt = IdOTEstatus,
				IdOTEstatus = 12,			
				ModificadoPor = @pUsuarioId,
				ModificadoEl = getdate()
			where IdOTSolicitud = @pIdOTSolicitud


			if @pComentario is not null
			begin
				set @descripcion = isnull(@descripcion,'') +' Motivo: ' + isnull(@pComentario,'')
			end

			exec p_OT_SolicitudBitacora_ins @pIdOTSolicitud,null,@descripcion,@pUsuarioId,null

			exec p_OT_CorreoProgramacion_Flujo @pIdOTSolicitud,@pUsuarioId,'',12

			commit tran
     
		END TRY  
		BEGIN CATCH  
			rollback tran
			select Error = error_message()
		 
		END CATCH  
	end
	else
	begin
		select Error = 'No se posible cerrar la OT, no tienes los permisos necesarios'
	end	
end