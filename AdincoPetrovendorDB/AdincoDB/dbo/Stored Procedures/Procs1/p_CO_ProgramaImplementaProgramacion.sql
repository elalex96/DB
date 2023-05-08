-- p_CO_ProgramaImplementaProgramacion 1,10
CREATE proc p_CO_ProgramaImplementaProgramacion
@pIdProgramaImplementa int,
@pIdusuario int
as


	select 
		prog.IdProgramaImplementaProgramacion,
		pol.IdProgramaImplementaPolitica,
		Politica = pol.Descripcion,
		e.IdProgramaImplementaElemento,
		Elemento = e.Descripcion,
		a.IdProgramaImplementaAccion,
		Accion = a.Descripcion,
		
		prog.FechaInicioProgramada,
		prog.FechaFinProgramada,
		prog.FechaInicioImplementa,
		prog.FechaFinImplementa,
		prog.RevisadoPor,
		NombreUsuarioRevision = ur.Usuario,
		prog.CreadoPor
	from [dbo].[CO_ProgramaImplementaAcciones] a 
	left join[dbo].[CO_ProgramaImplementaProgramacion] prog	on a.IdProgramaImplementaAccion = prog.IdProgramaImplementaAccion
	inner join [dbo].[CO_ProgramaImplementaElemento] e on a.IdProgramaImplementaElemento = e.IdProgramaImplementaElemento
	inner join [dbo].[CO_ProgramaImplementaPoliticas] pol on pol.IdProgramaImplementaPolitica = e.IdProgramaImplementaPolitica
	inner join [dbo].[CO_ProgramaImplementaDepartamentos] dep on dep.IdProgramaImplementaDepartamento = a.IdProgramaImplementaDepartamento
	--left join [dbo].[CO_ProgramaImplementaDepartamentoUsuario] ud on ud.IdProgramaImplementaDepartamento = dep.IdProgramaImplementaDepartamento and
	--												ud.IdUsuario = @pIdusuario
	left join AP_Usuario ur on ur.UsuarioID = prog.RevisadoPor
	where e.IdProgramaImplementa = @pIdProgramaImplementa
	order by pol.Descripcion,e.Descripcion,a.Descripcion,prog.FechaInicioProgramada,prog.FechaFinProgramada