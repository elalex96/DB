
create proc p_OT_SolicitudAdicional_Combo
@pContratoId int,
@pUsuarioId int
as

	select ot.Folio,
		ot.IdOTSolicitud,
		ot.Objeto,
		cc.CentroCosto,
		ot.CreadoEl
	from OT_Solicitud ot
	inner join SC_SubContrato sc on sc.IdSubContrato = ot.IdSubContrato
	inner join Petrovendor..CC_CentroCosto cc on cc.IdCentroCosto = ot.IdCentroCosto
	where sc.IdContrato = @pContratoId and IdOTEstatus in (5,6) 