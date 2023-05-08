CREATE Proc p_OT_ActualizarConfigurador
@pIdContratista int,
@pIdContrato int,
@pDiasToleranciaCapAct int,
@pProgarmaInicialPorOperador bit,
@pPermitirAprobarSubcontratista bit,
@pPermitirConvenios bit,
@pPermitirOTExcedida bit,
@pDecimales tinyint  ,
@pPermitirAceptacionAut BIT
as

  DECLARE @IdUsuarioTaskPetro INT = 0;

	if not exists (
		select 1
		from OT_Configurador
		where IdContratista = @pIdContratista and
		IdContrato = @pIdContrato
	)
	Begin 
		insert into OT_Configurador(IdContratista,IdContrato,DiasToleranciaCapAct,ProgarmaInicialPorOperador,
		PermitirAprobarSubcontratista,PermitirConvenios,PermitirOTExcedida, Decimales, PermitirAceptacionAut)
		values(@pIdContratista,@pIdContrato,@pDiasToleranciaCapAct,@pProgarmaInicialPorOperador,
		@pPermitirAprobarSubcontratista,@pPermitirConvenios,@pPermitirOTExcedida,@pDecimales,@pPermitirAceptacionAut)
	End
	Else
	Begin
		update OT_Configurador
		set DiasToleranciaCapAct = @pDiasToleranciaCapAct,
			ProgarmaInicialPorOperador = @pProgarmaInicialPorOperador,
			PermitirAprobarSubcontratista=@pPermitirAprobarSubcontratista,
			PermitirConvenios=@pPermitirConvenios,
			PermitirOTExcedida=@pPermitirOTExcedida,
			Decimales = @pDecimales,
			PermitirAceptacionAut = @pPermitirAceptacionAut
		where IdContratista = @pIdContratista and
		IdContrato = @pIdContrato

	End
		
		select @IdUsuarioTaskPetro = IdUsuario
		from petrovendor..S_Usuario
		where correo = 'control.obra@adinco.mx'

		IF(@IdUsuarioTaskPetro > 0)
		BEGIN
		update OT_Configurador
		set IdUsuarioTaskPetro = @IdUsuarioTaskPetro
		/*ESTE UPDATE ESTÁ SIN WHERE YA QUE DEBE DE APLICAR EL MISMO EMAIL PARA TODOS LOS CONTRATOS DEL CONFIGURADOR*/
		END






