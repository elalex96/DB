Create proc p_InsertarEventosMensualesPozo
@pIdPozo	int,
@pMesReporte	date,
@pEventos	varchar(3000),
@pCreadoPor	int
as

	insert into PR_EventosMensualesPozo(
		IdPozo,			MesReporte,		Eventos,		CreadoPor,CreadoEl,
		ModificadoPor,ModificadoEl
	)
	values(
		@pIdPozo,@pMesReporte,@pEventos,@pCreadoPor,getdate(),
		null,null
	)