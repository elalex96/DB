Create Proc p_CO_ActualizarProgramaImplementa
@pIdProgramaImplementa	int,
@pIdContrato	int,
@pIdTipoPrograma	tinyint,
@pFechaInicio	datetime,
@pFechaFin	datetime,
@pCreadoPor	int
as

	update [CO_ProgramaImplementa]
	set [IdTipoPrograma] = @pIdTipoPrograma
			   ,[FechaInicio] = @pFechaInicio
			   ,[FechaFin] =  @pFechaFin			  
			   ,[ModificadoEl] = getdate()
			   ,[ModificadoPor] = @pCreadoPor
	where IdProgramaImplementa = @pIdProgramaImplementa
			   
