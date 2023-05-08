
Create Proc p_CO_EliminaPogramaImplementaDepartamentos
@pIdProgramaImplementaDepartamento int
as
begin
	--delete [dbo].[CO_ProgramaImplementaDepartamentoUsuario]	where IdProgramaImplementaDepartamento = @pIdProgramaImplementaDepartamento
	update	[dbo].[CO_ProgramaImplementaDepartamentoUsuario]	
	set		Activo								=	0
	where	IdProgramaImplementaDepartamento	=	@pIdProgramaImplementaDepartamento


	--delete [dbo].[CO_ProgramaImplementaDepartamentos]	where IdProgramaImplementaDepartamento = @pIdProgramaImplementaDepartamento
	update	[dbo].[CO_ProgramaImplementaDepartamentos] 
	set		Activo								=	0 
	where	IdProgramaImplementaDepartamento	=	@pIdProgramaImplementaDepartamento
end