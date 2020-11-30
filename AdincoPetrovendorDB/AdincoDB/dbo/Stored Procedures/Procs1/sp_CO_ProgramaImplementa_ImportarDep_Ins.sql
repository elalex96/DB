
create proc sp_CO_ProgramaImplementa_ImportarDep_Ins
(
    
	@IdProgramaImplementa	int,
	@Categoria				varchar(8000),
	@pIdContrato			int,
	@pIdUsuario				int
)
as
begin

	if not exists(select * from CO_ProgramaImplementa_ImportarDep 
					where Categoria = rtrim(ltrim(@Categoria)) 					
					and idcontrato = @pIdContrato
					)
    begin
		select	@IdProgramaImplementa	=	isnull(max(IdProgramaImplementa),0)+1 from CO_ProgramaImplementa_ImportarDep
		insert	into	CO_ProgramaImplementa_ImportarDep
					(
                    
						IdProgramaImplementa,
						IdContrato,
						Categoria,
						IdUsuario
					)

			values
					(
                    
						@IdProgramaImplementa,
						@pIdContrato,
						rtrim(ltrim(@Categoria)),
						@pIdUsuario
					)
		end

end