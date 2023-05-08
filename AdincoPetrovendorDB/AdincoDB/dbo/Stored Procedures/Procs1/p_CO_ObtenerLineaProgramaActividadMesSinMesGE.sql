-- p_CO_ObtenerLineaProgramaActividadMesSinMesGE 3,10039
Create Proc p_CO_ObtenerLineaProgramaActividadMesSinMesGE
@pIdContrato int,
@pIdProgramaActividad int
as

	select 
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
		NumeroAnio = datepart(year,anioC.inicio) + (pam.NumeroAnio-1),
		NumeroAnioCaptura = pam.NumeroAnio,
		pam.NumeroMes,
		pam.Actividades,
		pam.Fecha,
		pc.IdContrato,
		anioC.inicio
	from CO_PeriodoContrato pc
	inner join CO_ProgramaActividad pa on pa.IdPeriodoContrato = pc.IdPeriodo
	inner join CO_Presupuesto pre on pre.IdProgramaActividad = pa.IdProgramaActividad
	inner join [dbo].[CO_AnioContractual] anioC on anioC.IdAnioContractual = pre.IdAnioContractual
	INNER JOIN [CO_LineaProgramaActividadMes] pam on pam.IdProgramaActividad = pa.IdProgramaActividad
	inner join CO_ActividadPetroleraCNH ap on ap.IdActividadPetrolera = pam.IdActividadPetrolera
	inner join CO_SubactividadPetrolera sap on sap.IdSubactividadPetrolera = pam.IdSubactividadPetrolera
	inner join dbo.CO_TareaPetrolera tp on tp.IdTareaPetrolera = pam.IdTareaPetrolera
	inner join [dbo].CO_Servicio s on s.IdServicio = pam.IdSubTareaPetrolera 
	--inner join CO_MesGEActualContrato mesC on mesC.IdContrato = pc.IdContrato and
	--								datepart(year,mesGe) = (datepart(year,anioC.inicio) + (pam.NumeroAnio-1)) and
	--								datepart(month,mesGe) = pam.NumeroMes
	where pc.IdContrato = @pIdContrato and
	@pIdProgramaActividad in (pa.IdProgramaActividad)
	