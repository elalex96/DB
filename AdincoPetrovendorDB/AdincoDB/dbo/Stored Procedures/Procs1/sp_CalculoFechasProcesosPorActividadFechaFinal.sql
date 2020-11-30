-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20191112
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_CalculoFechasProcesosPorActividadFechaFinal]-- 3,10061,'20190801',12484,11156--  3,10061,'20190728',12484,11156
    @idContrato         INT,
    @idUsuario          INT,
    @FechaInicial       DATE,
    @idProceso          INT,
	@IdActividad		INT
AS
    BEGIN
        SET NOCOUNT ON;
        IF OBJECT_ID('tempdb.dbo.#Actividades', 'U') IS NOT NULL
            DROP TABLE #Actividades;
        IF OBJECT_ID('tempdb.dbo.#DiasHabiles', 'U') IS NOT NULL
            DROP TABLE #DiasHabiles;
        IF OBJECT_ID('tempdb.dbo.#SucesorAntecesor', 'U') IS NOT NULL
            DROP TABLE #SucesorAntecesor;
        IF OBJECT_ID('tempdb.dbo.#EN_ProcesosActividades', 'U') IS NOT NULL
            DROP TABLE #EN_ProcesosActividades;

        CREATE TABLE #Actividades
            (
                IdProceso              INT,
                DescripcionProceso     VARCHAR(500),
                IdContrato             INT,
                Orden                  INT,
                IdActividad            INT,
                NombreActividad        VARCHAR(500),
                Dias                   INT,
                DiasNaturales          BIT,
                FechaInicial           DATE,
                FechaLimite            DATE,
                IdActividadPredecesora INT,
                IdActividadSucesora    INT
            );
        CREATE TABLE #DiasHabiles
            (
                Id      INT IDENTITY(1, 1),
                IdFecha DATE
            );
        CREATE TABLE #SucesorAntecesor
            (
                IdActividad    INT,
                OrdenSucesor   INT,
                OrdenAntecesor INT
            );
        CREATE TABLE #EN_ProcesosActividades
            (
                IdProceso   INT,
                idActividad INT,
                IdContrato  INT,
                Orden       INT     IDENTITY(0, 1),
                CreadoPor   INT,
                CreadoEl    DATETIME,
                Activo      BIT
            );
        DECLARE
            @ordenActividad  INT,
            @FechaInicialSig DATE,
            @NvaFechaIni     DATE,
            @NvaFechaFin     DATE,
            @IsSerie         BIT,
			@BitDiasNaturales BIT = 0,
			@OrdenMax INT,
			@Regulador int;

--IF @idProceso = 13869
--	SELECT @FechaInicial = '20201012'

        SELECT  @ordenActividad = Orden,
				@Regulador=ISNULL(A.IdRegulador,0)
        FROM
            EN_ProcesosActividades	PA
		JOIN
			EN_Actividades	A
			ON PA.idActividad	=	A.IdActividad
			AND	PA.idActividad = @idActividad
        WHERE
            PA.idActividad = @idActividad
            AND PA.IdProceso = @idProceso
			AND PA.Activo = 1;
			
        INSERT INTO #EN_ProcesosActividades
            (
                IdProceso,
                idActividad,
                IdContrato,
                CreadoPor,
                CreadoEl,
                Activo
            )
                    SELECT
                        IdProceso,
                        idActividad,
                        IdContrato,
                        CreadoPor,
                        CreadoEl,
                        Activo --,Orden
                    FROM
                        EN_ProcesosActividades
                    WHERE
                        IdProceso	=	@idProceso
                        AND Orden	<=	@ordenActividad
                        AND Orden IS NOT NULL
						AND Orden	>= 0
						AND Activo = 1
                    ORDER BY
                        Orden asc;
        -- Select * from #EN_ProcesosActividades

	Select @OrdenMax=Max(orden) from 	#EN_ProcesosActividades

        SELECT
            @IsSerie = ISNULL(IsSerie, 1)
     FROM
            dbo.EN_Procesos
        WHERE
            IdProceso = @idProceso; -- si esta null lo tomamos como lineal

      INSERT INTO #DiasHabiles
            (
                IdFecha
            )
                    SELECT
                        A.IdFecha
                   FROM 
						dbo.AP_Calendario A
					LEFT JOIN 
						AP_CalendarioExcepciones CE 
						ON A.IdFecha=CE.IdFecha 
						AND CE.Activo=1 
						AND CE.IdRegulador = @Regulador
				WHERE
					A.IdFecha <= @FechaInicial
					AND	DATEADD(YEAR, -5, @FechaInicial
					) <=	A.IdFecha
					AND FinDeSemana	=	0
					AND DiaLaborable = 1
					AND CE.IdFecha IS NULL
				ORDER BY
					A.IdFecha DESC;

        -- DECLARE @FechaInicial DATE='20190906', @idContrato INT=3, @IdProceso INT=12092;
IF(@IsSerie=0)
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
	--PA.IdContrato,
	@idContrato,
	PA.Orden,
	A.IdActividad,
	A.NombreActividad,
	A.Dias,
	A.DiasNaturales,
	CASE 
		WHEN PA.Orden <= @OrdenMax AND A.DiasNaturales = 1
	   THEN DATEADD(DAY, -A.Dias,@FechaInicial)
		WHEN PA.Orden <= @OrdenMax AND A.DiasNaturales = 0 AND FI.DiaLaborable = 1
			THEN DH.IdFecha
		WHEN PA.Orden <= @OrdenMax AND A.DiasNaturales = 0 AND FI.DiaLaborable = 0
		THEN DH.IdFecha
	END,
	CASE WHEN PA.Orden <= @OrdenMax AND A.DiasNaturales = 1
		THEN  @FechaInicial
		WHEN PA.Orden <= @OrdenMax AND A.DiasNaturales = 0 AND FI.DiaLaborable = 1
		THEN @FechaInicial
		WHEN PA.Orden <= @OrdenMax AND A.DiasNaturales = 0 AND FI.DiaLaborable = 0
		THEN MAX(C2.IdFecha)
	END AS FechaLimite
	--Select *
FROM
	EN_Procesos	P
JOIN
	#EN_ProcesosActividades	PA
	ON	P.IdProceso	=	PA.IdProceso
JOIN
	EN_Actividades	A
	ON	PA.IdActividad	=	A.IdActividad
JOIN
	dbo.AP_Calendario	FI
	ON	@FechaInicial	=	FI.IdFecha
JOIN
	#DiasHabiles	DH
	ON	@FechaInicial	>=	DH.IdFecha
	AND	A.Dias = DH.Id 
JOIN
	dbo.AP_Calendario	C2
	ON	@FechaInicial	>=	C2.IdFecha
	AND	C2.IdFecha	>	DATEADD(YEAR, -5, @FechaInicial)
	AND C2.FinDeSemana	=	0
	AND C2.DiaLaborable = 1
WHERE
	P.IdProceso	=@IdProceso
	AND
	PA.Activo	=	1
	AND
    A.Activo	=	1
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
IF(@IsSerie=1)
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
	--PA.IdContrato,
	@idContrato,
	PA.Orden,
	A.IdActividad,
	A.NombreActividad,
	A.Dias,
	A.DiasNaturales,
	CASE WHEN PA.Orden = @OrdenMax 
	AND A.DiasNaturales = 1 AND A.Dias <> 1
		THEN DATEADD(DAY, -A.Dias,@FechaInicial
		 )
		WHEN PA.Orden = @OrdenMax
		 AND A.DiasNaturales = 1 AND A.Dias = 1
		THEN   @FechaInicial
		WHEN PA.Orden =@OrdenMax
		 AND A.DiasNaturales = 0 AND FI.DiaLaborable = 1
			THEN DH.IdFecha
		WHEN PA.Orden =@OrdenMax
		 AND A.DiasNaturales = 0 AND FI.DiaLaborable = 0
		THEN DH.IdFecha
	END,
	CASE WHEN PA.Orden =@OrdenMax
	 AND A.DiasNaturales = 1
		THEN  @FechaInicial
		WHEN PA.Orden =@OrdenMax
		 AND A.DiasNaturales = 0 AND FI.DiaLaborable = 1
		THEN @FechaInicial
		WHEN PA.Orden =@OrdenMax
		 AND A.DiasNaturales = 0 AND FI.DiaLaborable = 0
		THEN MAX(C2.IdFecha)
	END AS FechaLimite
	--Select *
FROM
	EN_Procesos	P
JOIN
	#EN_ProcesosActividades	PA
	ON	P.IdProceso	=	PA.IdProceso
JOIN
	EN_Actividades	A
	ON	PA.IdActividad	=	A.IdActividad
JOIN
	dbo.AP_Calendario	FI
	ON	@FechaInicial	
	=	FI.IdFecha
JOIN
	#DiasHabiles	DH
	ON	@FechaInicial
		>=	DH.IdFecha
	AND	A.Dias = DH.Id 
JOIN
	dbo.AP_Calendario	C2
	ON	@FechaInicial	
	>=	C2.IdFecha
	AND	C2.IdFecha	>	DATEADD(YEAR, -5, 
	@FechaInicial
	)
	AND C2.FinDeSemana	=	0
	AND C2.DiaLaborable = 1
WHERE
	P.IdProceso	=@IdProceso
	AND
	PA.Activo	=	1
	AND
    A.Activo	=	1
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

        --Select * from #Actividades
        --Select * from #SucesorAntecesor

        INSERT INTO #SucesorAntecesor
            (
                IdActividad,
                OrdenSucesor,
                OrdenAntecesor
            )
                    SELECT
                            A.IdActividad,
                            MAX(A2.Orden),
                            MIN(A3.Orden)
                    FROM
                            #Actividades A
                        LEFT JOIN
                            #Actividades A2
                                ON A.Orden > A2.Orden
                        LEFT JOIN
                            #Actividades A3
                                ON A.Orden < A3.Orden
                    GROUP BY
                            A.IdActividad;

        UPDATE
                A
        SET
                A.IdActividadSucesora = S.IdActividad,
                A.IdActividadPredecesora = ANT.IdActividad
        FROM
                #Actividades      A
            JOIN
                #SucesorAntecesor SA
                    ON A.IdActividad = SA.IdActividad
            LEFT JOIN
                #Actividades      S
                    ON SA.OrdenSucesor = S.Orden
            LEFT JOIN
                #Actividades      ANT
                    ON SA.OrdenAntecesor = ANT.Orden;

        --Select * from #Actividades
        --    DECLARE @FechaInicial DATE='20190820', @FechaInicialSig DATE, @IdActividad INT, @NvaFechaIni DATE, @NvaFechaFin DATE, @IsSerie BIT=1,@BitDiasNaturales bit;

WHILE (SELECT COUNT(1) FROM #Actividades WHERE FechaLimite IS NULL ) > 0
BEGIN
--DECLARE @FechaInicialSig	DATE,@IdActividad	INT,	@NvaFechaIni	DATE,@NvaFechaFin	DATE;
	SELECT TOP 1
       @FechaInicialSig = CASE @IsSerie
                              WHEN 1 THEN
                                  CASE
                                      WHEN Orden > 0 THEN
                                          DATEADD(DAY, -1, FechaInicial)--DATEADD(DAY, -5, FechaInicial)
                                      ELSE
                                          FechaInicial
                                  END
                              ELSE
                                  @FechaInicial
                          END, ----************************Cambio
       @IdActividad = IdActividadSucesora
FROM #Actividades
WHERE FechaLimite IS NOT NULL
ORDER BY Orden ASC

SELECT @BitDiasNaturales = DiasNaturales
FROM dbo.EN_Actividades A
WHERE IdActividad = @IdActividad
	
SELECT @Regulador=ISNULL(A.IdRegulador,0)
 FROM 
	EN_ProcesosActividades PA
JOIN 
	EN_Actividades A
	ON PA.idActividad=A.IdActividad 
	AND PA.idActividad=@IdActividad
	AND  PA.IdProceso=@idProceso 
	AND PA.IdContrato=@IdContrato

TRUNCATE TABLE #DiasHabiles

IF @BitDiasNaturales = 0
BEGIN
	IF ISNULL(@Regulador,0) = 0
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
				AND	DATEADD(YEAR, -5, @FechaInicialSig) <=	A.IdFecha
				AND FinDeSemana	=	0
				AND DiaLaborable = 1
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
			LEFT JOIN 
							AP_CalendarioExcepciones CE 
							ON A.IdFecha=CE.IdFecha 
							AND CE.Activo=1 
							AND CE.IdRegulador = @Regulador
			WHERE
				A.IdFecha <= @FechaInicialSig
				AND	DATEADD(YEAR, -5, @FechaInicialSig) <=	A.IdFecha
				AND FinDeSemana	=	0
				AND DiaLaborable = 1
				AND CE.IdFecha IS NULL
			ORDER BY
				A.IdFecha DESC;
		END
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
		AND	DATEADD(YEAR, -5, @FechaInicialSig) <=	A.IdFecha
	ORDER BY
		A.IdFecha DESC;
END

SELECT
		--@NvaFechaIni	=
		@NvaFechaFin	=	CASE WHEN A.DiasNaturales = 1
								THEN @FechaInicialSig
								WHEN A.DiasNaturales = 0 AND FI.DiaLaborable = 1
								THEN @FechaInicialSig
								WHEN A.DiasNaturales = 0 AND FI.DiaLaborable = 0
								THEN MAX(C2.IdFecha)
						END,
		--@NvaFechaFin	=	
		@NvaFechaIni	=	CASE WHEN A.DiasNaturales = 1 AND A.Dias <> 1
								THEN DATEADD(DAY,-A.Dias, @FechaInicialSig)
								WHEN A.DiasNaturales = 1 AND A.Dias = 1
								THEN @FechaInicialSig
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
		ON	@FechaInicialSig >=	DH.IdFecha
		AND	A.Dias= DH.Id
	JOIN
		dbo.AP_Calendario	C2
		ON	@FechaInicialSig	>=	C2.IdFecha
		AND	C2.IdFecha	>	DATEADD(YEAR, -5, @FechaInicialSig)
		AND C2.FinDeSemana	=	0
		AND C2.DiaLaborable = 1
	WHERE
		A.IdActividad = @IdActividad
	GROUP BY

		A.Dias,
		A.DiasNaturales,
		FI.DiaLaborable,
		DH.IdFecha,
		a.fechaInicial,a.FechaLimite,a.idactividadPredecesora,a.idActividadSucesora
		--SELECT @NvaFechaFin;
		--SELECT @NvaFechaIni;

	UPDATE #Actividades	
		SET
			FechaInicial	=	@NvaFechaIni,
			FechaLimite		=	@NvaFechaFin
	WHERE
		IdActividad = @IdActividad

	--SELECT  @BitDiasNaturales = 1
END 

END

Select idProceso,DescripcionProceso,idContrato,orden,idActividad,NombreActividaD,dias,DiasNaturales,FechaInicial,FechaLimite,idActividadPredecesora,idActividadSucesora  
FROM #Actividades 
order by fechaInicial asc

    END;
