Create proc p_EliminarEventosMensualesPozo
@pIdPozo	int,
@pMesReporte	date
as

	delete PR_EventosMensualesPozo	
	where IdPozo = @pIdPozo and
	MesReporte = @pMesReporte