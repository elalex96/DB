----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE Proc p_OT_ActualizarConfigurador
@pIdContratista int,
@pIdContrato int,
@pDiasToleranciaCapAct tinyint,
@pProgarmaInicialPorOperador bit,
@pPermitirAprobarSubcontratista bit,
@pPermitirConvenios bit,
@pPermitirOTExcedida bit
as

	if not exists (
		select 1
		from OT_Configurador
		where IdContratista = @pIdContratista and
		IdContrato = @pIdContrato
	)
	Begin 
		insert into OT_Configurador(IdContratista,IdContrato,DiasToleranciaCapAct,ProgarmaInicialPorOperador,
		PermitirAprobarSubcontratista,PermitirConvenios,PermitirOTExcedida)
		values(@pIdContratista,@pIdContrato,@pDiasToleranciaCapAct,@pProgarmaInicialPorOperador,
		@pPermitirAprobarSubcontratista,@pPermitirConvenios,@pPermitirOTExcedida)
	End
	Else
	Begin
		update OT_Configurador
		set DiasToleranciaCapAct = @pDiasToleranciaCapAct,
			ProgarmaInicialPorOperador = @pProgarmaInicialPorOperador,
			PermitirAprobarSubcontratista=@pPermitirAprobarSubcontratista,PermitirConvenios=@pPermitirConvenios,PermitirOTExcedida=@pPermitirOTExcedida
		where IdContratista = @pIdContratista and
		IdContrato = @pIdContrato
	End


	



