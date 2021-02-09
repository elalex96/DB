-- =============================================
-- Author:		<Stephany>
-- Create date: <29/04/20>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_AP_ExtraeCalendario_v2]
	-- Add the parameters for the stored procedure here
	@idContrato INT,
	@idUsuario INT,
	@IdRegulador INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(@IdRegulador=0)
	BEGIN
		SELECT  ID=IdFecha,
				AllDay=NULL,
				Description = Descripcion,
				EndTime=TerminoDia,
				Label=3,
				Location = CASE
								--WHEN DiaLaborable=1 THEN 'Día Laborable'
								--WHEN FinDeSemana=1 THEN 'Fin de Semana'
								WHEN DiaFeriado=1 THEN 'Día Feriado'
						   END,
			    RecurrenceInfo = 1,
				ReminderInfo = 'Reminder',
				IDResource = 1,
				StartTime=InicioDia,
				Status=    CASE
								--WHEN DiaLaborable=1 THEN 'Día Laborable'
								--WHEN FinDeSemana=1 THEN 'Fin de Semana'
								WHEN DiaFeriado=1 THEN 'Día Feriado'
						   END,
				Subject= Descripcion,
				EventType = NULL
				FROM AP_Calendario
				WHERE ANIO   >= YEAR(GETDATE())
				AND   IdFecha <= DATEADD(YEAR,5,GETDATE())
				AND DiaLaborable <> 1
				AND FinDeSemana <> 1
	END
	ELSE
	BEGIN
			SELECT  C.IdFecha,
			AllDay=NULL,
			Description = CASE 
					  WHEN ISNULL(LEN(C.Descripcion),0) <> 0 AND ISNULL(LEN(CE.Descripcion),0)<> 0
						THEN  CONCAT(C.Descripcion ,',',CE.Descripcion)
					  WHEN  ISNULL(LEN(C.Descripcion),0) <> 0  AND ISNULL(LEN(CE.Descripcion),0) = 0
						THEN  C.Descripcion
					  WHEN ISNULL(LEN(C.Descripcion),0) = 0 AND ISNULL(LEN(CE.Descripcion),0)<> 0
						THEN  CE.Descripcion
					 ELSE ' '
					END,
			EndTime=TerminoDia,
			Label=3,
			Location= CASE
						  --WHEN DiaLaborable=1 THEN 'Día Laborable'
						  --WHEN FinDeSemana=1 THEN 'Fin de Semana'
						  WHEN DiaFeriado=1 THEN 'Día Feriado'
				      END,
			RecurrenceInfo=1,
			ReminderInfo='Reminder',
			IDResource=1,
			StartTime=InicioDia,
			Status= CASE
						--WHEN DiaLaborable=1 THEN 'Día Laborable'
						--WHEN FinDeSemana=1 THEN 'Fin de Semana'
						WHEN DiaFeriado=1 THEN 'Día Feriado'
					END,
			Subject= CASE 
					  WHEN ISNULL(LEN(C.Descripcion),0) <> 0 AND ISNULL(LEN(CE.Descripcion),0)<> 0
						THEN  CONCAT(C.Descripcion ,',',CE.Descripcion)
					  WHEN  ISNULL(LEN(C.Descripcion),0) <> 0  AND ISNULL(LEN(CE.Descripcion),0) = 0
						THEN  C.Descripcion
					  WHEN ISNULL(LEN(C.Descripcion),0) = 0 AND ISNULL(LEN(CE.Descripcion),0)<> 0
						THEN  CE.Descripcion
					 ELSE ' '
					END,
		    EventType = NULL
			FROM  AP_Calendario C
				LEFT JOIN AP_CalendarioExcepciones CE 
					ON C.IdFecha= CE.IdFecha 
						AND CE.IdRegulador=@IdRegulador
			WHERE ANIO   >= YEAR(GETDATE())
			     AND   C.IdFecha <= DATEADD(YEAR,5,GETDATE())
				 AND CASE 
					  WHEN ISNULL(LEN(C.Descripcion),0) <> 0 AND ISNULL(LEN(CE.Descripcion),0)<> 0
						THEN  CONCAT(C.Descripcion ,',',CE.Descripcion)
					  WHEN  ISNULL(LEN(C.Descripcion),0) <> 0  AND ISNULL(LEN(CE.Descripcion),0) = 0
						THEN  C.Descripcion
					  WHEN ISNULL(LEN(C.Descripcion),0) = 0 AND ISNULL(LEN(CE.Descripcion),0)<> 0
						THEN  CE.Descripcion
					 ELSE ' '
					END <> ' '
				 AND FinDeSemana <> 1
	END
END
GO


