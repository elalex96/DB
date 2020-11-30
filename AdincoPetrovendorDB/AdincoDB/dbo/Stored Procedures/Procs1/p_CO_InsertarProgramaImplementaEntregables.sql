
Create Proc p_CO_InsertarProgramaImplementaEntregables
@pIdProgramaImplementaEntregable int out,
@pIdProgramaImplementaProgramacion int,
@pArchivo image,
@pNombreArchivo varchar(250),
@pTipoArchivo varchar(100),
@pCreadoPor int
as


	select @pIdProgramaImplementaEntregable = isnull(max(IdProgramaImplementaEntregable),0) + 1
	from CO_ProgramaImplementaEntregables

	insert into CO_ProgramaImplementaEntregables(
		IdProgramaImplementaEntregable,		IdProgramaImplementaProgramacion,		Archivo,	
		NombreArchivo,						TipoArchivo,					CreadoEl,
		CreadoPor
	)
	values(
		@pIdProgramaImplementaEntregable,@pIdProgramaImplementaProgramacion,@pArchivo,
		@pNombreArchivo,					@pTipoArchivo,					getdate(),
		@pCreadoPor
	)