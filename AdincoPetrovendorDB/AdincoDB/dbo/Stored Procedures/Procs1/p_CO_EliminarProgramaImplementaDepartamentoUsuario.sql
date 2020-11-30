cREATE Proc p_CO_EliminarProgramaImplementaDepartamentoUsuario
@pIdProgramaImplementaDepartamento	smallint,
@pIdUsuario	int
as

	delete [CO_ProgramaImplementaDepartamentoUsuario]
	where IdProgramaImplementaDepartamento = @pIdProgramaImplementaDepartamento and
	IdUsuario = @pIdUsuario