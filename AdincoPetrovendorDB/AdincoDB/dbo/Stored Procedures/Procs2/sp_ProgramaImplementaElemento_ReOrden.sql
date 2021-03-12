create proc sp_ProgramaImplementaElemento_ReOrden --21, 139, 1047, 8353,0,1
(
	@pIdProgramaImplementa			int,
	@pIdProgramaImplementaPolitica	int,
	@pIdProgramaImplementaElemento	int,
	@pOrden							int, 
	@pUpDown						int
)
as
begin

	select @pOrden = isnull(@pOrden,0)+@pUpDown
	
	if(@pOrden<1)
	begin
		select @pOrden = 1
	end

	update		CO_ProgramaImplementaElemento
	set			Orden							=	@pOrden
	where		IdProgramaImplementaElemento	=	@pIdProgramaImplementaElemento
	
	declare		@IdProgramaImplementaElemento	int
	
	select		@IdProgramaImplementaElemento		=	e.IdProgramaImplementaElemento
	from		CO_ProgramaImplementaElemento	e
	inner join	CO_ProgramaImplementaPoliticas	p
	on			e.IdProgramaImplementaPolitica	=	p.IdProgramaImplementaPolitica
	and			e.IdProgramaImplementa			=	p.IdProgramaImplementa
	where		e.IdProgramaImplementa			=	@pIdProgramaImplementa
	and			e.IdProgramaImplementaPolitica	=	@pIdProgramaImplementaPolitica
	and			e.IdProgramaImplementaElemento	<>	@pIdProgramaImplementaElemento
	and			e.Orden							=	@pOrden

	Update		CO_ProgramaImplementaElemento
	set			CO_ProgramaImplementaElemento.Orden	=	e.Orden +1
	from		CO_ProgramaImplementaElemento	e
	inner join	CO_ProgramaImplementaPoliticas	p
	on			e.IdProgramaImplementaPolitica	=	p.IdProgramaImplementaPolitica
	and			e.IdProgramaImplementa			=	p.IdProgramaImplementa
	where		e.IdProgramaImplementa			=	@pIdProgramaImplementa
	and			e.IdProgramaImplementaPolitica	=	@pIdProgramaImplementaPolitica
	and			e.IdProgramaImplementaElemento	<>	@pIdProgramaImplementaElemento
	and			e.Orden							>=	@pOrden
	
	update		CO_ProgramaImplementaElemento
	set			Orden							=	@pOrden+(@pUpDown*-1)
	where		IdProgramaImplementaElemento	=	@IdProgramaImplementaElemento

	select		Orden							=	ROW_NUMBER() OVER( ORDER BY e.Orden), 
				e.IdProgramaImplementa,
				e.IdProgramaImplementaPolitica,
				e.IdProgramaImplementaElemento,
				Elemento						=	cast(e.Descripcion as varchar(50)),
				OrdenElemento					=	e.Orden				
	into		#tmp
	from		CO_ProgramaImplementaElemento	e
	inner join	CO_ProgramaImplementaPoliticas	p
	on			e.IdProgramaImplementaPolitica	=	p.IdProgramaImplementaPolitica
	and			e.IdProgramaImplementa			=	p.IdProgramaImplementa
	where		e.IdProgramaImplementa			=	@pIdProgramaImplementa
	and			e.IdProgramaImplementaPolitica	=	@pIdProgramaImplementaPolitica
	and			e.Orden							is not null
	order by	e.Orden
	
	--select 999, * from #tmp
	
	Update		CO_ProgramaImplementaElemento
	set			CO_ProgramaImplementaElemento.Orden	=	t1.Orden
	from		CO_ProgramaImplementaElemento	e
	inner join	CO_ProgramaImplementaPoliticas	p
	on			e.IdProgramaImplementaPolitica	=	p.IdProgramaImplementaPolitica
	and			e.IdProgramaImplementa			=	p.IdProgramaImplementa
	inner join	#tmp							t1
	on			t1.IdProgramaImplementa			=	p.IdProgramaImplementa
	and			t1.IdProgramaImplementaElemento	=	e.IdProgramaImplementaElemento
	and			t1.IdProgramaImplementaPolitica	=	p.IdProgramaImplementaPolitica
	
	select		Id								=	ROW_NUMBER() OVER( ORDER BY e.Orden), 
				e.IdProgramaImplementa,
				e.IdProgramaImplementaPolitica,
				e.IdProgramaImplementaElemento,			
				Elemento						=	cast(e.Descripcion as varchar(50)),
				Politica						=	p.Descripcion,
				OrdenElemento					=	e.Orden
	from		CO_ProgramaImplementaElemento	e
	inner join	CO_ProgramaImplementaPoliticas	p
	on			e.IdProgramaImplementaPolitica	=	p.IdProgramaImplementaPolitica
	and			e.IdProgramaImplementa			=	p.IdProgramaImplementa
	where		e.IdProgramaImplementa			=	@pIdProgramaImplementa
	and			e.IdProgramaImplementaPolitica	=	@pIdProgramaImplementaPolitica
	order by	e.Orden

end
