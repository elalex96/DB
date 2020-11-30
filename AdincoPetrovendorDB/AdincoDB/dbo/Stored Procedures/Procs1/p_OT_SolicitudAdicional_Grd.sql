
-- p_OT_SolicitudAdicional_Grd 8,47,10
create proc p_OT_SolicitudAdicional_Grd
@pIdOTSolicitudAdicional int,
@pIdOTSolicitud int,
@pUsuarioId int
as

	declare @idSubcontrato int

	select @idSubcontrato = IdSubContrato
	from OT_Solicitud
	where @pIdOTSolicitud = IdOTSolicitud

	select 
		IdOTSolicitudAdicional = @pIdOTSolicitudAdicional,
		m.IdSCMaterial,
		otm.IdOTSolicitudMaterial,
		m.Concepto,
		m.Descripcion,
		scCant.cantDisponibleSC,
		scCant.cantOcupadaOTS,
		cantOcupadaOT = scCant.cantOcupadaOT,
		Cantidad = isnull(osm.Cantidad,otm.Cantidad),
		FechaProgramaInicio = isnull(osm.FechaProgramaInicio,otm.FechaProgramaInicio),
		FechaProgramaFin = isnull(osm.FechaProgramaFin, otm.FechaProgramaFin),
		UsuarioId = @pUsuarioId
	from OT_Solicitud ot
	inner join SC_Materiales m on m.IdSubContrato = OT.IdSubContrato
	left join dbo.fn_Get_SC_Cantidad(@idSubcontrato,@pIdOTSolicitud) scCant on scCant.idOTSolicitud = ot.IdOTSolicitud and
																			scCant.idSCMaterial = m.IdSCMaterial
	left join OT_SolicitudMaterial otm on otm.IdSCMaterial = m.IdSCMaterial and
								otm.IdOTSolicitud = ot.IdOTSolicitud
	left join OT_SolicitudAdicionalMaterial osm on osm.IdOTSolicitudAdicional = @pIdOTSolicitudAdicional and
												osm.IdSCMaterial = m.IdSCMaterial
	left join OT_SolicitudAdicional sa on sa.IdOTSolicitudAdicional = @pIdOTSolicitudAdicional
	where ot.IdOTSolicitud = @pIdOTSolicitud 
	and
	(
		(sa.IdEstatusAdicional > 1 and isnull(osm.Id,0) > 0)OR
		sa.IdEstatusAdicional = 1
	)
	order by isnull(osm.Cantidad,otm.Cantidad) desc, otm.IdOTSolicitudMaterial desc,m.Concepto
										