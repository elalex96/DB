CREATE PROCEDURE SP_Actividades_CONSULTAACTIVIDADES
@pIdContrato int
AS
BEGIN 
SELECT CL.IdLineaProgramaActividadMes, PA.NombrePrograma, AP.DescripcionActividadPetrolera,SAP.SubActividadPetrolera,TP.TareaPetrolera,CL.Fecha, CL.NumeroAnio AS ActividadAnio
FROM CO_LineaProgramaActividadMes as CL
INNER JOIN [dbo].[CO_ProgramaActividad] as PA ON CL.IdProgramaActividad = PA.IdProgramaActividad
INNER JOIN [dbo].[CO_ActividadPetroleraCNH] as AP on CL.IdActividadPetrolera = AP.IdActividadPetrolera
INNER JOIN [dbo].[CO_SubactividadPetrolera] as SAP on CL.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera
INNER JOIN [dbo].[CO_TareaPetrolera] AS TP ON CL.IdTareaPetrolera = TP.IdTareaPetrolera
inner join CO_PeriodoContrato pc on pc.IdPeriodo = pa.IdPeriodoContrato
where pc.idContrato = @pIdContrato
END