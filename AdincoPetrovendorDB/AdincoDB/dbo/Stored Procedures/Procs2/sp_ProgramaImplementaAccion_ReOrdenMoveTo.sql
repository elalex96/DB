create proc sp_ProgramaImplementaAccion_ReOrdenMoveTo
(
	@pIdProgramaImplementa			int,	
	@pIdProgramaImplementaPolitica	int,	
	@pIdProgramaImplementaElemento	int,
	@pIdProgramaImplementaAccion	int,
	@pOrden							int, 
	@pOrdenNuevo					int
)
as
begin

	declare		@maxOrden	int, @pUpDown int

	select		@maxOrden =	count(Orden) 	
	from		CO_ProgramaImplementaAcciones	a
	where		a.IdProgramaImplementaElemento	=	@pIdProgramaImplementaElemento --and Orden is not null
	--select		@maxOrden

	update CO_ProgramaImplementaAcciones
	SET Orden = Orden -1
	where IdProgramaImplementaElemento = @pIdProgramaImplementaElemento and
	IdProgramaImplementaAccion <> @pIdProgramaImplementaAccion and
	Orden >= @pOrden

	update CO_ProgramaImplementaAcciones
	SET Orden = @pOrdenNuevo
	where
	IdProgramaImplementaAccion = @pIdProgramaImplementaAccion 

	update CO_ProgramaImplementaAcciones
	SET Orden = Orden +1
	where IdProgramaImplementaElemento = @pIdProgramaImplementaElemento and
	IdProgramaImplementaAccion <> @pIdProgramaImplementaAccion and
	Orden >= @pOrdenNuevo


	
	select 
		Orden = ROW_NUMBER() OVER(ORDER BY Orden ASC) ,
		IdProgramaImplementaAccion
	into #tmpOrden
	from CO_ProgramaImplementaAcciones
	Where IdProgramaImplementaElemento = @pIdProgramaImplementaElemento
	

	UPDATE CO_ProgramaImplementaAcciones
	set orden = tmp.Orden
	FROM CO_ProgramaImplementaAcciones a
	inner join #tmpOrden tmp on tmp.IdProgramaImplementaAccion = a.IdProgramaImplementaAccion
end
