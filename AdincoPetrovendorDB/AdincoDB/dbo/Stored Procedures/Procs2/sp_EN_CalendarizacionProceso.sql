/****** Object:  StoredProcedure [dbo].[sp_EN_CalendarizacionProceso]    Script Date: 16/04/2019 10:03:56 p. m. ******/
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	FormaCalendario
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_CalendarizacionProceso]--3,2,11028,10035
	@idContrato INT,
	@idUsuario INT,
	@IdProceso INT,
	@idInstanciaProcesos INT
AS
BEGIN

	SET NOCOUNT ON;
SELECT  ID = IE.idInstanciaEntregable,
       AllDay = NULL,
       Description = 'Actividad: '+ NombreActividad,
       EndTime = DATEADD(MINUTE, 59, DATEADD(HOUR, 23, FechasLimiteAprobacion)),
       Label = 3,
       Location = reg.Regulador,
       RecurrenceInfo = 1,
       ReminderInfo = 'Reminder',
       IDResource = 1,
       StartTime = DATEADD(DAY, 0, FechasLimiteAprobacion),

	  -- StartTimeReal = DATEADD(DAY, 3, FechasLimiteAprobacion),
	   --EndTimeReal = DATEADD(DAY,10,FechasLimiteAprobacion),

       Status = ES.NombreEstado,
       Subject ='Entregable: ' +e.DocumentoEntregable,
       EventType = NULL
	  -- Select * 
FROM EN_InstanciasProcesosFecha IP
    JOIN EN_InstanciasActividades IA 
        ON IP.IdInstanciasProcesos = IA.IdInstanciasProcesos AND idContrato=@idContrato AND IdProceso=@IdProceso
    JOIN EN_ActividadesEntregables AE
        ON AE.IdActividad = IA.IdActividad
		Join EN_Actividades AC ON AC.IdActividad = IA.IdActividad
    JOIN EN_contratoEntregable CE
        ON AE.idEntregable = CE.idEntregable
           AND CE.IdContrato = @idContrato
    JOIN en_entregable E
        ON CE.idEntregable = E.idEntregable
    JOIN EN_FrecuenciaEntregable FE
        ON E.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable
    JOIN EN_instanciasEntregable IE
        ON IE.FechasLimiteAprobacion = IA.FechaActividad
           AND CE.idContratoEntregable = IE.idContratoEntregable
	JOIN EN_actividad  EA ON IE.ActividadId=EA.ActividadId
	JOIN EN_Estado ES ON EA.EstadoId= ES.EstadoId
    LEFT JOIN CO_Regulador reg
        ON reg.IdRegulador = E.IdRegulador
		WHERE IA.IdInstanciasProcesos=@idInstanciaProcesos
		ORDER BY DATEADD(DAY, ISNULL(DiasAprobacion, 0), FechasLimiteAprobacion);


		END
		--SELECT * FROM en_procesos