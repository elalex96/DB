CREATE PROC p_CO_ObtenerLineaProgramaActividadMesDetalle
@pIdProgramaActividad int,
@pIdLineaProgramaActividadMes int
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
		SubTareaPetrolera = isnull(id_SubTarea,''),
		pam.NumeroAnio,
		pam.NumeroMes,
		pam.Actividades,
		pam.Fecha,
		pamD.Id,
		pamD.CantidadEjecutar,
		pamD.UTUnidad,
		pamD.FechaInicio,
		pamD.FechaFin,
		pamD.Comentarios,
		pamD.CreadoEl,
		pamD.CreadoPor
		--IsNull(PamD.IdUnidad,13) as IdUnidad, 
		--ISNULL(u.Unidad,'Servicio') as Unidad
		,u.IdUnidad
		,u.Unidad 
	from CO_PeriodoContrato pc
	inner join CO_ProgramaActividad pa on pa.IdPeriodoContrato = pc.IdPeriodo
	INNER JOIN [CO_LineaProgramaActividadMes] pam on pam.IdProgramaActividad = pa.IdProgramaActividad
	inner join CO_ActividadPetroleraCNH ap on ap.IdActividadPetrolera = pam.IdActividadPetrolera
	inner join CO_SubactividadPetrolera sap on sap.IdSubactividadPetrolera = pam.IdSubactividadPetrolera
	inner join dbo.CO_TareaPetrolera tp on tp.IdTareaPetrolera = pam.IdTareaPetrolera
	left join [dbo].[CO_SubTareaPetrolera] s on s.IdSubTareaPetrolera = pam.IdSubTareaPetrolera 
	inner join [CO_LineaProgramaActividadMesDetalle] pamD on pamD.IdLineaProgramaActividadMes = pam.IdLineaProgramaActividadMes
	inner join CO_Servicio as sv on pam.IdSubTareaPetrolera = sv.IdServicio
	inner join CO_Unidad as u on u.IdUnidad = isnull(pamD.IdUnidad,sv.IdUnidad)
	where pa.IdProgramaActividad = @pIdProgramaActividad and
	pam.IdLineaProgramaActividadMes = @pIdLineaProgramaActividadMes