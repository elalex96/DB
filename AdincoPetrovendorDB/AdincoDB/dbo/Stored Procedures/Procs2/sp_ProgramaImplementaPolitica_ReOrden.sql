create proc sp_ProgramaImplementaPolitica_ReOrden --21, 139, 1047, 8353,0,1
(
	@pIdProgramaImplementa			int,
	@pIdProgramaImplementaPolitica	int,
	@pOrden							int, 
	@pUpDown						int
)
as
begin

	if(@pOrden = 1 and @pUpDown=1)
	begin
		select	@pIdProgramaImplementaPolitica	=	IdProgramaImplementaPolitica,
				@pOrden							=	Orden,
				@pUpDown						=	-1
				
		from	CO_ProgramaImplementaPoliticas where IdProgramaImplementa = @pIdProgramaImplementa and Orden = 2
	end

	--select  @pIdProgramaImplementa,@pIdProgramaImplementaPolitica,@pOrden,@pUpDown

	select @pOrden = isnull(@pOrden,0)+@pUpDown
	
	if(@pOrden<1)
	begin
		select @pOrden = 1
	end
	
	update		CO_ProgramaImplementaPoliticas
	set			Orden							=	@pOrden
	where		IdProgramaImplementaPolitica	=	@pIdProgramaImplementaPolitica
	
	declare		@IdProgramaImplementaPolitica	int
	
	select		@IdProgramaImplementaPolitica	=	p.IdProgramaImplementaPolitica
	from		CO_ProgramaImplementaPoliticas	p
	where		p.IdProgramaImplementa			=	@pIdProgramaImplementa
	and			p.IdProgramaImplementaPolitica	<>	@pIdProgramaImplementaPolitica
	and			p.Orden							=	@pOrden

	Update		CO_ProgramaImplementaPoliticas
	set			CO_ProgramaImplementaPoliticas.Orden	=	p.Orden +1
	from		CO_ProgramaImplementaPoliticas	p
	where		p.IdProgramaImplementa			=	@pIdProgramaImplementa
	and			p.IdProgramaImplementaPolitica	<>	@pIdProgramaImplementaPolitica
	and			p.Orden							>=	@pOrden
	
	update		CO_ProgramaImplementaElemento
	set			Orden							=	@pOrden+(@pUpDown*-1)
	where		IdProgramaImplementaElemento	=	@IdProgramaImplementaPolitica

	select		Orden							=	ROW_NUMBER() OVER( ORDER BY p.Orden), 
				p.IdProgramaImplementa,
				p.IdProgramaImplementaPolitica,
				OrdenPolitica					=	p.Orden				
	into		#tmp
	from		CO_ProgramaImplementaPoliticas	p
	where		p.IdProgramaImplementa			=	@pIdProgramaImplementa
	--and		p.IdProgramaImplementaPolitica	=	@pIdProgramaImplementaPolitica
	and			p.Orden							is not null
	order by	p.Orden
	
	--select 999, * from #tmp
	
	Update		CO_ProgramaImplementaPoliticas
	set			CO_ProgramaImplementaPoliticas.Orden	=	t1.Orden
	from		CO_ProgramaImplementaPoliticas	p
	inner join	#tmp							t1
	on			t1.IdProgramaImplementa			=	p.IdProgramaImplementa
	and			t1.IdProgramaImplementaPolitica	=	p.IdProgramaImplementaPolitica
	
end
