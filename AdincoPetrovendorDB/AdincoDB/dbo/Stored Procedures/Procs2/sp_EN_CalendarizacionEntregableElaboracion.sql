-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20190103
-- Description:	FormaCalendario
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_CalendarizacionEntregableElaboracion]-- 3,10061
	@idContrato INT,
	@idUsuario INT
AS
BEGIN

	SET NOCOUNT ON;
SELECT  ID = IE.idInstanciaEntregable,
       AllDay = NULL,
       Description = 'Entregable: '+ DocumentoEntregable,
       EndTime = DATEADD(MINUTE, 59, DATEADD(HOUR, 23, IE.FechasLimiteElaboracion)),
       Label = 3,
       Location =  'Periodo: ' + RTRIM( CONVERT(DATE, IE.FechasLimiteAprobacion)),
       RecurrenceInfo = 1,
       ReminderInfo = 'Reminder',
       IDResource = 1,
       StartTime = DATEADD(DAY, 0, IE.FechasLimiteElaboracion),
       Status = E.NombreEstado,
       Subject ='Entregable: '+ DocumentoEntregable,
       EventType = NULL
	  -- Select *
  FROM
	 EN_Entregable EN    (NOLOCK)
    JOIN
        EN_ContratoEntregable CE    (NOLOCK)
        ON CE.IdContrato = @idContrato  
        AND EN.IdEntregable = CE.IdEntregable
		AND EN.IsActivo = 1
		AND EN.BitJOA = 0
		AND CE.Activo = 1
    JOIN
        EN_InstanciasEntregable IE  (NOLOCK)
        ON  CE.IdContratoEntregable =   IE.IdContratoEntregable
		AND IE.Activo = 1
  JOIN
	 EN_Actividad A	(NOLOCK)
    ON IE.ActividadID            = A.ActividadID
  JOIN
	 EN_Estado E	(NOLOCK)
    ON A.EstadoID                = E.EstadoID
  JOIN
	 dbo.CO_Regulador R
    ON EN.IdRegulador            = R.IdRegulador
  JOIN
	 dbo.EN_MarcoLegal M
    ON EN.IdMarcoLegal           = M.IdMarcoLegal
  JOIN
	 dbo.EN_FrecuenciaEntregable f
    ON EN.IdFrecuenciaEntregable = f.IdFrecuenciaEntregable
  LEFT JOIN --********************************
       dbo.EN_ExcepcionesActividad EXAR --********************************
    ON A.ActividadID             = EXAR.ActividadIDExcepcion --********************************
   AND IE.idInstanciaEntregable  = EXAR.IdInstanciasEntregables --********************************

 WHERE (   A.idUsuario = @idUsuario --********************************
     AND   EXAR.IdInstanciasEntregables IS NULL
     AND   A.EstadoID  = 10000)
    OR --********************************
       (   EXAR.idUsuario = @idUsuario --********************************
     AND   EXAR.IdInstanciasEntregables IS NOT NULL
     AND   EXAR.EstadoID  = 10000) --********************************
END