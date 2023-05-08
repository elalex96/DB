CREATE Proc p_OT_ObtenerConfigurador
@pIdContratista int,
@pIdContrato int
as
Begin
	

	select IdContratista,
		IdContrato,
		DiasToleranciaCapAct,
		ProgarmaInicialPorOperador,
		Decimales,
		PermitirAprobarSubcontratista,
	PermitirConvenios,
	PermitirOTExcedida,
	PermitirAceptacionAut
	from OT_Configurador
	where IdContratista = @pIdContratista and
	IdContrato = @pIdContrato


End


