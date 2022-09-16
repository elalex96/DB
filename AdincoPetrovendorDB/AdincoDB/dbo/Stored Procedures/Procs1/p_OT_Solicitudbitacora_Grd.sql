-- p_OT_Solicitudbitacora_Grd 27
create proc [dbo].[p_OT_Solicitudbitacora_Grd]
@pIdOTSolicitud int
as

	select IdOTBitacora,
		IdOTSolicitud,
		FlujoAprobacionTareaId,
		Descripcion = case when OT_SolicitudBitacoraTipo.Id is not null then isnull(OT_SolicitudBitacoraTipo.Descripcion,'') + ' : ' + isnull(OT_SolicitudBitacora.Descripcion,'')
						   when OT_SolicitudBitacoraTipo.Id is null then isnull(OT_SolicitudBitacora.Descripcion,'')
						end ,
		OT_SolicitudBitacora.CreadoEl,
		UsuarioAdincoId,
		UsuarioPetroId,
		Usuario = case 
						when OT_SolicitudBitacora.UsuarioAdincoId is not null then AP_Usuario.Usuario collate Modern_Spanish_CI_AS
						when OT_SolicitudBitacora.UsuarioPetroId is not null then S_Usuario.Nombre collate Modern_Spanish_CI_AS
				  end
	from OT_SolicitudBitacora (NOLOCK)
	left join AP_Usuario (NOLOCK) on OT_SolicitudBitacora.UsuarioAdincoId = AP_Usuario.UsuarioId 
	left join petrovendor..S_Usuario (NOLOCK) on OT_SolicitudBitacora.UsuarioPetroId = S_Usuario.IdUsuario 
	left join OT_SolicitudBitacoraTipo (NOLOCK) on OT_SolicitudBitacora.IdTipoMovimiento = OT_SolicitudBitacoraTipo.Id  
	where IdOTSolicitud = @pIdOTSolicitud
	order by OT_SolicitudBitacora.CreadoEl desc

GO


