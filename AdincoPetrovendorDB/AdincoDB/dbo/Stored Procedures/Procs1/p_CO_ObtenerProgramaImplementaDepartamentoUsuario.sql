Create Proc p_CO_ObtenerProgramaImplementaDepartamentoUsuario
@pIdProgramaImplementaDepartamento int
as

	select	
			ID=ROW_NUMBER() OVER(ORDER BY IdProgramaImplementaDepartamento DESC) ,
			IdProgramaImplementaDepartamento,
			IdUsuario,
			CreadoEl,
			CreadoPor
	from [dbo].[CO_ProgramaImplementaDepartamentoUsuario]
	where IdProgramaImplementaDepartamento = @pIdProgramaImplementaDepartamento

