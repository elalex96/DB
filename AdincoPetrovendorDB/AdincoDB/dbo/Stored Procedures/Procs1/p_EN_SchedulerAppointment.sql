-- p_EN_SchedulerAppointment 3
Create Proc p_EN_SchedulerAppointment
@pIdContrato int
as

	select ID = i.idInstanciaEntregable,
		AllDay=null,
        Description=e.DocumentoEntregable,
		EndTime =
					dateadd(
					MINUTE,
					59,
						dateadd(
								hour,
								23,
								dateadd(day,isnull(DiasAprobacion,0),FechasLimiteAprobacion)
						)
					),
		Label = 3,
		Location =reg.Regulador,
		RecurrenceInfo =  1,
		ReminderInfo = 'Reminder',
		IDResource = 1,
        StartTime = dateadd(day,isnull(DiasAprobacion,0),FechasLimiteAprobacion),
		Status = sta.Estatus,
        Subject = e.DocumentoEntregable,
		EventType = null
	from EN_Instanciasentregable i
	inner join en_contratoentregable ce on ce.IdContratoEntregable = i.IdContratoEntregable
	inner join EN_Entregable e on e.IdEntregable = ce.IdEntregable
	inner join EN_Estatus sta on sta.idEstatus = i.Estatus
	left join CO_Regulador reg on reg.IdRegulador = E.IdRegulador
	where ce.idContrato = @pIdContrato
	order by dateadd(day,isnull(DiasAprobacion,0),FechasLimiteAprobacion)