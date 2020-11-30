cREATE Proc p_CO_InsertarProgramaImplementaDepartamentoUsuario
@pIdProgramaImplementaDepartamento	smallint,
@pIdUsuario	int,
@pCreadoPor	int
as

	insert into [dbo].[CO_ProgramaImplementaDepartamentoUsuario](
		IdProgramaImplementaDepartamento,IdUsuario,CreadoEl,CreadoPor
	)
	values(
		@pIdProgramaImplementaDepartamento,@pIdUsuario,getdate(),@pCreadoPor
	)