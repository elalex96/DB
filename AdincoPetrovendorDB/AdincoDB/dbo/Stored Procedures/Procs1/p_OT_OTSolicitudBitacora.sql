create procedure p_OT_OTSolicitudBitacora
@pIdOTSolicitud int
as
begin

	select 
		IdOTSolicitud
		,CreadoEl 
		,Descripcion as 'Comentarios'
		,UsuarioAdincoId
		,UsuarioPetroId
		,(case when UsuarioAdincoId is null 
		then (select nombre COLLATE SQL_Latin1_General_CP1_CI_AS from Petrovendor..S_Usuario u join 
		OT_SolicitudBitacora as b 
		on u.IdUsuario = b.UsuarioPetroId
				where b.IdOTSolicitud = @pIdOTSolicitud and b.IdOTBitacora = otb.IdOTBitacora)
		else (select nombre COLLATE SQL_Latin1_General_CP1_CI_AS from AP_Usuario u join 
				OT_SolicitudBitacora as b 
				on u.UsuarioID = b.UsuarioAdincoId 
				where b.IdOTSolicitud = @pIdOTSolicitud and b.IdOTBitacora = otb.IdOTBitacora)
		 end ) as 'Usuario' 
	from 
	OT_SolicitudBitacora as otb
	where IdOTSolicitud = @pIdOTSolicitud
	order by CreadoEl desc
end