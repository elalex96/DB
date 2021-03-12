create proc sp_CO_ProgramaImplementa_cmb
(
	@pIdContratista		int,
	@pIdContrato		int
)
as
begin
		select			Id = I.IdProgramaImplementa,
						Descripcion = it.Descripcion						
		from			CO_ProgramaImplementacionTipo	it
		inner	join	CO_ProgramaImplementa			i
		on				it.Id							=	i.IdTipoPrograma
		and				it.IdContrato					=	i.IdContrato
		where			i.Activo						=	1
		and				it.IdContratista				=	@pIdContratista
		and				it.IdContrato					=	@pIdContrato 
		group by		I.IdProgramaImplementa,
						it.Descripcion
						
end


