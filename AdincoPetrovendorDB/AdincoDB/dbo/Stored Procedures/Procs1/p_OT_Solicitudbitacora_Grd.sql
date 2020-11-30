-- p_OT_Solicitudbitacora_Grd 27
CREATE proc p_OT_Solicitudbitacora_Grd
@pIdOTSolicitud int
as

	select IdOTBitacora,
		IdOTSolicitud,
		FlujoAprobacionTareaId,
		Descripcion = case when t.Id is not null then isnull(t.Descripcion,'') + ' : ' + isnull(b.Descripcion,'')
						   when t.Id is null then isnull(b.Descripcion,'')
						end ,
		b.CreadoEl,
		UsuarioAdincoId,
		UsuarioPetroId,
		Usuario = case 
						when b.UsuarioAdincoId is not null then u.Usuario collate Modern_Spanish_CI_AS
						when b.UsuarioPetroId is not null then up.Nombre collate Modern_Spanish_CI_AS
				  end
	from OT_SolicitudBitacora b
	left join AP_Usuario u on u.UsuarioId = b.UsuarioAdincoId
	left join petrovendor..S_Usuario up on up.IdUsuario = b.UsuarioPetroId
	left join OT_SolicitudBitacoraTipo t on t.Id = b.IdTipoMovimiento
	where IdOTSolicitud = @pIdOTSolicitud
	order by b.CreadoEl desc

