
create proc p_CO_ActualizarProgramaImplementaPoliticas
		@pIdProgramaImplementaPolitica	int,
		@pIdProgramaImplementa			int,
		@pDescripcion					varchar(1500),
		@pCreadoPor						int
AS
begin
	update	[CO_ProgramaImplementaPoliticas]
	set		Descripcion						=	@pDescripcion
	where	IdProgramaImplementaPolitica	=	@pIdProgramaImplementaPolitica
end