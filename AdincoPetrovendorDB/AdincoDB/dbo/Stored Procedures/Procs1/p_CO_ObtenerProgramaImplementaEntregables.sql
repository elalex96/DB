

cREATE Proc p_CO_ObtenerProgramaImplementaEntregables
@pIdProgramaImplementaEntregable int
as

	select IdProgramaImplementaEntregable,
		IdProgramaImplementaProgramacion,
		Archivo,
		NombreArchivo,
		TipoArchivo,
		CreadoEl,
		CreadoPor
	from CO_ProgramaImplementaEntregables
	where IdProgramaImplementaEntregable = @pIdProgramaImplementaEntregable