
-- p_OT_SolicitudAdicional_Sel 1,0,10
create proc p_OT_SolicitudAdicional_Sel
@pIdOTSolicitudAdicional int,
@pIdOTSolicitud int,
@pUsuarioId int
as

	select 
		FolioSolicitud = s.IdOTSolicitudAdicional,
		FechaSolicitud = s.CreadoEl,
		OT.IdOTSolicitud,
		OT.Folio,
		CC = cc.CentroCosto,
		ot.CreadoEl,
		ot.FechaInicio,
		ot.FechaFin,
		Moneda = ISNULL(TipoMonedaCorto,''),
		Contrato = sc.NumeroSubContrato,
		Proveedor = prov.RazonSocial,
		ot.Objeto,
		s.Motivo,
		S.IdEstatusAdicional,
		Estatus = e.Nombre

	from OT_Solicitud ot
	inner join SC_SubContrato sc on sc.IdSubContrato = ot.IdSubContrato
	inner join PV_Subcontratista prov on prov.IdSubcontratista = sc.idSubcontratista
	inner join Petrovendor..CC_CentroCosto cc on cc.IdCentroCosto = ot.IdCentroCosto
	inner join Petrovendor..PV_TipoMoneda m on m.IdMoneda = ot.IdMoneda
	inner join [dbo].[AP_UsuarioCentroCosto] ucc on ucc.IdUsuario = @pUsuarioId and
											ucc.IdCentroCosto = ot.IdCentroCosto
	inner JOIN [OT_SolicitudAdicional] s on s.IdOTSolicitud = ot.IdOTSolicitud and
											s.IdOTSolicitudAdicional = @pIdOTSolicitudAdicional
	inner join OT_EstatusAdicional e on e.IdEstatusAdicional = s.IdEstatusAdicional
	where ot.IdOTSolicitud = s.IdOTSolicitud