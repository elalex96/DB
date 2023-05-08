create proc spOT_Solicitud_Sel
(
	@IdOTSolicitud	int
)
as
begin

	select	Folio,
			FechaInicio,
			FechaFin,
			IdCentroCosto,
			Objeto
	from	OT_Solicitud
	where	IdOTSolicitud =		@IdOTSolicitud

	--select * from CO_CentroCostos where IdCentroCostos = 863

end