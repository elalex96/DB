create proc p_CO_InsertarProgramaImplementaProgramacion
@IdProgramaImplementaProgramacion	int,
@IdProgramaImplementaAccion	int,
@FechaInicioProgramada	datetime,
@FechaFinProgramada	datetime,
@FechaInicioImplementa	datetime,
@FechaFinImplementa	datetime,
@RevisadoPor	int,
@CreadoPor	int
as

	select @IdProgramaImplementaProgramacion= isnull(max(IdProgramaImplementaProgramacion),0) + 1
	from [CO_ProgramaImplementaProgramacion]

	
	insert into [CO_ProgramaImplementaProgramacion](
		IdProgramaImplementaProgramacion,IdProgramaImplementaAccion,FechaInicioProgramada,
		FechaFinProgramada,FechaInicioImplementa,FechaFinImplementa,
		RevisadoPor,CreadoEl,CreadoPor
	)
	values(
		@IdProgramaImplementaProgramacion,@IdProgramaImplementaAccion,@FechaInicioProgramada,
		@FechaFinProgramada,@FechaInicioImplementa,@FechaFinImplementa,
		@RevisadoPor,GETDATE(),@CreadoPor
	)