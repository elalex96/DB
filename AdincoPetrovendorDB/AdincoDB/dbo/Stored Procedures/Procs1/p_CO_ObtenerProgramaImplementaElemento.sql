-- p_CO_ObtenerProgramaImplementaElemento 1
CREATE PRoc p_CO_ObtenerProgramaImplementaElemento
@pIdProgramaImplementaPolitica int,
@pIdProgramaImplementa int,
@pIdProgramaImplementaElemento	int 
as


	SELECT pe.IdProgramaImplementaElemento,
		pe.IdProgramaImplementa,
		pe.Descripcion,
		pe.CreadoEl,
		pe.CreadoPor,
		pe.ModificadoEl,
		pe.ModificadoPor 
	FROM [dbo].[CO_ProgramaImplementaElemento] pe	
	where @pIdProgramaImplementa in (0,pe.IdProgramaImplementa)
	AND @pIdProgramaImplementaPolitica = IdProgramaImplementaPolitica
	order by pe.Descripcion

