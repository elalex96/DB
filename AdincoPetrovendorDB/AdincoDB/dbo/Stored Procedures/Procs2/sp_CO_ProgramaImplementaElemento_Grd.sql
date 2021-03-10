
create proc sp_CO_ProgramaImplementaElemento_Grd
(
	@pIdProgramaImplementaPolitica	int,
	@pIdProgramaImplementa			int
)
as
begin

	--select		@pIdProgramaImplementa = 21, @pIdProgramaImplementaPolitica = 139

	declare		@orden int
	select		@orden =	max(isnull(e.Orden,0))
	from		CO_ProgramaImplementaElemento	e
	inner join	CO_ProgramaImplementaPoliticas	p
	on			e.IdProgramaImplementaPolitica	=	p.IdProgramaImplementaPolitica
	and			e.IdProgramaImplementa			=	p.IdProgramaImplementa
	where		e.IdProgramaImplementaPolitica	=	@pIdProgramaImplementaPolitica--139
	and			e.IdProgramaImplementa			=	@pIdProgramaImplementa--21

	select		Id = case when e.Orden is null then   ROW_NUMBER() OVER (	ORDER BY e.Orden   )+@orden else e.Orden end,
				e.IdProgramaImplementa,
				e.IdProgramaImplementaPolitica,
				e.IdProgramaImplementaElemento,			
				Elemento						=	cast(e.Descripcion as varchar(50)),
				Orden							=	isnull(e.Orden,0)
	into		#tmp
	from		CO_ProgramaImplementaElemento	e
	inner join	CO_ProgramaImplementaPoliticas	p
	on			e.IdProgramaImplementaPolitica	=	p.IdProgramaImplementaPolitica
	and			e.IdProgramaImplementa			=	p.IdProgramaImplementa
	where		e.IdProgramaImplementaPolitica	=	@pIdProgramaImplementaPolitica--139
	and			e.IdProgramaImplementa			=	@pIdProgramaImplementa--21

	update		CO_ProgramaImplementaElemento
	set			CO_ProgramaImplementaElemento.orden	=	t1.Id	
	from		CO_ProgramaImplementaElemento		e
	inner join	#tmp								t1
	on			t1.IdProgramaImplementaElemento		=	e.IdProgramaImplementaElemento

	select		e.IdProgramaImplementa,
				e.IdProgramaImplementaPolitica,
				e.IdProgramaImplementaElemento,			
				Elemento						=	cast(e.Descripcion as varchar(50)),
				Orden							=	isnull(e.Orden,0)
	from		CO_ProgramaImplementaElemento	e
	inner join	CO_ProgramaImplementaPoliticas	p
	on			e.IdProgramaImplementaPolitica	=	p.IdProgramaImplementaPolitica
	and			e.IdProgramaImplementa			=	p.IdProgramaImplementa
	where		e.IdProgramaImplementaPolitica	=	@pIdProgramaImplementaPolitica--139
	and			e.IdProgramaImplementa			=	@pIdProgramaImplementa--21
	order by	e.Orden
end
