
-- p_CO_SchedulerResourceProgramacionImplementa 2
CREATE Proc p_CO_SchedulerResourceProgramacionImplementa
@pIdProgramaImplementa int,
@pIdAccion int
as

	select ID = 1,
		Model = '(Todos)',
		Color = 'red'

	--select ID = a.IdProgramaImplementaAccion,
	--	Model = UPPER(e.Descripcion)+' '+a.Descripcion,
	--	Color = 'red'
	--from [dbo].[CO_ProgramaImplementa] p
	--inner join [dbo].[CO_ProgramaImplementaElemento] e on e.IdProgramaImplementa = p.IdProgramaImplementa
	--inner join [dbo].[CO_ProgramaImplementaAcciones] a on a.IdProgramaImplementaElemento = e.IdProgramaImplementaElemento
	--where p.IdProgramaImplementa = @pIdProgramaImplementa
	--order by e.Descripcion,a.Descripcion


