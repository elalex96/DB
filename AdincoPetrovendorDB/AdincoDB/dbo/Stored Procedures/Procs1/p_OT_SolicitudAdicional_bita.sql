-- p_OT_SolicitudAdicional_bita 3
create proc p_OT_SolicitudAdicional_bita
@pIdOTSolicitudAdicional int
as

	select sa.IdOTSolicitudAdicional,
			Descripcion = isnull(ea.Nombre,'') + 
							case when isnull(sab.Descripcion,'') != '' then ':' else '' end +isnull(sab.Descripcion,''),
			sab.CreadoEl,
			Usuario = u.Usuario
	from OT_SolicitudAdicional sa
	inner join OT_SolicitudAdicionalBitacora sab on sab.IdOTSolicitudAdicional = sa.IdOTSolicitudAdicional
	inner join AP_Usuario u on u.UsuarioId = sab.CreadoPor
	left join OT_EstatusAdicional ea on ea.IdEstatusAdicional = sab.IdOTEstatusAdicional
	where sab.IdOTSolicitudAdicional = @pIdOTSolicitudAdicional
	order by sab.CreadoEl desc