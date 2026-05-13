CREATE	PROCEDURE [dbo].[sp_GeneraFechasProcesosConFechaFinal] --1,10061,'2019-05-01',10009--SIMULACION  Fecha FINAL
    @idContrato INT,
    @idUsuario INT,
    @FechaInicial DATE,
    @idProceso INT
AS
BEGIN
-- =============================================
-- Author:      Bárbara Arrañaga
-- Create date: 20181023
-- Description: Genera Calculo de fechas(SIMULACION FECHA FINAL)
-- =============================================
SET NOCOUNT ON

CREATE TABLE #Actividades
(
    IdProceso   INT,
    DescripcionProceso VARCHAR(500),
    IdContrato  INT,
    Orden   INT,
    IdActividad INT,
    NombreActividad VARCHAR(500),
    Dias    INT,
    DiasNaturales   BIT,
    FechaInicial    DATE,
    FechaLimite     DATE,
    IdActividadPredecesora  INT,
    IdActividadSucesora     INT
)

CREATE TABLE #DiasHabiles
(
    Id  INT IDENTITY (1,1),
    IdFecha DATE
)

CREATE TABLE #SucesorAntecesor
(
    IdActividad     INT,
    OrdenSucesor    INT,
    OrdenAntecesor  INT
)

DECLARE
    @FechaInicialSig    DATE,
    @IdActividad    INT,
    @NvaFechaIni    DATE,
    @NvaFechaFin    DATE,
    @OrdenMax INT,
    @IsSerie bit,
    @BitDiasNaturales BIT = 0,
    @Regulador INT = 0,
	@MismoRegulador INT = 0

SELECT @IsSerie=ISNULL(IsSerie,1) FROM dbo.EN_Procesos WHERE IdProceso=@idProceso;-- si esta null lo tomamos como lineal

SELECT TOP 1 @Regulador = ISNULL(A.IdRegulador,0)
FROM 
	EN_ProcesosActividades PA
JOIN
	EN_Actividades	A 
	ON	PA.idActividad	=	A.IdActividad 
    AND  PA.IdProceso	=	@idProceso 
    AND PA.IdContrato	=	@IdContrato
WHERE	
	PA.Activo = 1
	AND PA.Orden >= 0
ORDER BY PA.Orden

SELECT 
	@MismoRegulador	= COUNT(DISTINCT ISNULL(A.IdRegulador,0) )
FROM 
	EN_ProcesosActividades	PA
JOIN 
	EN_Actividades A 
	ON	PA.idActividad	=	A.IdActividad 
	AND	PA.IdProceso	=	@idProceso 
	AND	PA.IdContrato	=	@IdContrato
WHERE  PA.Activo = 1
	   AND PA.Orden	>=	0


IF ISNULL(@Regulador,0)	=	0
BEGIN
    INSERT INTO #DiasHabiles
    ( IdFecha   )
    SELECT
        A.IdFecha
    FROM 
        dbo.AP_Calendario A
    WHERE
		A.IdFecha < @FechaInicial
      AND DATEADD(YEAR, -5, @FechaInicial) <= A.IdFecha
	  AND FinDeSemana =   0
        AND DiaLaborable = 1
    ORDER BY
        A.IdFecha DESC
END
ELSE
BEGIN
	INSERT INTO #DiasHabiles
    ( IdFecha   )
	SELECT
        A.IdFecha
    FROM 
        dbo.AP_Calendario A
    LEFT JOIN 
		AP_CalendarioExcepciones	CE 
		ON	A.IdFecha	=	CE.IdFecha 
		AND	CE.Activo	=	1 
		AND	CE.IdRegulador	=	@Regulador
    WHERE
        A.IdFecha	<=	@FechaInicial
        AND DATEADD(YEAR, -5, @FechaInicial) <= A.IdFecha
        AND	FinDeSemana	=	0
        AND	DiaLaborable	=	1
        AND	CE.IdFecha	IS	NULL
    ORDER BY
        A.IdFecha DESC
END

Select @OrdenMax=Max(orden) 
FROM
	EN_Procesos P
JOIN
	EN_ProcesosActividades  PA
	ON  P.IdProceso =   PA.IdProceso
	AND PA.IdContrato=@IdContrato
JOIN
	EN_Actividades  A
	ON  PA.IdActividad  =   A.IdActividad
WHERE
	P.IdProceso	=	@IdProceso
	AND	PA.Activo   =   1
	AND	A.Activo    =   1
	AND PA.Orden >= 0

IF @IsSerie = 0 AND @MismoRegulador = 1
BEGIN
	TRUNCATE TABLE #DiasHabiles

	IF ISNULL(@Regulador,0)	=	0
	BEGIN
		INSERT INTO #DiasHabiles
		( IdFecha   )
		SELECT
			A.IdFecha
		FROM 
			dbo.AP_Calendario A
		WHERE
			A.IdFecha < @FechaInicial
		  AND DATEADD(YEAR, -5, @FechaInicial) <= A.IdFecha
		  AND FinDeSemana =   0
			AND DiaLaborable = 1
		ORDER BY
			A.IdFecha DESC
	END
	ELSE
	BEGIN
		INSERT INTO #DiasHabiles
		( IdFecha   )
		SELECT
			A.IdFecha
		FROM 
			dbo.AP_Calendario A
		LEFT JOIN 
			AP_CalendarioExcepciones	CE 
			ON	A.IdFecha	=	CE.IdFecha 
			AND	CE.Activo	=	1 
			AND	CE.IdRegulador	=	@Regulador
		WHERE
			A.IdFecha	<	@FechaInicial
			AND DATEADD(YEAR, -5, @FechaInicial) <= A.IdFecha
			AND	FinDeSemana	=	0
			AND	DiaLaborable	=	1
			AND	CE.IdFecha	IS	NULL
		ORDER BY
			A.IdFecha DESC
	END
   
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
		PA.Orden,
		A.IdActividad,
		A.NombreActividad,
		A.Dias,
		A.DiasNaturales,
		CASE WHEN A.DiasNaturales = 1 AND A.Dias <> 1
			THEN DATEADD(DAY, -A.Dias, @FechaInicial)
			WHEN A.DiasNaturales = 1 AND A.Dias = 1
			THEN @FechaInicial
			WHEN A.DiasNaturales = 0 AND FI.DiaLaborable = 1
				THEN DH.IdFecha--THEN DATEADD(DAY,-A.Dias, @FechaInicial)
			WHEN A.DiasNaturales = 0 AND FI.DiaLaborable = 0
			THEN DH.IdFecha
		END,
		CASE WHEN A.DiasNaturales = 1
			THEN @FechaInicial
			WHEN A.DiasNaturales = 0 AND FI.DiaLaborable = 1
			THEN @FechaInicial
		   WHEN A.DiasNaturales = 0 AND FI.DiaLaborable = 0
			THEN MAX(C2.IdFecha)
		END AS FechaLimite
	FROM
		EN_Procesos P
	JOIN
		EN_ProcesosActividades  PA
		ON  P.IdProceso =   PA.IdProceso
		AND PA.IdContrato	=	@IdContrato
	JOIN
		EN_Actividades  A
		ON  PA.IdActividad  =   A.IdActividad
	JOIN
		dbo.AP_Calendario   FI
		ON  @FechaInicial   =   FI.IdFecha
	JOIN
		#DiasHabiles    DH
		ON  @FechaInicial   >=  DH.IdFecha
		AND A.Dias = DH.Id 
	JOIN
		dbo.AP_Calendario   C2
		ON  @FechaInicial   >=  C2.IdFecha
		AND C2.IdFecha  >   DATEADD(YEAR, -5, @FechaInicial)
		AND C2.FinDeSemana  =   0
		AND C2.DiaLaborable = 1
	WHERE
		P.IdProceso =   @IdProceso
		AND
		PA.Activo   =   1
		AND
		A.Activo    =   1
		AND PA.Orden >= 0
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
		PA.Orden DESC

END
ELSE
BEGIN
  
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
		PA.Orden,
		A.IdActividad,
		A.NombreActividad,
		A.Dias,
		A.DiasNaturales,
		CASE WHEN PA.Orden = @OrdenMax AND A.DiasNaturales = 1 AND A.Dias <> 1
			THEN DATEADD(DAY, -A.Dias, @FechaInicial)
			WHEN PA.Orden = @OrdenMax AND A.DiasNaturales = 1 AND A.Dias = 1
			THEN @FechaInicial
			WHEN PA.Orden =@OrdenMax AND A.DiasNaturales = 0 AND FI.DiaLaborable = 1
				THEN DH.IdFecha--THEN DATEADD(DAY,-A.Dias, @FechaInicial)
			WHEN PA.Orden =@OrdenMax AND A.DiasNaturales = 0 AND FI.DiaLaborable = 0
			THEN DH.IdFecha
		END,
		CASE WHEN PA.Orden =@OrdenMax AND A.DiasNaturales = 1
			THEN @FechaInicial
			WHEN PA.Orden =@OrdenMax AND A.DiasNaturales = 0 AND FI.DiaLaborable = 1
			THEN @FechaInicial
		   WHEN PA.Orden =@OrdenMax AND A.DiasNaturales = 0 AND FI.DiaLaborable = 0
			THEN MAX(C2.IdFecha)
		END AS FechaLimite
	FROM
		EN_Procesos P
	JOIN
		EN_ProcesosActividades  PA
		ON  P.IdProceso =   PA.IdProceso
		AND PA.IdContrato	=	@IdContrato
	JOIN
		EN_Actividades  A
		ON  PA.IdActividad  =   A.IdActividad
	JOIN
		dbo.AP_Calendario   FI
		ON  @FechaInicial   =   FI.IdFecha
	JOIN
		#DiasHabiles    DH
		ON  @FechaInicial   >=  DH.IdFecha
		AND A.Dias = DH.Id 
	JOIN
		dbo.AP_Calendario   C2
		ON  @FechaInicial   >=  C2.IdFecha
		AND C2.IdFecha  >   DATEADD(YEAR, -5, @FechaInicial)
		AND C2.FinDeSemana  =   0
		AND C2.DiaLaborable = 1
	WHERE
		P.IdProceso =   @IdProceso
		AND
		PA.Activo   =   1
		AND
		A.Activo    =   1
		AND PA.Orden >= 0
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
		PA.Orden DESC
END


INSERT INTO #SucesorAntecesor
(
    IdActividad,
    OrdenSucesor,
    OrdenAntecesor
)
SELECT
    A.IdActividad, MAx(A2.Orden), MIN(A3.Orden)
FROM
    #Actividades    A
LEFT JOIN
    #Actividades    A2
    ON  A.Orden >   A2.Orden
LEFT JOIN
    #Actividades 
   A3
    ON  A.Orden <   A3.Orden
GROUP BY
    A.IdActividad
    --Select * from #SucesorAntecesor

UPDATE  A
    SET
        A.IdActividadSucesora   =   S.IdActividad,
        A.IdActividadPredecesora    =   ANT.IdActividad
FROM
    #Actividades    A
JOIN
    #SucesorAntecesor   SA
    ON  A.IdActividad   =   SA.IdActividad
LEFT JOIN
    #Actividades    S
    ON  SA.OrdenSucesor =   S.Orden
LEFT JOIN
    #Actividades    ANT
    ON  SA.OrdenAntecesor   =   ANT.Orden

WHILE (SELECT COUNT(1) FROM #Actividades WHERE FechaLimite IS NULL ) > 0
BEGIN
--DECLARE @FechaInicialSig  DATE,@IdActividad   INT,    @NvaFechaIni    DATE,@NvaFechaFin   DATE;
    SELECT TOP 1
       @FechaInicialSig = CASE @IsSerie
                              WHEN 1 THEN
                                  CASE  WHEN Orden > 0 THEN
                                          DATEADD(DAY, -1, FechaInicial)
                                      ELSE
                                          FechaInicial
									END
                              ELSE
                                  @FechaInicial
                          END,
       @IdActividad = IdActividadSucesora
FROM 
	#Actividades
WHERE 
	FechaLimite IS NOT NULL
ORDER BY 
	Orden ASC

SELECT @BitDiasNaturales = DiasNaturales
FROM dbo.EN_Actividades A
WHERE IdActividad = @IdActividad
    
    
SELECT @Regulador = ISNULL(A.IdRegulador,0)
FROM 
	EN_ProcesosActividades	PA
JOIN 
	EN_Actividades	A 
	ON	PA.idActividad	=	A.IdActividad 
	AND	PA.idActividad =	@IdActividad
	AND	PA.IdProceso	=	@idProceso 
	AND	PA.IdContrato	=	@IdContrato 

    TRUNCATE TABLE #DiasHabiles

IF @BitDiasNaturales = 0
BEGIN

    INSERT INTO #DiasHabiles
    (
        IdFecha
    )
    SELECT
        A.IdFecha
    FROM 
        dbo.AP_Calendario A
	LEFT JOIN 
		AP_CalendarioExcepciones	CE 
		ON A.IdFecha	=	CE.IdFecha 
		AND	CE.Activo	=	1 
		AND	CE.IdRegulador	=	@Regulador
    WHERE
        A.IdFecha	<	@FechaInicialSig
        AND DATEADD(YEAR,	-5, @FechaInicialSig)	<=	A.IdFecha
        AND FinDeSemana	=	0
        AND DiaLaborable	=	1
        AND CE.IdFecha IS NULL
    ORDER BY
        A.IdFecha DESC;
END
ELSE
BEGIN

    INSERT INTO #DiasHabiles
    (
        IdFecha
    )
    SELECT
        A.IdFecha
    FROM 
        dbo.AP_Calendario A
	WHERE
		A.IdFecha <= @FechaInicialSig
		AND DATEADD(YEAR, -5, @FechaInicialSig) <=  A.IdFecha
	ORDER BY
		A.IdFecha DESC;
END

SELECT
	@NvaFechaFin	=	CASE WHEN A.DiasNaturales = 1
                        THEN @FechaInicialSig
                        WHEN A.DiasNaturales = 0 AND FI.DiaLaborable = 1
                        THEN @FechaInicialSig
                        WHEN A.DiasNaturales = 0 AND FI.DiaLaborable = 0
						THEN MAX(C2.IdFecha)
			            END,
    @NvaFechaIni    =   CASE WHEN A.DiasNaturales = 1 AND A.Dias <> 1
                        THEN DATEADD(DAY,-A.Dias, @FechaInicialSig)
                        WHEN A.DiasNaturales = 1 AND A.Dias = 1
                        THEN @FechaInicialSig
                        WHEN A.DiasNaturales = 0 AND FI.DiaLaborable = 1
                        THEN DH.IdFecha
                        WHEN A.DiasNaturales = 0 AND FI.DiaLaborable = 0
                        THEN DH.IdFecha
                  END
    FROM
        #Actividades    A
    JOIN
        dbo.AP_Calendario   FI
        ON  @FechaInicialSig    =   FI.IdFecha
    JOIN
        #DiasHabiles    DH
        ON  @FechaInicialSig >= DH.IdFecha
        AND A.Dias= DH.Id
    JOIN
        dbo.AP_Calendario   C2
        ON  @FechaInicialSig    >=  C2.IdFecha
        AND C2.IdFecha  >   DATEADD(YEAR, -5, @FechaInicialSig)
	    AND C2.FinDeSemana  =   0
        AND C2.DiaLaborable = 1
    WHERE
        A.IdActividad = @IdActividad
    GROUP BY
        A.Dias,
        A.DiasNaturales,
        FI.DiaLaborable,
        DH.IdFecha,
        a.fechaInicial,
		a.FechaLimite,
		a.idactividadPredecesora,
		a.idActividadSucesora
    
    UPDATE #Actividades 
        SET
            FechaInicial    =   @NvaFechaIni,
            FechaLimite     =   @NvaFechaFin
    WHERE
        IdActividad = @IdActividad

    SELECT  @BitDiasNaturales = 1
END

Select idProceso,DescripcionProceso,idContrato,orden,idActividad,NombreActividaD,dias,DiasNaturales,FechaInicial,FechaLimite,idActividadPredecesora,idActividadSucesora  
FROM 
	#Actividades 
order by 
	fechaInicial asc

END;
