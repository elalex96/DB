create proc sp_CO_ProgramaImplementaPoliticas_Grd
(
	@pIdTipoPrograma	int
)
as
begin
		--select		@pIdTipoPrograma = 12

		declare		@orden int
		select		@orden =	max(isnull(Orden,0))
		from		CO_ProgramaImplementaPoliticas
		where		IdProgramaImplementa			=	@pIdTipoPrograma

		select		Id = case when Orden is null then   ROW_NUMBER() OVER (	ORDER BY Orden   )+@orden else Orden end,
					IdProgramaImplementaPolitica,
					IdProgramaImplementa,
					Descripcion,
					Orden							=	isnull(Orden,0)
		into		#tmp
		from		CO_ProgramaImplementaPoliticas
		where		IdProgramaImplementa			=	@pIdTipoPrograma

		update		CO_ProgramaImplementaPoliticas
		set			CO_ProgramaImplementaPoliticas.orden	=	t1.Id	
		from		CO_ProgramaImplementaPoliticas			p
		inner join	#tmp									t1
		on			t1.IdProgramaImplementaPolitica			=	p.IdProgramaImplementaPolitica

		select		IdProgramaImplementaPolitica,
					IdProgramaImplementa,
					Descripcion,
					Orden							=	isnull(Orden,0)
		from		CO_ProgramaImplementaPoliticas
		where		IdProgramaImplementa			=	@pIdTipoPrograma
		order by	Orden
end
