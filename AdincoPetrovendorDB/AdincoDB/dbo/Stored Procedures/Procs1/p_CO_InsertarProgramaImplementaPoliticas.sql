
Create proc p_CO_InsertarProgramaImplementaPoliticas
	@pIdProgramaImplementaPolitica	int out,
	@pIdProgramaImplementa			int,
	@pDescripcion					varchar(1500),
	@pCreadoPor						int
AS
begin
	select	@pIdProgramaImplementaPolitica  =	isnull(max(IdProgramaImplementaPolitica),0) + 1
	from	CO_ProgramaImplementaPoliticas

	insert into [dbo].[CO_ProgramaImplementaPoliticas]
				(	IdProgramaImplementaPolitica,	IdProgramaImplementa,	Descripcion,	CreadoEl,		CreadoPor	)
		values	(	@pIdProgramaImplementaPolitica,	@pIdProgramaImplementa,	@pDescripcion,	getdate(),		@pCreadoPor	)
end
