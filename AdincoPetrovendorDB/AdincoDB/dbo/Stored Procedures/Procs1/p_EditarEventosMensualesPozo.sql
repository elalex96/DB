Create proc p_EditarEventosMensualesPozo
@pIdPozo	int,
@pMesReporte	date,
@pEventos	varchar(3000),
@pCreadoPor	int
as

	update PR_EventosMensualesPozo
	set Eventos = @pEventos,
		ModificadoPor = @pCreadoPor,
		ModificadoEl = getdate()
	where IdPozo = @pIdPozo and
	MesReporte = @pMesReporte