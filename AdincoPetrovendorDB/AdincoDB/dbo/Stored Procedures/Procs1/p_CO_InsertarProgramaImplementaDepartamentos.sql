
create Proc p_CO_InsertarProgramaImplementaDepartamentos
	@pIdProgramaImplementaDepartamento	smallint out,
	@pIdContrato						int,
	@pDescripcion						varchar(250),
	@pCreadoPor							int
as
begin
	select @pIdProgramaImplementaDepartamento  =isnull(max(IdProgramaImplementaDepartamento),0) + 1
	from [CO_ProgramaImplementaDepartamentos]

	insert into [CO_ProgramaImplementaDepartamentos](
		IdProgramaImplementaDepartamento,IdContrato,Descripcion,CreadoEl,CreadoPor,Activo
	)
	values(
	@pIdProgramaImplementaDepartamento,@pIdContrato,@pDescripcion,getdate(),@pCreadoPor,1
	)
end