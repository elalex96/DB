Create Proc p_CO_ActualizarProgramaImplementaDepartamentos
@pIdProgramaImplementaDepartamento	smallint ,
@pIdContrato	int,
@pDescripcion	varchar(250),
@pCreadoPor	int
as

	update [CO_ProgramaImplementaDepartamentos]
	set Descripcion = @pDescripcion
	where IdProgramaImplementaDepartamento = @pIdProgramaImplementaDepartamento

