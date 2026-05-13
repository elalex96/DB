CREATE PROCEDURE [dbo].[sp_GeneraFechasProcesosParalelos]-- 1,10061,'2018-10-25',10009--SIMULACION  Fecha Inicial
    @idContrato INT,
    @idUsuario INT,
    @FechaInicial DATE,
    @idProceso INT
AS
BEGIN

  
    SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#Actividades', 'U') IS NOT NULL
DROP TABLE #Actividades
IF OBJECT_ID('tempdb.dbo.#DiasHabiles', 'U') IS NOT NULL
DROP TABLE #DiasHabiles
IF OBJECT_ID('tempdb.dbo.#SucesorAntecesor', 'U') IS NOT NULL
DROP TABLE #SucesorAntecesor


CREATE TABLE #Actividades
(
	IdProceso	INT,
	DescripcionProceso VARCHAR(500),
	IdContrato	INT,
	Orden	INT,
	IdActividad	INT,
	NombreActividad VARCHAR(500),
	Dias	INT,
	DiasNaturales	BIT,
	FechaInicial	DATE,
	FechaLimite		DATE,
	IdActividadPredecesora	INT,
	IdActividadSucesora		INT
)

CREATE TABLE #DiasHabiles
(
	Id	INT IDENTITY (1,1),
	IdFecha	DATE
)

CREATE TABLE #SucesorAntecesor
(
	IdActividad		INT,
	OrdenSucesor	INT,
	OrdenAntecesor	INT
)

DECLARE
	--@IdProceso	INT,
	--@FechaInicial DATE,
	--@IdContrato	INT,
	@FechaInicialSig	DATE,
	@IdActividad	INT,
	@NvaFechaIni	DATE,
	@NvaFechaFin	DATE


INSERT INTO #DiasHabiles
(
	IdFecha
)
SELECT
	IdFecha
FROM 
	dbo.AP_Calendario
WHERE
	IdFecha >= @FechaInicial
	AND	DATEADD(YEAR, 1, @FechaInicial) >=	IdFecha
	AND FinDeSemana	=	0
	AND DiaLaborable = 1
ORDER BY
	IdFecha

INSERT INTO #Actividades
(
	IdProceso,
	DescripcionProceso,
	IdContrato,
	Orden,
	IdActividad,
	NombreActividad,
	Dias,
	DiasNaturales,
	FechaInicial,
	FechaLimite
)
SELECT
	P.IdProceso,
	P.Descripcion,
	@idContrato,
	--PA.IdContrato,
	PA.Orden,
	A.IdActividad,
	A.NombreActividad,
	A.Dias,
	A.DiasNaturales,
	CASE WHEN PA.Orden = 0 AND A.DiasNaturales = 1
		THEN @FechaInicial
		WHEN PA.Orden = 0 AND A.DiasNaturales = 0 AND FI.DiaLaborable = 1
		THEN @FechaInicial
		WHEN PA.Orden = 0 AND A.DiasNaturales = 0 AND FI.DiaLaborable = 0
		THEN MIN(C2.IdFecha)
	END AS FechaInicial,
	CASE WHEN PA.Orden = 0 AND A.DiasNaturales = 1
		THEN DATEADD(DAY, A.Dias, @FechaInicial)
		WHEN PA.Orden = 0 AND A.DiasNaturales = 0 AND FI.DiaLaborable = 1
		THEN DH.IdFecha
		WHEN PA.Orden = 0 AND A.DiasNaturales = 0 AND FI.DiaLaborable = 0
		THEN DH.IdFecha
	END
FROM
	EN_Procesos	P
JOIN
	EN_ProcesosActividades	PA
	ON	P.IdProceso	=	PA.IdProceso
JOIN
	EN_Actividades	A
	ON	PA.IdActividad	=	A.IdActividad
JOIN
	dbo.AP_Calendario	FI
	ON	@FechaInicial	=	FI.IdFecha
JOIN
	#DiasHabiles	DH
	ON	@FechaInicial	<=	DH.IdFecha
	AND	A.Dias= DH.Id
JOIN
	dbo.AP_Calendario	C2
	ON	@FechaInicial	<=	C2.IdFecha
	AND	C2.IdFecha	<	DATEADD(YEAR, 1, @FechaInicial)
	AND C2.FinDeSemana	=	0
	AND C2.DiaLaborable = 1
WHERE
	P.IdProceso	=	@IdProceso
	--AND
	--PA.IdContrato	=	@IdContrato
	AND
	PA.Activo	=	1
	AND
    A.Activo	=	1
	AND
	PA.Orden IS NOT NULL
GROUP BY
	P.IdProceso,
	P.Descripcion,
	--PA.IdContrato,
	PA.Orden,
	A.IdActividad,
	A.NombreActividad,
	A.Dias,
	A.DiasNaturales,
	FI.DiaLaborable,
	DH.IdFecha
ORDER BY
	PA.Orden


INSERT INTO #SucesorAntecesor
(
	IdActividad,
	OrdenSucesor,
	OrdenAntecesor
)
SELECT
	A.IdActividad, MIN(A2.Orden), MAX(A3.Orden)
FROM
	#Actividades	A
LEFT JOIN
	#Actividades	A2
	ON	A.Orden	<	A2.Orden
LEFT JOIN
	#Actividades	A3
	ON	A.Orden	>	A3.Orden
GROUP BY
	A.IdActividad

UPDATE	A
	SET
		A.IdActividadSucesora	=	S.IdActividad,
		A.IdActividadPredecesora	=	ANT.IdActividad
FROM
	#Actividades	A
JOIN
	#SucesorAntecesor	SA
	ON	A.IdActividad	=	SA.IdActividad
LEFT JOIN
	#Actividades	S
	ON	SA.OrdenSucesor	=	S.Orden
LEFT JOIN
	#Actividades	ANT
	ON	SA.OrdenAntecesor	=	ANT.Orden


WHILE (SELECT COUNT(1) FROM #Actividades WHERE FechaLimite IS NULL ) > 0
BEGIN

	SELECT TOP 1
		@FechaInicialSig = CASE WHEN Orden > 0 THEN DATEADD(DAY,1,@FechaInicial) ELSE FechaLimite END,--**************************Cambio se suma uno
		@IdActividad	=	IdActividadSucesora
	FROM
		#Actividades
	WHERE
		FechaLimite IS NOT NULL
	ORDER BY
		Orden DESC

	TRUNCATE TABLE #DiasHabiles

	INSERT INTO #DiasHabiles
	(
		IdFecha
	)
	SELECT
		IdFecha
	FROM 
		dbo.AP_Calendario
	WHERE
		IdFecha >= @FechaInicialSig
		AND	DATEADD(YEAR, 1, @FechaInicialSig) >=	IdFecha
		AND FinDeSemana	=	0
		AND DiaLaborable = 1
	ORDER BY
		IdFecha

	SELECT
		@NvaFechaIni	=	CASE WHEN A.DiasNaturales = 1
								THEN @FechaInicialSig
								WHEN A.DiasNaturales = 0 AND FI.DiaLaborable = 1
								THEN @FechaInicialSig
								WHEN A.DiasNaturales = 0 AND FI.DiaLaborable = 0
								THEN MIN(C2.IdFecha)
						END,
		@NvaFechaFin	=	CASE WHEN A.DiasNaturales = 1
								THEN DATEADD(DAY, A.Dias, @FechaInicialSig)
								WHEN A.DiasNaturales = 0 AND FI.DiaLaborable = 1
								THEN DH.IdFecha	--DATEADD(DAY, A.Dias, @FechaInicialSig)
								WHEN A.DiasNaturales = 0 AND FI.DiaLaborable = 0
								THEN DH.IdFecha
							END
	FROM
		#Actividades	A
	JOIN
		dbo.AP_Calendario	FI
		ON	@FechaInicialSig	=	FI.IdFecha
	JOIN
		#DiasHabiles	DH
		ON	@FechaInicialSig	<=	DH.IdFecha
		AND	A.Dias = DH.Id 
	JOIN
		dbo.AP_Calendario	C2
		ON	@FechaInicialSig	<=	C2.IdFecha
		AND	C2.IdFecha	<	DATEADD(YEAR, 1, @FechaInicialSig)
		AND C2.FinDeSemana	=	0
		AND C2.DiaLaborable = 1
	WHERE
		A.IdActividad = @IdActividad
	GROUP BY
		A.Dias,
		A.DiasNaturales,
		FI.DiaLaborable,
		DH.IdFecha

	UPDATE #Actividades	
		SET
			FechaInicial	=	@NvaFechaIni,
			FechaLimite		=	@NvaFechaFin
	WHERE
		IdActividad = @IdActividad

END 

SELECT * FROM #Actividades ORDER by fechaInicial asc


END;

