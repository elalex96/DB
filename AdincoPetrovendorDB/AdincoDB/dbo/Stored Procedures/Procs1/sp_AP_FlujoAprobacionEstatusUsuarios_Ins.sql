CREATE proc sp_AP_FlujoAprobacionEstatusUsuarios_Ins
(
    
	@FlujoAprobacionEstatusUsuarioId	int,
	@FlujoAprobacionEstatusId			int,
	@UsuarioId							int,
	@ActivarNotificacion				bit=0
)
as
begin

	if exists(select * from AP_FlujoAprobacionEstatusUsuarios where UsuarioId = @UsuarioId and FlujoAprobacionEstatusId = @FlujoAprobacionEstatusId)
	begin
		select UsuarioId = @UsuarioId, FlujoAprobacionEstatusId= @FlujoAprobacionEstatusId
		exec sp_AP_FlujoAprobacionEstatusUsuarios_Del @UsuarioId, @FlujoAprobacionEstatusId
	end

	select	@FlujoAprobacionEstatusUsuarioId	=	isnull(max(FlujoAprobacionEstatusUsuarioId),0)+1 from AP_FlujoAprobacionEstatusUsuarios
	insert	into	AP_FlujoAprobacionEstatusUsuarios
				(
                    
					FlujoAprobacionEstatusUsuarioId,
					FlujoAprobacionEstatusId,
					UsuarioId,
					CreadoEl,
					ActivarNotificacion
				)

			values
				(
                    
					@FlujoAprobacionEstatusUsuarioId,
					@FlujoAprobacionEstatusId,
					@UsuarioId,
					GETDATE(),
					@ActivarNotificacion
				)
	

end


