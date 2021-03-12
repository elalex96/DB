create proc sp_ProgramaImplementaPolitica_ReOrdenMoveTo
(
	@pIdProgramaImplementa			int,	
	@pIdProgramaImplementaPolitica	int,	
	@pOrden							int, 
	@pOrdenNuevo					int
)
as
begin

	declare		@maxOrden	int, @pUpDown int

	select		@maxOrden =	count(Orden) 	from	CO_ProgramaImplementaPoliticas where IdProgramaImplementa = @pIdProgramaImplementa --and Orden is not null
	   	

	update CO_ProgramaImplementaPoliticas
	set Orden = Orden -1
	where IdProgramaImplementa = @pIdProgramaImplementa AND
	IdProgramaImplementaPolitica <> @pIdProgramaImplementaPolitica AND
	Orden >= @pOrden

	update CO_ProgramaImplementaPoliticas
	set Orden = @pOrdenNuevo
	where IdProgramaImplementaPolitica = @pIdProgramaImplementaPolitica	

	update CO_ProgramaImplementaPoliticas
	set Orden = Orden + 1
	where IdProgramaImplementa = @pIdProgramaImplementa AND
	IdProgramaImplementaPolitica <> @pIdProgramaImplementaPolitica AND
	Orden >= @pOrdenNuevo

	

	


	select 
		Orden = ROW_NUMBER() OVER(ORDER BY Orden ASC) ,
		IdProgramaImplementaPolitica
	into #tmpOrden
	from CO_ProgramaImplementaPoliticas
	Where IdProgramaImplementa = @pIdProgramaImplementa	
	


	update CO_ProgramaImplementaPoliticas
	set Orden = tmp.Orden
	from CO_ProgramaImplementaPoliticas p
	inner join #tmpOrden tmp on tmp.IdProgramaImplementaPolitica = p.IdProgramaImplementaPolitica
	where p.IdProgramaImplementa = @pIdProgramaImplementa

	

	
end


