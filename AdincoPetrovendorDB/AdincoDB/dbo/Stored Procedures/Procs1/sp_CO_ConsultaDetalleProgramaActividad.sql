CREATE PROCEDURE [dbo].[sp_CO_ConsultaDetalleProgramaActividad] 
-- Add the parameters for the stored procedure here
@IdProgramaActividad INT = 0
AS
         BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
             SET NOCOUNT ON; -- Insert statements for procedure here
             DECLARE @tipocontrato INT; 
    

/*Identificar tipo de contrato*/


             SELECT @tipocontrato = C.idtipocontrato
             FROM co_programaActividad PA
                  JOIN co_periodocontrato PC ON PA.idperiodocontrato = PC.Idperiodo
                  JOIN co_contrato C ON C.idcontrato = PC.idcontrato
             WHERE Pa.IdProgramaActividad = @IdProgramaActividad; 
    

/*CIE*/

SET LANGUAGE spanish
             IF @tipocontrato = 1
                 BEGIN
                     SELECT LPM.idtiposervicio AS id_Actividad,
                            TS.Nombretiposervicio AS DescripcionActividadPetrolera,
                            LPM.idactividad AS [id_Sub-actividad],
                            AC.Nombreactividad AS SubactividadPetrolera,
                            LPM.idsubactividad AS id_Tarea,
                            SA.nombresubactividad AS TareaPetrolera,
                            S.NombreServicio,
                            YEAR(lpm.AC_PRESUP_MES) AS NumeroAnio,
                            CONCAT(YEAR(AC_PRESUP_MES), ' ',RIGHT('00'+CAST(MONTH(AC_PRESUP_MES) AS VARCHAR(2)), 2), ' ', datename(month, AC_PRESUP_MES))   AS NumeroMes,
                            LPM.volumetria AS Actividades,
                            LPM.AC_PRESUP_MES AS Fecha,
                            0 AS Real
                     FROM CO_lineaPresupuestoMes LPM
                          LEFT JOIN co_tiposervicio TS ON TS.idtiposervicio = LPM.idtiposervicio
                          LEFT JOIN co_actividadCIEP AC ON AC.idactividad = LPM.idactividad
                          LEFT JOIN co_subactividadCIEP SA ON SA.idsubactividad = LPM.idsubactividad
                          LEFT JOIN co_presupuesto P ON P.idpresupuesto = LPM.idpresupuesto
                          INNER JOIN CO_Servicio S ON LPM.idservicio = S.IdServicio
                     WHERE P.idprogramaactividad = @IdProgramaActividad;
                 END;
                 ELSE
                 BEGIN
                     SELECT CO_ActividadPetroleraCNH.id_Actividad,
                            CO_ActividadPetroleraCNH.DescripcionActividadPetrolera,
                            CO_SubactividadPetrolera.[id_Sub-actividad],
                            CO_SubactividadPetrolera.SubactividadPetrolera,
                            CO_TareaPetrolera.id_Tarea,
                            CO_TareaPetrolera.TareaPetrolera,
                            CO_Servicio.NombreServicio,
                            CO_LineaProgramaActividadMes.NumeroAnio,
                            CO_LineaProgramaActividadMes.NumeroMes,
                            CO_LineaProgramaActividadMes.Actividades,
                            CO_LineaProgramaActividadMes.Fecha,
                            0 AS Real
                     FROM CO_LineaProgramaActividadMes
                          INNER JOIN CO_ActividadPetroleraCNH ON CO_LineaProgramaActividadMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
                          INNER JOIN CO_SubactividadPetrolera ON CO_LineaProgramaActividadMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
                          INNER JOIN CO_TareaPetrolera ON CO_LineaProgramaActividadMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
                          INNER JOIN CO_Servicio ON CO_LineaProgramaActividadMes.IdSubTareaPetrolera = CO_Servicio.IdServicio
                     WHERE IdProgramaActividad = @IdProgramaActividad;
                 END;
         END;