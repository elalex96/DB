create proc sp_ProgramaImplementaElemento_ReOrdenMoveTo
(
	@pIdProgramaImplementa			int,	
	@pIdProgramaImplementaPolitica	int,	
	@pIdProgramaImplementaElemento	int,
	@pOrden							int, 
	@pOrdenNuevo					int
)
as
begin

	declare		@maxOrden	int, @pUpDown int

	select		@maxOrden =	count(Orden) 	
	from		CO_ProgramaImplementaElemento	e
	where		e.IdProgramaImplementa			=	@pIdProgramaImplementa --and Orden is not null
	and			e.IdProgramaImplementaPolitica	=	@pIdProgramaImplementaPolitica
	--select		@maxOrden

	update CO_ProgramaImplementaElemento
	set Orden = Orden -1
	where IdProgramaImplementaElemento <> @pIdProgramaImplementaElemento AND
	IdProgramaImplementaPolitica = @pIdProgramaImplementaPolitica AND
	Orden >= @pOrden

	update CO_ProgramaImplementaElemento
	set Orden = @pOrdenNuevo
	where IdProgramaImplementaElemento = @pIdProgramaImplementaElemento 

	update CO_ProgramaImplementaElemento
	set Orden = Orden + 1
	where IdProgramaImplementaElemento <> @pIdProgramaImplementaElemento AND
	IdProgramaImplementaPolitica = @pIdProgramaImplementaPolitica AND
	Orden >= @pOrdenNuevo

	select 
		Orden = ROW_NUMBER() OVER(ORDER BY Orden ASC) ,
		IdProgramaImplementaElemento
	into #tmpOrden
	from CO_ProgramaImplementaElemento
	Where IdProgramaImplementaPolitica = @pIdProgramaImplementaPolitica	


	update CO_ProgramaImplementaElemento
	set Orden = tmp.Orden
	from CO_ProgramaImplementaElemento a
	inner join #tmpOrden tmp on tmp.IdProgramaImplementaElemento = a.IdProgramaImplementaElemento
	
end