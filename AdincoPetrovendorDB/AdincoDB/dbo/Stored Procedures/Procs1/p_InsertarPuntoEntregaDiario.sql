Create Proc p_InsertarPuntoEntregaDiario 
@pPuntoEntregaID	int,
@pFecha	date,
@pEventos	varchar(3000),
@pCreadoPor	int
as

	if not exists (
		select 1
		from PR_PuntoEntregaDiario
		where PuntoEntregaID = @pPuntoEntregaID and
		Fecha = @pFecha

	)
	begin
		insert into PR_PuntoEntregaDiario (
			PuntoEntregaID,Fecha,Presion,Temperatura,Eventos,
			Dato,Nominal,Instantaneo,CreadoPor,
			CreadoEl,ModificadoPor,ModificadoEl
		)
		select @pPuntoEntregaID,@pFecha,null,null,@pEventos,
		null,null,null,@pCreadoPor,
		getdate(),null,null
	End
	Else
	Begin
		update PR_PuntoEntregaDiario
		set Eventos = @pEventos
		where PuntoEntregaID = @pPuntoEntregaID and Fecha = @pFecha
	End