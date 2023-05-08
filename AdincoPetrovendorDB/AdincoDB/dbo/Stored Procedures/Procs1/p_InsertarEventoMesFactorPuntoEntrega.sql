Create proc p_InsertarEventoMesFactorPuntoEntrega
@pPuntoEntregaID int,
@pMes date,
@pModificadoPor int,
@pEventos varchar(3000)
as

	if not exists (
		select 1
		from PR_FactorPuntoEntrega
		where PuntoEntregaID = @pPuntoEntregaID and
		Mes = @pMes
	)
	begin
		insert into PR_FactorPuntoEntrega(
		PuntoEntregaID,		Mes,			ModificadoPor,		
		ModificadoEn,	Eventos
		)
		select @pPuntoEntregaID,@pMes,@pModificadoPor,
		getdate(),			@pEventos

	end
	Else
	Begin
		update PR_FactorPuntoEntrega
		set Eventos = @pEventos,
			ModificadoPor = @pModificadoPor,
			ModificadoEn = getdate()
		where PuntoEntregaID = @pPuntoEntregaID and
		Mes = @pMes

	End