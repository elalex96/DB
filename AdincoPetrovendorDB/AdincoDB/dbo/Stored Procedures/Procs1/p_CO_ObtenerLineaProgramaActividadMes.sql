-- p_CO_ObtenerLineaProgramaActividadMes 3,10008
CREATE Proc p_CO_ObtenerLineaProgramaActividadMes
@pIdContrato int,
@pIdProgramaActividad int
as

	select 
		distinct
		pam.IdLineaProgramaActividadMes,
		pam.IdProgramaActividad,
		pam.IdActividadPetrolera,
		pam.IdSubactividadPetrolera,
		pam.IdTareaPetrolera,
		pam.IdSubTareaPetrolera,
		Programa = pa.NombrePrograma,
		ap.DescripcionActividadPetrolera,
		sap.SubactividadPetrolera,
		tp.TareaPetrolera,
		SubTareaPetrolera = isnull(s.NombreServicio,''),
		NumeroAnio = case when pam.NumeroAnio > datepart(year,anioC.inicio) then pam.NumeroAnio
							else datepart(year,anioC.inicio) + (pam.NumeroAnio-1)
					End,
		NumeroAnioCaptura = pam.NumeroAnio,
		pam.NumeroMes,
		pam.Actividades,
		pam.Fecha,
		pc.IdContrato,
		anioC.inicio,
		ActividadAnio = (
			select isnull(sum(Actividades) ,0)
			from [CO_LineaProgramaActividadMes] s1
			where s1.IdProgramaActividad = pa.IdProgramaActividad and
			s1.IdActividadPetrolera = pam.IdActividadPetrolera and
			s1.IdSubactividadPetrolera = pam.IdSubactividadPetrolera and
			s1.IdTareaPetrolera = pam.IdTareaPetrolera and
			s1.IdSubTareaPetrolera = pam.IdSubTareaPetrolera and
			s1.NumeroAnio = pam.NumeroAnio 
		),
		AcumuladoEjecutado = (
			select isnull(sum(CantidadEjecutar) ,0)
			from [CO_LineaProgramaActividadMesDetalle] s1
			where s1.IdLineaProgramaActividadMes = pam.IdLineaProgramaActividadMes
		)
	from CO_PeriodoContrato pc
	inner join CO_ProgramaActividad pa on pa.IdPeriodoContrato = pc.IdPeriodo
	inner join CO_Presupuesto pre on pre.IdProgramaActividad = pa.IdProgramaActividad
	inner join [dbo].[CO_AnioContractual] anioC on anioC.IdAnioContractual = pre.IdAnioContractual
	INNER JOIN [CO_LineaProgramaActividadMes] pam on pam.IdProgramaActividad = pa.IdProgramaActividad
	inner join CO_ActividadPetroleraCNH ap on ap.IdActividadPetrolera = pam.IdActividadPetrolera
	inner join CO_SubactividadPetrolera sap on sap.IdSubactividadPetrolera = pam.IdSubactividadPetrolera
	inner join dbo.CO_TareaPetrolera tp on tp.IdTareaPetrolera = pam.IdTareaPetrolera
	inner join [dbo].CO_Servicio s on s.IdServicio = pam.IdSubTareaPetrolera 
	left join CO_MesGEActualContrato mesC on mesC.IdContrato = pc.IdContrato --and
									--datepart(year,mesGe) = (datepart(year,anioC.inicio) + (pam.NumeroAnio-1)) and
									--datepart(month,mesGe) = pam.NumeroMes
	where pc.IdContrato = @pIdContrato and
	@pIdProgramaActividad in (pa.IdProgramaActividad)

