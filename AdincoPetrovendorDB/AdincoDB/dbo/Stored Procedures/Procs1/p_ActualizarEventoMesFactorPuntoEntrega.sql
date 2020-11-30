Create proc p_ActualizarEventoMesFactorPuntoEntrega
@pPuntoEntregaID int,
@pMes date,
@pModificadoPor int,
@pEventos varchar(3000)
as

	update PR_FactorPuntoEntrega
	set Eventos = @pEventos,
		ModificadoPor = @pModificadoPor,
		ModificadoEn = getdate()
	where PuntoEntregaID = @pPuntoEntregaID and
	Mes = @pMes