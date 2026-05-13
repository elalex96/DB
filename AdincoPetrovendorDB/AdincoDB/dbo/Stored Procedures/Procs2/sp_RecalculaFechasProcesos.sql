USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_RecalculaFechasProcesos'
)
    DROP PROCEDURE sp_RecalculaFechasProcesos;
/****** Object:  StoredProcedure [dbo].[sp_EN_ExtraeDatosEntregableProceso]    Script Date: 06/11/2023 06:36:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  StoredProcedure [dbo].[sp_RecalculaFechasProcesos]    Script Date: 07/11/2023 02:25:12 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:  	Daniel AC
-- Create date: 07/11/2023
-- Se agrega CAMBIA condicion si es 0 se recalcule y si es 1 no haga nada
-- =============================================
CREATE PROCEDURE [dbo].[sp_RecalculaFechasProcesos]--  3,10061,'20200319',12784,12310,11443
    @idContrato         INT,
    @idUsuario          INT,
    @FechaInicial       DATE,
    @idProceso          INT,
	@idintanciaActividad INT,
    @idInstanciaProceso INT
AS
    BEGIN
        SET NOCOUNT ON;

	--VALIDACION DE RECALCULO 0 SI SE RECALCULA Y 1 NO SE RECALCULA
	DECLARE @NO_RECALCULO INT = (SELECT NoRecalculo 
								FROM EN_InstanciasProcesosFecha 
								WHERE IdInstanciasProcesos = @idInstanciaProceso);
	
	IF ISNULL(@NO_RECALCULO,0) = 0
	BEGIN
		
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
            @IdActividad     INT,
            @NvaFechaIni     DATE,
            @NvaFechaFin     DATE,
            @IsSerie         BIT,
			@Regulador INT = 0,
			@BitDiasNaturales BIT = 0;


		SELECT	
			@IdActividad	=	IdActividad
		FROM	
			dbo.EN_InstanciasActividades	
		WHERE 
			idInstanciaActividad	=	@idintanciaActividad

		SELECT
			@IdContrato	=	IdContrato
		FROM
			EN_ProcesosActividades
		WHERE
			IdProceso	=	@idProceso
			AND
			idActividad	=	@IdActividad
		GROUP BY
			IdContrato

        SELECT
            @ordenActividad = PA.Orden,
			@Regulador = ISNULL(A.IdRegulador,0)
        FROM
            EN_ProcesosActividades PA
		JOIN 
			EN_Actividades	A 
				ON	PA.idActividad	=	A.IdActividad 
				AND	PA.idActividad = @idActividad
				AND PA.IdProceso	=	@idProceso 
				AND PA.IdContrato	=	@IdContrato
        WHERE
            PA.idActividad = @idActividad
            AND PA.IdProceso = @idProceso
			AND PA.Activo = 1
			AND PA.Orden	>= 0;



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
                    IdProceso = @idProceso
                    AND Orden > @ordenActividad
                    AND Orden IS NOT NULL
					AND Activo = 1
                ORDER BY
                    Orden ASC;


	SELECT
		@IsSerie = ISNULL(IsSerie, 1)
	FROM
		dbo.EN_Procesos
	WHERE
		IdProceso = @idProceso; -- si esta null lo tomamos como lineal

-- SI EL PROCESO EL PARALELO, EL RECALCULO SE DEBE REALIZAR SOBRE LA FECHA ORIGINAL DEL PROCESO
IF @IsSerie = 0
BEGIN
	SELECT @FechaInicial	=	FechaInicioProceso
	FROM EN_InstanciasProcesosFecha
	WHERE	IdInstanciasProcesos = @idInstanciaProceso
END

-- CAMBIO PARA SHELL PARA SIEMPRE AGREGAR UN DIA A LA ACTIVIDAD
	IF 10055 = (SELECT IDCONTRATISTA FROM CO_CONTRATO WHERE IDCONTRATO = @idContrato)
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
					ON	A.IdFecha	=	CE.IdFecha 
					AND	CE.Activo	=	1 
					AND	CE.IdRegulador	=	@Regulador
                WHERE
                    A.IdFecha > @FechaInicial
                    AND DATEADD(YEAR, 5, @FechaInicial) >= A.IdFecha
                    AND FinDeSemana = 0
                    AND DiaLaborable = 1
					AND	CE.IdFecha	IS	NULL
                ORDER BY
                    A.IdFecha;
	END
	ELSE
	BEGIN
        -- DECLARE @FechaInicial DATE='20190906', @idContrato INT=3, @IdProceso INT=12092;
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
					ON	A.IdFecha	=	CE.IdFecha 
					AND	CE.Activo	=	1 
					AND	CE.IdRegulador	=	@Regulador
                WHERE
                    A.IdFecha >= @FechaInicial
                    AND DATEADD(YEAR, 5, @FechaInicial) >= A.IdFecha
                    AND FinDeSemana = 0
                    AND DiaLaborable = 1
					AND	CE.IdFecha	IS	NULL
                ORDER BY
                    A.IdFecha;
	END
        -- DECLARE @FechaInicial DATE='20190906', @idContrato INT=3, @IdProceso INT=12092;

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
			CASE
				WHEN PA.Orden = 0
						AND A.DiasNaturales = 1
					THEN
					@FechaInicial
				WHEN PA.Orden = 0
						AND A.DiasNaturales = 0
						AND FI.DiaLaborable = 1
					THEN
					@FechaInicial
				WHEN PA.Orden = 0
						AND A.DiasNaturales = 0
						AND FI.DiaLaborable = 0
					THEN
					MIN(C2.IdFecha)
			END        AS FechaInicial,
			CASE
				WHEN PA.Orden = 0
						AND A.DiasNaturales = 1
					THEN
					DATEADD(DAY, A.Dias, @FechaInicial)
				WHEN PA.Orden = 0
						AND A.DiasNaturales = 0
						AND FI.DiaLaborable = 1
					THEN
					DH.IdFecha
				WHEN PA.Orden = 0
						AND A.DiasNaturales = 0
						AND FI.DiaLaborable = 0
					THEN
					DH.IdFecha
			END
		FROM
			EN_Procesos             P
		JOIN
			#EN_ProcesosActividades PA
				ON P.IdProceso = PA.IdProceso
		JOIN
			EN_Actividades          A
				ON PA.idActividad = A.IdActividad
		JOIN
			dbo.AP_Calendario       FI
				ON @FechaInicial = FI.IdFecha
		JOIN
			#DiasHabiles            DH
				ON	@FechaInicial <= DH.IdFecha
				AND	A.Dias = DH.Id
		JOIN
			dbo.AP_Calendario       C2
				ON @FechaInicial <= C2.IdFecha
				AND C2.IdFecha < DATEADD(YEAR, 5, @FechaInicial)
				AND C2.FinDeSemana = 0
				AND C2.DiaLaborable = 1
		WHERE
			P.IdProceso = @idProceso
			AND PA.Activo = 1
			AND A.Activo = 1
		GROUP BY
			P.IdProceso,
			P.Descripcion,
			PA.Orden,
			A.IdActividad,
			A.NombreActividad,
			A.Dias,
			A.DiasNaturales,
			FI.DiaLaborable,
			DH.IdFecha
		ORDER BY
			PA.Orden;

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
			MIN(A2.Orden),
			MAX(A3.Orden)
		FROM
			#Actividades A
		LEFT JOIN
			#Actividades A2
				ON A.Orden < A2.Orden
		LEFT JOIN
			#Actividades A3
				ON A.Orden > A3.Orden
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
        --    DECLARE @FechaInicial DATE='20190906', @FechaInicialSig DATE, @IdActividad INT, @NvaFechaIni DATE, @NvaFechaFin DATE, @IsSerie BIT=1;

		WHILE(SELECT	COUNT(1)	FROM	#Actividades	WHERE	FechaLimite IS NULL	) > 0
            BEGIN
                SELECT TOP 1
                       @FechaInicialSig = CASE @IsSerie
												WHEN 1
                                                  THEN
                                                  CASE
                                                      WHEN Orden > 0
                                                          THEN
                                                          DATEADD(DAY, 1, FechaLimite)
                                                      ELSE
                                                          FechaLimite
                                                  END
                                              ELSE
                                                  @FechaInicial
                                          END,
                       --**************************Cambio se suma uno
                       @idActividad     = IdActividadSucesora
                FROM
                       #Actividades
                WHERE
                       FechaLimite IS NOT NULL
                ORDER BY
						Orden DESC;

				SELECT 
					@BitDiasNaturales = DiasNaturales
				FROM 
					dbo.EN_Actividades A
				WHERE 
					IdActividad = @IdActividad
    
    
				SELECT 
					@Regulador = ISNULL(A.IdRegulador,0)
				FROM 
					EN_ProcesosActividades	PA
				JOIN 
					EN_Actividades	A 
					ON	PA.idActividad	=	A.IdActividad 
					AND	PA.idActividad	=	@IdActividad
					AND	PA.IdProceso	=	@idProceso 
					AND	PA.IdContrato	=	@IdContrato 

                TRUNCATE TABLE #DiasHabiles;

				IF @BitDiasNaturales = 0
				BEGIN
					IF 10055 = (SELECT IDCONTRATISTA FROM CO_CONTRATO WHERE IDCONTRATO = @idContrato)
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
							A.IdFecha > @FechaInicialSig
							AND DATEADD(YEAR, 5, @FechaInicialSig) >= A.IdFecha
							AND FinDeSemana	=	0
							AND DiaLaborable	=	1
							AND CE.IdFecha IS NULL
						ORDER BY
							A.IdFecha ;
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
							AP_CalendarioExcepciones	CE 
							ON A.IdFecha	=	CE.IdFecha 
							AND	CE.Activo	=	1 
							AND	CE.IdRegulador	=	@Regulador
						WHERE
							A.IdFecha >= @FechaInicialSig
							AND DATEADD(YEAR, 5, @FechaInicialSig) >= A.IdFecha
							AND FinDeSemana	=	0
							AND DiaLaborable	=	1
							AND CE.IdFecha IS NULL
						ORDER BY
							A.IdFecha ;
					END
				END
					ELSE
					BEGIN
						IF 10055 = (SELECT IDCONTRATISTA FROM CO_CONTRATO WHERE IDCONTRATO = @idContrato)
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
								A.IdFecha > @FechaInicialSig
								AND DATEADD(YEAR, 5, @FechaInicialSig) >= IdFecha
							ORDER BY
								A.IdFecha ;
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
							A.IdFecha >= @FechaInicialSig
							AND DATEADD(YEAR, 5, @FechaInicialSig) >= IdFecha
						ORDER BY
							A.IdFecha ;
						END
					END

                SELECT
                        @NvaFechaIni = CASE
                                           WHEN A.DiasNaturales = 1
										   THEN	@FechaInicialSig
                                           WHEN A.DiasNaturales = 0	AND FI.DiaLaborable = 1
                                           THEN	@FechaInicialSig
                                           WHEN A.DiasNaturales = 0	AND FI.DiaLaborable = 0
                                           THEN	MIN(C2.IdFecha)
                                       END,
                        @NvaFechaFin = CASE
                                           WHEN A.DiasNaturales = 1
                                           THEN	DATEADD(DAY, A.Dias, @FechaInicialSig)
                                           WHEN A.DiasNaturales = 0	AND FI.DiaLaborable = 1
                                           THEN	DH.IdFecha --DATEADD(DAY, A.Dias, @FechaInicialSig)
                                           WHEN A.DiasNaturales = 0	AND FI.DiaLaborable = 0
                                           THEN	DH.IdFecha
                                       END
                FROM
                        #Actividades      A
                    JOIN
                        dbo.AP_Calendario FI
                            ON @FechaInicialSig = FI.IdFecha
                    JOIN
					      #DiasHabiles      DH
                            ON @FechaInicialSig <= DH.IdFecha
                               AND A.Dias = DH.Id
                    JOIN
                        dbo.AP_Calendario C2
                            ON @FechaInicialSig <= C2.IdFecha
                               AND C2.IdFecha < DATEADD(YEAR, 5, @FechaInicialSig)
                               AND C2.FinDeSemana = 0
                               AND C2.DiaLaborable = 1
                WHERE
                        A.IdActividad = @idActividad
                GROUP BY
                        A.Dias,
                        A.DiasNaturales,
                        FI.DiaLaborable,
                        DH.IdFecha;

                UPDATE
                    #Actividades
                SET
                    FechaInicial = @NvaFechaIni,
                    FechaLimite = @NvaFechaFin
                WHERE
                    IdActividad = @idActividad;
					
				SELECT  @BitDiasNaturales = 1
            END;

      
        UPDATE  IA
        SET
                IA.FechaActividad = A.FechaLimite,
                IA.FechaInicioActividad = A.FechaInicial
        FROM
                #Actividades                 A
        JOIN
                dbo.EN_InstanciasActividades IA
                ON A.IdActividad = IA.IdActividad
                    AND IdInstanciasProcesos = @idInstanciaProceso;


        UPDATE   IE
        SET
                IE.FechasLimiteAprobacion = A.FechaLimite,
                IE.FechaCalculadaEntregaReg = A.FechaLimite,
                ContieneAjusteFechas = 1
        --SELECT * 
        FROM
                dbo.EN_InstanciasEntregable                     IE
            JOIN
                dbo.EN_InstanciasEntregables_InstanciaActividad IEIA
				ON IE.idInstanciaEntregable = IEIA.idInstanciaEntregable
            JOIN
                EN_InstanciasActividades                        IA
                    ON IEIA.idInstanciaActividad = IA.idInstanciaActividad
            JOIN
                #Actividades                                    A
                    ON IA.IdActividad = A.IdActividad
                       AND IA.IdInstanciasProcesos = @idInstanciaProceso;


        UPDATE  IE
        SET
                FechasLimiteRevision = Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechasLimiteAprobacion, CE.DiasAprobacion)
        --SELECT *
        FROM
                dbo.EN_InstanciasEntregable                     IE
            JOIN
                dbo.EN_InstanciasEntregables_InstanciaActividad IEIA
                    ON IE.idInstanciaEntregable = IEIA.idInstanciaEntregable
            JOIN
                EN_InstanciasActividades                        IA
                    ON IEIA.idInstanciaActividad = IA.idInstanciaActividad
            JOIN
                #Actividades                                    A
                    ON IA.IdActividad = A.IdActividad
                       AND IA.IdInstanciasProcesos = @idInstanciaProceso
            JOIN
                dbo.EN_ContratoEntregable                       CE
                    ON IE.IdContratoEntregable = CE.IdContratoEntregable;

        UPDATE  IE
        SET
                FechasLimiteElaboracion = Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechasLimiteRevision, CE.DiasRevision)
        --SELECT * 
        FROM
                dbo.EN_InstanciasEntregable                     IE
            JOIN
                dbo.EN_InstanciasEntregables_InstanciaActividad IEIA
                    ON IE.idInstanciaEntregable = IEIA.idInstanciaEntregable
            JOIN
                EN_InstanciasActividades                        IA
                    ON IEIA.idInstanciaActividad = IA.idInstanciaActividad
            JOIN
                #Actividades                                    A
				ON IA.IdActividad = A.IdActividad
                       AND IA.IdInstanciasProcesos = @idInstanciaProceso
            JOIN
                dbo.EN_ContratoEntregable                       CE
                    ON IE.IdContratoEntregable = CE.IdContratoEntregable;


        UPDATE
                IE
        SET
                FechaInicioElaboracion = Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechasLimiteElaboracion, CE.DiasElaboracion),
                FechaEnvioMensajeAtrasoRevision = Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechasLimiteElaboracion,CE.DiasAlerta)
        --SELECT *
        FROM
                dbo.EN_InstanciasEntregable                     IE
            JOIN
                dbo.EN_InstanciasEntregables_InstanciaActividad IEIA
                    ON IE.idInstanciaEntregable = IEIA.idInstanciaEntregable
            JOIN
                EN_InstanciasActividades                        IA
                    ON IEIA.idInstanciaActividad = IA.idInstanciaActividad
            JOIN
                #Actividades                                    A
                    ON IA.IdActividad = A.IdActividad
                       AND IA.IdInstanciasProcesos = @idInstanciaProceso
            JOIN
                dbo.EN_ContratoEntregable                       CE
                    ON IE.IdContratoEntregable = CE.IdContratoEntregable;

	END

END;