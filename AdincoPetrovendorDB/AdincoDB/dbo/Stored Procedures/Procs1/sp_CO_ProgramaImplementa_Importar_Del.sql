
create proc sp_CO_ProgramaImplementa_Importar_Del
(
	@pIdContrato	int
)
as
begin
		delete		
		from		CO_ProgramaImplementa_Importar
		where		IdContrato						=	@pIdContrato
end
