Create proc p_OT_ActualizarProgramaBitacoraSemana
@pIdOTProgramaBitacoraSemana	int,
@pFechaRegistro	datetime,
@pComentarios	varchar(500)
as

	
	update [OT_ProgramaBitacoraSemana]
	set 
		Comentarios = @pComentarios
	where IdOTProgramaBitacoraSemana = @pIdOTProgramaBitacoraSemana

	
