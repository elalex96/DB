
-- p_CO_SchedulerAppointmentProgramacionImplementa 2,0
CREATE Proc p_CO_SchedulerAppointmentProgramacionImplementa
@pIdProgramaImplementa int,
@pIdAccion int
as

	select ID = prog.IdProgramaImplementaProgramacion,
		AllDay=null,
        Description=convert(varchar,FechaInicioProgramada,103) + '-'+convert(varchar,FechaFinProgramada,103),
		EndTime = prog.FechaFinProgramada,
		Label = 1,
		Location = 'Prog.',
		RecurrenceInfo =  a.IdProgramaImplementaAccion,
		ReminderInfo = 'Reminder',
		IDResource = 1,--a.IdProgramaImplementaAccion,
        StartTime = FechaInicioProgramada,
		Status = null,
        Subject =a.Descripcion,-- convert(varchar,FechaInicioProgramada,103) + '-'+convert(varchar,FechaFinProgramada,103),
		EventType = null
	INTO #TMPResult
	from [dbo].[CO_ProgramaImplementa] p
	inner join [dbo].[CO_ProgramaImplementaElemento] e on e.IdProgramaImplementa = p.IdProgramaImplementa
	inner join [dbo].[CO_ProgramaImplementaAcciones] a on a.IdProgramaImplementaElemento = e.IdProgramaImplementaElemento
	inner join [dbo].[CO_ProgramaImplementaProgramacion] prog on prog.IdProgramaImplementaAccion = a.IdProgramaImplementaAccion
	where p.IdProgramaImplementa = @pIdProgramaImplementa and
	@pIdAccion in (0,a.IdProgramaImplementaAccion)

	insert into #tmpResult
	select distinct ID = prog.IdProgramaImplementaProgramacion,
		AllDay=null,
        Description=convert(varchar,FechaInicioImplementa,103) + '-'+convert(varchar,FechaFinImplementa,103),
		EndTime = prog.FechaFinImplementa,
		Label = 3,
		Location = 'Imp.',
		RecurrenceInfo =  a.IdProgramaImplementaAccion,
		ReminderInfo = '',
		IDResource =1,-- a.IdProgramaImplementaAccion,
        StartTime = FechaInicioImplementa,
		Status = null,
        Subject =a.Descripcion,-- convert(varchar,FechaInicioImplementa,103) + '-'+convert(varchar,FechaFinImplementa,103),
		EventType = null
	from [dbo].[CO_ProgramaImplementa] p
	inner join [dbo].[CO_ProgramaImplementaElemento] e on e.IdProgramaImplementa = p.IdProgramaImplementa
	inner join [dbo].[CO_ProgramaImplementaAcciones] a on a.IdProgramaImplementaElemento = e.IdProgramaImplementaElemento
	inner join [dbo].[CO_ProgramaImplementaProgramacion] prog on prog.IdProgramaImplementaAccion = a.IdProgramaImplementaAccion
	where p.IdProgramaImplementa = @pIdProgramaImplementa and
	prog.FechaInicioImplementa is not null and prog.FechaFinImplementa is not null --AND
	--PROG.IdProgramaImplementaProgramacion <> 15
	and
	@pIdAccion in (0,a.IdProgramaImplementaAccion)

	ORDER BY prog.IdProgramaImplementaProgramacion

	select *
	from #tmpResult
	order by EndTime,StartTime

