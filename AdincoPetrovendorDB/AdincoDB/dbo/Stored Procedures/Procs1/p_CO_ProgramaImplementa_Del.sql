
create proc p_CO_ProgramaImplementa_Del
(
	@pIdProgramaImplementa	int
)
as
begin

	update	CO_ProgramaImplementa
	set		Activo	=	0
	where	IdProgramaImplementa	=	@pIdProgramaImplementa

end