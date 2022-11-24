-- =============================================
-- Author:		<Stephany Vega>
-- Create date: <29/04/20>
-- Description:	<Description,,>
-- =============================================
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <17/01/21>
-- Description:	<Opcion de todos los reguladores en el calendario>
-- =============================================
CREATE PROCEDURE [dbo].[sp_AP_ExtraeCalendario_v2] --[sp_AP_ExtraeCalendario_v2] 3,0,10001
	-- Add the parameters for the stored procedure here
	@idContrato INT,
	@idUsuario INT,
	@IdRegulador INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CONT INT = 1;
	DECLARE @CONT_TOTAL INT = 0;
	DECLARE @REGULADORINT INT = 0;
	DECLARE @NOMBREREGULADORINT VARCHAR(1000) = '';

	CREATE TABLE #CALENDARIO(
		ID DATETIME,
		Description VARCHAR(1000),
		EndTime DATETIME,
		Location VARCHAR(1000),
		ReminderInfo VARCHAR(1000),
		StartTime DATETIME,
		Status VARCHAR(1000),
		Subject VARCHAR(1000),
		RecurrenceInfo INT,
		IDResource INT,
		Label INT
	);

	CREATE TABLE #REGULADORES(
		ID INT IDENTITY(1,1),
		IDREGULADOR INT,
		REGULADOR VARCHAR(1000)
	);

    -- DEFAULT
	IF(@IdRegulador=0)
	BEGIN
		
		INSERT INTO #CALENDARIO (
			ID,
			Description,
			EndTime,
			Location,
			ReminderInfo,
			StartTime,
			Status,
			Subject,
			RecurrenceInfo,
			IDResource 
		)
		SELECT  
			IdFecha,
			Descripcion,
			TerminoDia,
			CASE WHEN DiaFeriado=1 THEN 'Día Feriado' END,
			'Reminder',
			InicioDia,
			CASE WHEN DiaFeriado=1 THEN 'Día Feriado' END,
			Descripcion,
			1,
			1
		FROM AP_Calendario
		WHERE ANIO   >= YEAR(GETDATE())
				AND   IdFecha <= DATEADD(YEAR,5,GETDATE())
				AND DiaLaborable <> 1
				AND FinDeSemana <> 1
	END
	
	--POR REGULADOR
	IF @IdRegulador IN (SELECT IdRegulador FROM CO_Regulador)
	BEGIN
			
		INSERT INTO #CALENDARIO (
			ID,
			Description,
			EndTime,
			Location,
			ReminderInfo,
			StartTime,
			Status,
			Subject,
			RecurrenceInfo,
			IDResource
		)
		SELECT  
			C.IdFecha,
			CASE 
				WHEN ISNULL(LEN(C.Descripcion),0) <> 0 AND ISNULL(LEN(CE.Descripcion),0)<> 0 THEN  CONCAT(C.Descripcion ,',',CE.Descripcion)
				WHEN  ISNULL(LEN(C.Descripcion),0) <> 0  AND ISNULL(LEN(CE.Descripcion),0) = 0 THEN  C.Descripcion 
				WHEN ISNULL(LEN(C.Descripcion),0) = 0 AND ISNULL(LEN(CE.Descripcion),0)<> 0 THEN  CE.Descripcion 
				ELSE ' '
			END,
			TerminoDia,
			CASE WHEN DiaFeriado=1 THEN 'Día Feriado' END,
			'Reminder',
			InicioDia,
			CASE WHEN DiaFeriado=1 THEN 'Día Feriado' END,
			CASE 
				WHEN ISNULL(LEN(C.Descripcion),0) <> 0 AND ISNULL(LEN(CE.Descripcion),0)<> 0 THEN  CONCAT(C.Descripcion ,',',CE.Descripcion)
				WHEN ISNULL(LEN(C.Descripcion),0) <> 0  AND ISNULL(LEN(CE.Descripcion),0) = 0 THEN  C.Descripcion
				WHEN ISNULL(LEN(C.Descripcion),0) = 0 AND ISNULL(LEN(CE.Descripcion),0)<> 0 THEN  CE.Descripcion
				ELSE ' '
			END,
			1,
			1
		FROM  AP_Calendario C
			LEFT JOIN AP_CalendarioExcepciones CE 
				ON C.IdFecha= CE.IdFecha 
				AND CE.IdRegulador=@IdRegulador
		WHERE ANIO   >= YEAR(GETDATE())
			AND   C.IdFecha <= DATEADD(YEAR,5,GETDATE())
			AND CASE 
					 WHEN ISNULL(LEN(C.Descripcion),0) <> 0 AND ISNULL(LEN(CE.Descripcion),0)<> 0 THEN  CONCAT(C.Descripcion ,',',CE.Descripcion)
					 WHEN ISNULL(LEN(C.Descripcion),0) <> 0  AND ISNULL(LEN(CE.Descripcion),0) = 0 THEN  C.Descripcion 
					 WHEN ISNULL(LEN(C.Descripcion),0) = 0 AND ISNULL(LEN(CE.Descripcion),0)<> 0 THEN  CE.Descripcion
					 ELSE ' '
				END <> ' '
			AND FinDeSemana <> 1

	END

	--TODOS LOS REGULADORES
	IF @IdRegulador = 10001
	BEGIN

		INSERT INTO #REGULADORES
		SELECT 
			R.IdRegulador,
			R.Regulador
		FROM AP_CalendarioExcepciones CE
			JOIN CO_Regulador R 
				ON CE.IdRegulador=R.IdRegulador
		GROUP BY R.IdRegulador,
			R.Regulador,
			R.NombreRegulador;
			
		SET @CONT_TOTAL = (SELECT COUNT(ID) FROM #REGULADORES);
		SET @NOMBREREGULADORINT = (SELECT COUNT(ID) FROM #REGULADORES);

		WHILE @CONT <= @CONT_TOTAL
		BEGIN

			SET @REGULADORINT = (SELECT IDREGULADOR FROM #REGULADORES WHERE ID = @CONT)
			SET @NOMBREREGULADORINT = (SELECT REGULADOR FROM #REGULADORES WHERE ID = @CONT);
			
			INSERT INTO #CALENDARIO (
				ID,
				Description,
				EndTime,
				Location,
				ReminderInfo,
				StartTime,
				Status,
				Subject,
				RecurrenceInfo,
				IDResource,
				Label
			)
			SELECT  
				DATEADD(MINUTE,@CONT,CAST(C.IdFecha AS DATETIME)),
				CASE 
					WHEN ISNULL(LEN(C.Descripcion),0) <> 0 AND ISNULL(LEN(CE.Descripcion),0)<> 0 THEN  CONCAT(C.Descripcion ,',',CE.Descripcion,' - ',@NOMBREREGULADORINT)
					WHEN ISNULL(LEN(C.Descripcion),0) <> 0  AND ISNULL(LEN(CE.Descripcion),0) = 0 THEN  CONCAT(C.Descripcion,' - ',@NOMBREREGULADORINT)
					WHEN ISNULL(LEN(C.Descripcion),0) = 0 AND ISNULL(LEN(CE.Descripcion),0)<> 0 THEN  CONCAT(CE.Descripcion,' - ',@NOMBREREGULADORINT)
					ELSE ' '
				END,
				TerminoDia,
				CASE
					WHEN DiaFeriado=1 THEN 'Día Feriado'
				END,
				'Reminder',
				InicioDia,
				CASE
					WHEN DiaFeriado=1 THEN 'Día Feriado'
				END,
				CASE 
					WHEN ISNULL(LEN(C.Descripcion),0) <> 0 AND ISNULL(LEN(CE.Descripcion),0)<> 0 THEN  CONCAT(C.Descripcion ,',',CE.Descripcion,' - ',@NOMBREREGULADORINT)
					WHEN ISNULL(LEN(C.Descripcion),0) <> 0  AND ISNULL(LEN(CE.Descripcion),0) = 0 THEN CONCAT(C.Descripcion,' - ',@NOMBREREGULADORINT)
					WHEN ISNULL(LEN(C.Descripcion),0) = 0 AND ISNULL(LEN(CE.Descripcion),0)<> 0 THEN  CONCAT(CE.Descripcion,' - ',@NOMBREREGULADORINT)
					ELSE ' '
				END,
				1,
				1,
				@CONT
			FROM  AP_Calendario C
			LEFT JOIN AP_CalendarioExcepciones CE 
				ON C.IdFecha= CE.IdFecha 
				AND CE.IdRegulador=@REGULADORINT
			WHERE ANIO   >= YEAR(GETDATE())
				AND   C.IdFecha <= DATEADD(YEAR,5,GETDATE())
				AND CASE 
					 WHEN ISNULL(LEN(C.Descripcion),0) <> 0 AND ISNULL(LEN(CE.Descripcion),0)<> 0 THEN  CONCAT(C.Descripcion ,',',CE.Descripcion)
					 WHEN ISNULL(LEN(C.Descripcion),0) <> 0  AND ISNULL(LEN(CE.Descripcion),0) = 0 THEN  C.Descripcion 
					 WHEN ISNULL(LEN(C.Descripcion),0) = 0 AND ISNULL(LEN(CE.Descripcion),0)<> 0 THEN  CE.Descripcion
					 ELSE ' '
				END <> ' '
				AND FinDeSemana <> 1

			SET @CONT = @CONT + 1;

		END

	END

	SELECT
		ID,
		AllDay = NULL,
		Description,
		EndTime,
		Label,
		Location,
		RecurrenceInfo,
		ReminderInfo,
		IDResource,
		StartTime,
		Status,
		Subject,
		EventType = NULL
	FROM #CALENDARIO
	ORDER BY ID,Label ASC;

END