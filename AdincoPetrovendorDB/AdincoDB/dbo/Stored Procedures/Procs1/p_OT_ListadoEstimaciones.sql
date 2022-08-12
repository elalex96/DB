CREATE PROCEDURE [dbo].[p_OT_ListadoEstimaciones]
	@pIdUsuario int ,
	@pIdContrato int = 0,
	@pIdCentroCostos int = 0
as
begin
	select		OT_Solicitud.Folio,
				OT_Estimacion.FechaCorteInicio,
				OT_Estimacion.FechaCorteFin,
				OT_Estimacion.CreadoEl,
				OT_Estimacion.Total,
				PV_TipoMoneda.TipoMonedaCorto,
				OT_Estimacion.IdPedidoGeneral as IdPedido,
				PV_Subcontratista.RazonSocial,
				OT_Estimacion.IdOTEstimacion
	from		Adinco..OT_Estimacion			(NOLOCK)
	inner join	OT_Solicitud					(NOLOCK) on OT_Estimacion.IdOTSolicitud	= OT_Solicitud.IdOTSolicitud
	inner join	PV_TipoMoneda					(NOLOCK) on OT_Solicitud.IdMoneda			= PV_TipoMoneda.IdMoneda
	inner join	SC_Subcontrato					(NOLOCK) on SC_Subcontrato.IdSubContrato		= OT_Solicitud.IdSubcontrato	
	inner join	PV_Subcontratista				(NOLOCK) on PV_Subcontratista.IdSubcontratista	= SC_Subcontrato.IdSubcontratista	
	inner join	Petrovendor..CC_CentroCosto 	(NOLOCK) on OT_Solicitud.IdCentroCosto	= CC_CentroCosto.IdCentroCosto
	inner join	AP_UsuarioCentroCosto			(NOLOCK) on CC_CentroCosto.IdCentroCosto		= AP_UsuarioCentroCosto.IdCentroCosto 
																and AP_UsuarioCentroCosto.IdUsuario = @pIdUsuario
	where ISNULL(OT_Estimacion.Cancelada, 0) =	0

end



