
CREATE Proc p_CO_ObtenerProgramaImplementa
(
	@pIdProgramaImplementa	int,
	@pIdContrato			int = 0
)
as
begin

	select i.IdProgramaImplementa,
		i.IdContrato,
		NombrePrograma = tipo.Descripcion,
		IdTipoPrograma,
		FechaInicio,
		FechaFin,
		CreadoEl,
		CreadoPor,
		ModificadoEl,
		ModificadoPor,
		FechaInicioAccion = (
								select		min(FechaInicioPrimeraAccion)
								from		[dbo].[CO_ProgramaImplementaElemento]	e
								inner join	[dbo].[CO_ProgramaImplementaAcciones]	a 
								on			a.IdProgramaImplementaElemento			=	e.IdProgramaImplementaElemento
								where		e.IdProgramaImplementa					=	i.IdProgramaImplementa
							)
	from		[dbo].[CO_ProgramaImplementa]			i
	inner join	[dbo].[CO_ProgramaImplementacionTipo]	tipo 
	on			tipo.Id									=		i.IdTipoPrograma
	where		@pIdProgramaImplementa					in		(0, IdProgramaImplementa) 
	and			i.IdContrato							=		@pIdContrato
	and			Activo									=		1

end
