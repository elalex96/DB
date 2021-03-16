create proc sp_ProgramaImplementaAccion_ReOrden --21, 139, 1047, 8353,0,1
(
	@pIdProgramaImplementa			int,
	@pIdProgramaImplementaPolitica	int,
	@pIdProgramaImplementaElemento	int,
	@pIdProgramaImplementaAccion	int,
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

	update		CO_ProgramaImplementaAcciones
	set			Orden							=	@pOrden
	where		IdProgramaImplementaAccion		=	@pIdProgramaImplementaAccion
	
	declare		@IdProgramaImplementaAccion	int
	
	select		@IdProgramaImplementaAccion		=	a.IdProgramaImplementaAccion
	from		CO_ProgramaImplementaElemento	e
	inner join	CO_ProgramaImplementaPoliticas	p
	on			e.IdProgramaImplementaPolitica	=	p.IdProgramaImplementaPolitica
	and			e.IdProgramaImplementa			=	p.IdProgramaImplementa
	inner join	CO_ProgramaImplementaAcciones	a
	on			a.IdProgramaImplementaElemento	=	e.IdProgramaImplementaElemento
	where		e.IdProgramaImplementa			=	@pIdProgramaImplementa
	and			e.IdProgramaImplementaPolitica	=	@pIdProgramaImplementaPolitica
	and			e.IdProgramaImplementaElemento	=	@pIdProgramaImplementaElemento
	and			a.IdProgramaImplementaAccion	<>	@pIdProgramaImplementaAccion
	and			a.Orden							=	@pOrden

	Update		CO_ProgramaImplementaAcciones
	set			CO_ProgramaImplementaAcciones.Orden	=	a.Orden +1
	from		CO_ProgramaImplementaElemento	e
	inner join	CO_ProgramaImplementaPoliticas	p
	on			e.IdProgramaImplementaPolitica	=	p.IdProgramaImplementaPolitica
	and			e.IdProgramaImplementa			=	p.IdProgramaImplementa
	inner join	CO_ProgramaImplementaAcciones	a
	on			a.IdProgramaImplementaElemento	=	e.IdProgramaImplementaElemento
	where		e.IdProgramaImplementa			=	@pIdProgramaImplementa
	and			e.IdProgramaImplementaPolitica	=	@pIdProgramaImplementaPolitica
	and			e.IdProgramaImplementaElemento	=	@pIdProgramaImplementaElemento
	and			a.IdProgramaImplementaAccion	<>	@pIdProgramaImplementaAccion
	and			a.Orden							>=	@pOrden
	
	update		CO_ProgramaImplementaAcciones
	set			Orden							=	@pOrden+(@pUpDown*-1)
	where		IdProgramaImplementaAccion		=	@IdProgramaImplementaAccion


	select		Orden							=	ROW_NUMBER() OVER( ORDER BY a.Orden), 
				e.IdProgramaImplementa,
				e.IdProgramaImplementaPolitica,
				e.IdProgramaImplementaElemento,
				a.IdProgramaImplementaAccion,				
				Elemento						=	cast(e.Descripcion as varchar(50)),
				Politica						=	p.Descripcion,
				Accion							=	a.Descripcion,
				OrdenElemento					=	e.Orden,
				OrdenAccion						=	a.Orden
	into		#tmp
	from		CO_ProgramaImplementaElemento	e
	inner join	CO_ProgramaImplementaPoliticas	p
	on			e.IdProgramaImplementaPolitica	=	p.IdProgramaImplementaPolitica
	and			e.IdProgramaImplementa			=	p.IdProgramaImplementa
	inner join	CO_ProgramaImplementaAcciones	a
	on			a.IdProgramaImplementaElemento	=	e.IdProgramaImplementaElemento
	where		e.IdProgramaImplementa			=	@pIdProgramaImplementa
	and			e.IdProgramaImplementaPolitica	=	@pIdProgramaImplementaPolitica
	and			e.IdProgramaImplementaElemento	=	@pIdProgramaImplementaElemento
	and			a.Orden							is not null
	order by	a.Orden

	Update		CO_ProgramaImplementaAcciones
	set			CO_ProgramaImplementaAcciones.Orden	=	t1.Orden
	from		CO_ProgramaImplementaElemento	e
	inner join	CO_ProgramaImplementaPoliticas	p
	on			e.IdProgramaImplementaPolitica	=	p.IdProgramaImplementaPolitica
	and			e.IdProgramaImplementa			=	p.IdProgramaImplementa
	inner join	CO_ProgramaImplementaAcciones	a
	on			a.IdProgramaImplementaElemento	=	e.IdProgramaImplementaElemento
	inner join	#tmp							t1
	on			t1.IdProgramaImplementa			=	p.IdProgramaImplementa
	and			t1.IdProgramaImplementaAccion	=	a.IdProgramaImplementaAccion
	and			t1.IdProgramaImplementaElemento	=	e.IdProgramaImplementaElemento
	and			t1.IdProgramaImplementaPolitica	=	p.IdProgramaImplementaPolitica
		
	select		Id								=	ROW_NUMBER() OVER( ORDER BY a.Orden), 
				e.IdProgramaImplementa,
				e.IdProgramaImplementaPolitica,
				e.IdProgramaImplementaElemento,
				a.IdProgramaImplementaAccion,				
				Elemento						=	cast(e.Descripcion as varchar(50)),
				Politica						=	p.Descripcion,
				Accion							=	a.Descripcion,
				OrdenElemento					=	e.Orden,
				OrdenAccion						=	a.Orden
	from		CO_ProgramaImplementaElemento	e
	inner join	CO_ProgramaImplementaPoliticas	p
	on			e.IdProgramaImplementaPolitica	=	p.IdProgramaImplementaPolitica
	and			e.IdProgramaImplementa			=	p.IdProgramaImplementa
	inner join	CO_ProgramaImplementaAcciones	a
	on			a.IdProgramaImplementaElemento	=	e.IdProgramaImplementaElemento
	where		e.IdProgramaImplementa			=	@pIdProgramaImplementa
	and			e.IdProgramaImplementaPolitica	=	@pIdProgramaImplementaPolitica
	and			e.IdProgramaImplementaElemento	=	@pIdProgramaImplementaElemento
	order by	a.Orden

end