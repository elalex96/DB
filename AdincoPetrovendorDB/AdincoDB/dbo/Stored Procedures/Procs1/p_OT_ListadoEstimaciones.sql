
CREATE PROCEDURE p_OT_ListadoEstimaciones
	@pIdUsuario int ,
	@pIdContrato int = 0,
	@pIdCentroCostos int = 0
as
begin
	select		ots.Folio,
				ote.FechaCorteInicio,
				ote.FechaCorteFin,
				ote.CreadoEl,
				ote.Total,
				tm.TipoMonedaCorto,
				ote.IdPedidoGeneral as IdPedido,
				pv.RazonSocial,
				ote.IdOTEstimacion
	from		Adinco..OT_Estimacion ote
	inner join	OT_Solicitud				ots on ote.IdOTSolicitud	= ots.IdOTSolicitud
	inner join	PV_TipoMoneda				tm	on ots.IdMoneda			= tm.IdMoneda
	inner join	SC_Subcontrato				sc	on sc.IdSubContrato		= ots.IdSubcontrato	
	inner join	PV_Subcontratista			pv	on pv.IdSubcontratista	= sc.IdSubcontratista	
	inner join	Petrovendor..CC_CentroCosto cc	on ots.IdCentroCosto	= cc.IdCentroCosto
	inner join	AP_UsuarioCentroCosto		ucc on cc.IdCentroCosto		= ucc.IdCentroCosto and ucc.IdUsuario = @pIdUsuario
	where		ote.Cancelada				=	0
	or			ote.Cancelada				is null
end
	-- select * from Adinco..OT_Estimacion

	-- select * from OT_Solicitud


	-- select * from SC_Subcontrato

	-- select * from AP_UsuarioCentroCosto	

	-- select * from Petrovendor..CC_CentroCosto
