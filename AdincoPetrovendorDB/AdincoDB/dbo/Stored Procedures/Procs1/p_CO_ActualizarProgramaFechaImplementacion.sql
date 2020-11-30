CREATE proc p_CO_ActualizarProgramaFechaImplementacion
@pIdProgramaImplementaProgramacion int,
@pFechaInicioImplementa datetime,
@pFechaFinImplementa datetime,
@pCreadoPor int
as

	update CO_ProgramaImplementaProgramacion
	set FechaInicioImplementa = @pFechaInicioImplementa,
		FechaFinImplementa = dateadd(minute,59,dateadd(hour,23,@pFechaFinImplementa)),
		RevisadoPor = @pCreadoPor
	where IdProgramaImplementaProgramacion = @pIdProgramaImplementaProgramacion