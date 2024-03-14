USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_EN_GeneraInstanciasFechasLimite'
)
    DROP PROCEDURE SP_EN_GeneraInstanciasFechasLimite;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20/04/2019
-- Description:	
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 18/11/2021
-- Description:	se agrega la programacion para entregables Trianuales y Mensuales cada septimo dia habil del mes
-- =============================================
-- Author:		Luis David
-- Create date: 23/11/2021
-- Description:	Se agrega la programación para entregables 
    --a más tardar el décimo quinto (15) Día Hábil del Periodo subsecuente.
    --Dentro de los 15 días hábiles posteriores al cumplimiento del mes a reportar.
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 10/08/2023
-- Description:	se agrega la validacion y generacion de fechas en caso de no ser dia abil se recorre hasta el proximo https://github.com/Adinco/adinco-entregables/issues/1136
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_GeneraInstanciasFechasLimite]
    @FechaLimiteFrecuencia DATE,
    @ContratoID INT,
    @Frecuencia INT,
    @IdContratoEntregable INT,
    @BitProgramaImplementa INT,
	@IsFechaRegulador BIT
AS
BEGIN
    DECLARE @CantidadIncrementFecha INT,
			@FinVigenciaContrato DATE,
			@FechaSIPAC int=0,
			@NombreDia varchar(50),
			@TEDecimoDiaHabil int=0,--Tiempo Entrega Decimo Dia habil
			@TEQuinceDiaHabil int = 0,
			@TESeptimoDiaHabil int=0,
			@BitRecorrerDiasAbiles bit;--Tiempo Entrega Decimo Dia habil

    IF OBJECT_ID('tempdb..#DiasFechasFinales', 'U') IS NOT NULL
        DROP TABLE #DiasFechasFinales;
    CREATE TABLE #DiasFechasFinales
    (
        Id INT IDENTITY(1, 1),
        IdFecha DATE
    );

	Select TOP 1
		@BitRecorrerDiasAbiles = E.BitRecorrerDiasAbiles
	FROM 
		EN_ContratoEntregable CE (NOLOCK)
	JOIN 
		EN_Entregable E (NOLOCK)
		ON CE.IdEntregable = E.IdEntregable
	WHERE 
		CE.IdContratoEntregable	=	@IdContratoEntregable;

	Select 
		@FechaSIPAC= COUNT(1)
	FROM 
		EN_ContratoEntregable CE (NOLOCK)
	JOIN 
		EN_Entregable E (NOLOCK)
		ON CE.IdEntregable = E.IdEntregable
	WHERE 
		CE.IdContratoEntregable	=	@IdContratoEntregable 
		AND E.DocumentoEntregable like '%SIPAC%' 
		AND IdFrecuenciaEntregable=10009--MENSUAL

	SELECT @TEDecimoDiaHabil=COUNT(1) 
	FROM 
		EN_ContratoEntregable CE (NOLOCK)
	JOIN 
		EN_Entregable E (NOLOCK)
		ON	CE.IdEntregable=E.IdEntregable
	WHERE 
		CE.IdContratoEntregable	=	@IdContratoEntregable
		AND replace(TIEMPOENTREGA,'á','a') LIKE 'dentro%10%habiles%'
		AND IdFrecuenciaEntregable	=	10013--TRIMESTRAL
	
	SELECT @TESeptimoDiaHabil= COUNT(1) 
	FROM 
		EN_ContratoEntregable CE (NOLOCK)
	JOIN 
		EN_Entregable E (NOLOCK)
		ON	CE.IdEntregable=E.IdEntregable
	WHERE 
		CE.IdContratoEntregable	=	@IdContratoEntregable AND 
		replace(TIEMPOENTREGA,'á','a') LIKE 'dentro%7%habiles%'
		AND IdFrecuenciaEntregable	=	10009--MENSUAL
						

	SELECT @TEQuinceDiaHabil= COUNT(1) 
	FROM 
		EN_ContratoEntregable CE (NOLOCK)
	JOIN 
		EN_Entregable E (NOLOCK)
		ON	CE.IdEntregable=E.IdEntregable
	WHERE 
		CE.IdContratoEntregable	=	@IdContratoEntregable AND
		(replace(TIEMPOENTREGA,'á','a') LIKE 'dentro%15%habiles%'
		or replace(TIEMPOENTREGA,'á','a') LIKE '%décimo quinto%')
		AND IdFrecuenciaEntregable	IN (	10009, --MENSUAL
						10013 ) --TRIMESTRAL


    IF (@BitProgramaImplementa = 0)
			BEGIN
				SELECT @FinVigenciaContrato = --Select 
					FinVigencia
				FROM dbo.CO_Contrato (NOLOCK)
				WHERE IdContrato = @ContratoID;
			END;
			ELSE
			BEGIN
				SELECT --PI.FechaInicio,
					@FinVigenciaContrato = PI.FechaFin
				FROM dbo.EN_ContratoEntregableProgramaImplementaAcciones CEPI (NOLOCK)
				JOIN dbo.CO_ProgramaImplementaAcciones PIA (NOLOCK) 
					ON CEPI.IdContratoEntregable = @IdContratoEntregable
						AND CEPI.IdProgramaImplementaAccion = PIA.IdProgramaImplementaAccion
				JOIN dbo.CO_ProgramaImplementaElemento PIE (NOLOCK) 
					ON PIA.IdProgramaImplementaElemento = PIE.IdProgramaImplementaElemento
				JOIN dbo.CO_ProgramaImplementaPoliticas PIP (NOLOCK)
					ON PIE.IdProgramaImplementaPolitica = PIP.IdProgramaImplementaPolitica
				JOIN dbo.CO_ProgramaImplementa PI (NOLOCK)
					ON PIP.IdProgramaImplementa = PI.IdProgramaImplementa;
			END;


    IF @Frecuencia NOT IN ( 10000, 10003, 10003, 10004, 10005, 10008, 10010, 10011, 10014, 10016, 10018,10019 )  
	--SELECT * FROM EN_FrecuenciaEntregable WHERE IdFrecuenciaEntregable IN ( 10000, 10003, 10003, 10004, 10005, 10008, 10010, 10011, 10014, 10016, 10018, 10019 )
    BEGIN --Entregable Frecuencia
			---------------------------------------------------------------------------------
			IF (
					  @Frecuencia = 10001
				   OR @Frecuencia = 10009
				   OR @Frecuencia = 10006
				   OR @Frecuencia = 10007
			   )
			--Anual,Mensual,Durante el primer trimestre de cada año,Enero de cada año
			BEGIN
					SET @CantidadIncrementFecha = 1;
				END;
				IF (@Frecuencia = 10002 OR @Frecuencia = 10020) -- Bianual,Bimestral
				BEGIN
					SET @CantidadIncrementFecha = 2;
				END;
				IF (@Frecuencia = 10012) --Semestral 
				BEGIN
					SET @CantidadIncrementFecha = 6;
				END;
				IF (@Frecuencia = 10013 OR @Frecuencia = 10021) ----trimestral,trianual
				BEGIN
					SET @CantidadIncrementFecha = 3;
				END;
				IF (@Frecuencia = 10015) -- quincenal,
				BEGIN
					SET @CantidadIncrementFecha = 15;
				END;
				IF (@Frecuencia = 10017) ----Quinquenal(Cada 5 años)
				BEGIN
					SET @CantidadIncrementFecha = 5;
				END;
			---------------------------Generación de instancias-----------------------
				IF(@FechaSIPAC=0)
				BEGIN

					WHILE (@FechaLimiteFrecuencia <= @FinVigenciaContrato)
					BEGIN
						IF (@TEDecimoDiaHabil	=	0)	--NO CONTIENE TIEMPO DE ENTREGA DEL DECIMO DÍA
						BEGIN

							IF @TESeptimoDiaHabil = 0 --NO CONTIENE TIEMPO DE ENTREGA DEL SEPTIMO DÍA
							BEGIN

								IF @TEQuinceDiaHabil = 0
								BEGIN
									--VALIDACION PARA VERIFICAR QUE LOS DIAS 
									--DE ENTREGA REGULADOR SERAN DESPUES
									--SI ESTE CAE EN FIN DE SEMANA
									IF ISNULL(@BitRecorrerDiasAbiles,0) = 1
									BEGIN

										INSERT INTO #DiasFechasFinales (IdFecha)
										SELECT TOP 1
											   IdFecha
										FROM dbo.AP_Calendario (NOLOCK)
										WHERE IdFecha >= @FechaLimiteFrecuencia
											  AND DATEADD(DAY, 5, @FechaLimiteFrecuencia) >= IdFecha
											  AND FinDeSemana = 0
											  AND DiaLaborable = 1
										ORDER BY IdFecha ASC;

									END
									ELSE
									BEGIN

										INSERT INTO #DiasFechasFinales (IdFecha)
										SELECT TOP 1
											   IdFecha
										FROM dbo.AP_Calendario (NOLOCK)
										WHERE IdFecha <= @FechaLimiteFrecuencia
											  AND DATEADD(DAY, -5, @FechaLimiteFrecuencia) <= IdFecha
											  AND FinDeSemana = 0
											  AND DiaLaborable = 1
										ORDER BY IdFecha DESC;

									END
									

								END
								ELSE
								BEGIN

									IF(@IsFechaRegulador=1)
									BEGIN
										INSERT INTO #DiasFechasFinales (IdFecha)
										SELECT 
											IdFecha
											FROM 
												AP_Calendario (NOLOCK)
											WHERE 
												Mes	=	MONTH(@FechaLimiteFrecuencia)
												AND	Anio	=	YEAR(@FechaLimiteFrecuencia)
											AND Descripcion LIKE '%Dia 15 habil%';

									END
									ELSE
									BEGIN
										INSERT INTO #DiasFechasFinales (IdFecha)
										Select Adinco.dbo.FN_EN_RestaDiasHabiles(
													IdFecha,
													2
												)
											from AP_Calendario (NOLOCK)
											WHERE 
												Mes	=	MONTH(@FechaLimiteFrecuencia)
												AND	Anio	=	YEAR(@FechaLimiteFrecuencia)
											AND Descripcion LIKE '%Dia 15 habil%';
									END

								END

								

							END
							ELSE
							BEGIN
								
								IF(@IsFechaRegulador=1)
									BEGIN
										INSERT INTO #DiasFechasFinales (IdFecha)
										SELECT 
											IdFecha
											FROM 
												AP_Calendario (NOLOCK)
											WHERE 
												Mes	=	MONTH(@FechaLimiteFrecuencia)
												AND	Anio	=	YEAR(@FechaLimiteFrecuencia)
											AND Descripcion LIKE '%Dia 7 hábil%';

									END
									ELSE
									BEGIN
										INSERT INTO #DiasFechasFinales (IdFecha)
										Select Adinco.dbo.FN_EN_RestaDiasHabiles(
													IdFecha,
													2
												)
											from AP_Calendario (NOLOCK)
											WHERE 
												Mes	=	MONTH(@FechaLimiteFrecuencia)
												AND	Anio	=	YEAR(@FechaLimiteFrecuencia)
											AND Descripcion LIKE '%Dia 7 hábil%';
									END

							END

							
						END
						ELSE
						BEGIN	-- TIEMPO DE ENTREGA DECIMO DÍA AHORITA SOLO PARA 10013--TRIMESTRAL
								IF(@IsFechaRegulador=1)
									BEGIN
										INSERT INTO #DiasFechasFinales (IdFecha)
										SELECT 
											IdFecha
											FROM 
												AP_Calendario (NOLOCK)
											WHERE 
												Mes	=	MONTH(@FechaLimiteFrecuencia)
												AND	Anio	=	YEAR(@FechaLimiteFrecuencia)
											AND Descripcion LIKE '%Recepción de Información para el cálculo de contraprestaciones%';

									END
									ELSE
									BEGIN
										INSERT INTO #DiasFechasFinales (IdFecha)
										Select Adinco.dbo.FN_EN_RestaDiasHabiles(
													IdFecha,
													2
												)
											from AP_Calendario (NOLOCK)
											WHERE 
												Mes	=	MONTH(@FechaLimiteFrecuencia)
												AND	Anio	=	YEAR(@FechaLimiteFrecuencia)
											AND Descripcion LIKE '%Recepción de Información para el cálculo de contraprestaciones%';
									END
						END


						IF (
								  @Frecuencia = 10001
							   OR @Frecuencia = 10002
							   OR @Frecuencia = 10006
							   OR @Frecuencia = 10007
							   OR @Frecuencia = 10017
							   OR @Frecuencia = 10021
						   ) --Anual,Bianual,Durante el primer trimestre de cada año,Enero de cada año,Quinquenal(Cada 5 años)
						BEGIN
							SELECT @FechaLimiteFrecuencia = DATEADD(YEAR, @CantidadIncrementFecha, @FechaLimiteFrecuencia);
						END;
						IF (@Frecuencia = 10009 OR @Frecuencia = 10012 OR @Frecuencia = 10013	OR  @Frecuencia = 10020) --Mensual,Semestral,trimestral, Bimestral
						BEGIN
							SELECT @FechaLimiteFrecuencia = DATEADD(MONTH, @CantidadIncrementFecha, @FechaLimiteFrecuencia);
						END;
						IF (@Frecuencia = 10015) -- quincenal
						BEGIN
							SELECT @FechaLimiteFrecuencia = DATEADD(DAY, @CantidadIncrementFecha, @FechaLimiteFrecuencia);
						END;
				END;
				END
				ELSE
				IF(@FechaSIPAC=1)
				BEGIN
					IF(@IsFechaRegulador=1)
					BEGIN


							INSERT INTO #DiasFechasFinales (IdFecha)
							Select 
							IdFecha 
							from AP_Calendario (NOLOCK)
							WHERE IdFecha BETWEEN Ltrim (Year(@FechaLimiteFrecuencia))+'-'+Ltrim (Month(@FechaLimiteFrecuencia))+'-'+'01' AND  Ltrim (Year(@FinVigenciaContrato))+'-'+Ltrim (Month(@FinVigenciaContrato))+'-'+'01' 
							AND Descripcion LIKE '%Recepción de Información para el cálculo de contraprestaciones%';


					END
					ELSE 
					BEGIN 

							--SI ES FECHA DE LIMITE INTERNA, SE LE RESTAN DOS DÍAS AL DE LA ENTREGA A REGULADOR
							INSERT INTO #DiasFechasFinales (IdFecha)
							Select Adinco.dbo.FN_EN_RestaDiasHabiles(
									IdFecha,
									2
								)
							from AP_Calendario (NOLOCK)
							WHERE IdFecha BETWEEN Ltrim (Year(@FechaLimiteFrecuencia))+'-'+Ltrim (Month(@FechaLimiteFrecuencia))+'-'+'01' AND  Ltrim (Year(@FinVigenciaContrato))+'-'+Ltrim (Month(@FinVigenciaContrato))+'-'+'01' 
							AND Descripcion LIKE '%Recepción de Información para el cálculo de contraprestaciones%';

						

					END
				END

			END
    ELSE

	IF(@Frecuencia=10019) --ENTREGABLE SEMANAL
	BEGIN
			SELECT @NombreDia = NombreDia FROM AP_Calendario (NOLOCK) WHERE IdFecha = @FechaLimiteFrecuencia;

			INSERT INTO #DiasFechasFinales (IdFecha)
			SELECT IdFecha
				FROM AP_Calendario (NOLOCK)
				WHERE NombreDia = @NombreDia
					AND IdFecha >= @FechaLimiteFrecuencia
					AND IdFecha <= @FinVigenciaContrato

	END
	ELSE
    BEGIN 
	---Entregable por EVENTO

			--VALIDACION PARA VERIFICAR QUE LOS DIAS 
			--DE ENTREGA REGULADOR SERAN DESPUES
			--SI ESTE CAE EN FIN DE SEMANA
			IF ISNULL(@BitRecorrerDiasAbiles,0) = 1
			BEGIN
				
				INSERT INTO #DiasFechasFinales (IdFecha)
				SELECT TOP 1
					   IdFecha
				FROM dbo.AP_Calendario (NOLOCK)
				WHERE IdFecha >= @FechaLimiteFrecuencia
					  AND DATEADD(DAY, 5, @FechaLimiteFrecuencia) >= IdFecha
					  AND FinDeSemana = 0
					  AND DiaLaborable = 1
				ORDER BY IdFecha ASC;

			END
			ELSE
			BEGIN

				INSERT INTO #DiasFechasFinales (IdFecha)
				SELECT TOP 1
					   IdFecha
				FROM dbo.AP_Calendario (NOLOCK)
				WHERE IdFecha <= @FechaLimiteFrecuencia
					  AND DATEADD(DAY, -5, @FechaLimiteFrecuencia) <= IdFecha
					  AND FinDeSemana = 0
					  AND DiaLaborable = 1
				ORDER BY IdFecha DESC;

			END
			
    END;


	SELECT IdFecha
	FROM #DiasFechasFinales;
END;
