
-- p_OT_SolicitudAdicional_List 10,3
create proc p_OT_SolicitudAdicional_List
@pUsuarioId int,
@pIdContrato int
as

	select FolioSolicitud = s.IdOTSolicitudAdicional,
			ot.IdOTSolicitud,
			FolioOT = ot.Folio,
			FecaRegistro = s.CreadoEl,
			Estatus = ea.Nombre,
			Contrato =sc.NumeroSubContrato,
			Proveedor = prov.RazonSocial
	from OT_SolicitudAdicional s
	inner join OT_Solicitud ot on ot.IdOTSolicitud = s.IdOTSolicitud
	inner join SC_SubContrato sc on sc.IdSubContrato = ot.IdSubContrato
	INNER JOIN PV_Subcontratista prov on prov.IdSubcontratista = SC.IdSubContratista
	INNER JOIN AP_UsuarioCentroCosto ucc on ucc.IdCentroCosto = ot.IdCentroCosto and
										ucc.IdUsuario = @pUsuarioId
	inner join OT_EstatusAdicional ea on ea.IdEstatusAdicional = s.IdEstatusAdicional
	where sc.IdContrato = @pIdContrato
	order by s.IdOTSolicitudAdicional desc