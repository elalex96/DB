
create proc sp_CO_ProgramaImplementa_ImportarDep_Del
(
	@pIdContrato	int
)
as
begin

	
		delete 		
		from	CO_ProgramaImplementa_ImportarDep
		where	IdContrato							=	@pIdContrato
end