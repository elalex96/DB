
Create Proc p_CO_InsertarProgramaImplementaElemento
(
	@pIdProgramaImplementaElemento	int out,
	@pIdProgramaImplementaPolitica	int,
	@pIdProgramaImplementa			int,
	@pDescripcion					varchar(1500),
	@pCreadoPor						int
)
as
begin
	select @pIdProgramaImplementaElemento = isnull(max(IdProgramaImplementaElemento),0) + 1
	from [CO_ProgramaImplementaElemento]

	insert into [dbo].[CO_ProgramaImplementaElemento](
		IdProgramaImplementaElemento,		IdProgramaImplementa,		Descripcion,	
		CreadoEl,							CreadoPor,					ModificadoEl,
		ModificadoPor,						IdProgramaImplementaPolitica
	)
	values(
		@pIdProgramaImplementaElemento,		@pIdProgramaImplementa,    @pDescripcion,
		getdate(),							@pCreadoPor,			null,
		null,								@pIdProgramaImplementaPolitica
	)
end
