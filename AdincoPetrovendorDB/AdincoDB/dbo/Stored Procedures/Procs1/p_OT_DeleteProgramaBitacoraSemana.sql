Create Proc p_OT_DeleteProgramaBitacoraSemana
@pIdOTProgramaBitacoraSemana	int
as

	delete [OT_ProgramaBitacoraSemana]
	where IdOTProgramaBitacoraSemana = @pIdOTProgramaBitacoraSemana
