USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'spGetDataPenalizacionesChartInfo'
)
    DROP PROCEDURE spGetDataPenalizacionesChartInfo;
GO 

/****** Object:  StoredProcedure [dbo].[spGetPeriodoExploracionChartInfo]    Script Date: 19/05/2021 01:13:04 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetDataPenalizacionesChartInfo]
	@pIdUsuario		int,
	@pIdContrato	int,
	@nombreGrafica nvarchar(max)
AS
BEGIN
SET NOCOUNT ON

    /*INFORMACIÓN PARA GRAFICAS DE PENALIZACIONES*/

	CREATE TABLE #tmp
	(
		Id			int,
		Titulo		varchar(50),
		Valor		decimal(4,2),
		Serie		int
	)

	if @nombreGrafica ='grafChartExploracion'
	begin

	insert into	#tmp
	SELECT
		1,
		'Porcentaje Pena Convencional',
		CASE WHEN @pIdContrato = 10049	THEN 77 -- AREA 10 CNH-R02-L01-A10.CS/2017
			 WHEN @pIdContrato = 10050	THEN 75 -- AREA	CNH-R03-L01-G-CS-01/2018
			 WHEN @pIdContrato = 10054	THEN 0	--AREA 1 CNH-R01-L02-A1/2015
			 WHEN @pIdContrato = 10055	THEN 77	--AREA 7 CNH-R02-L01-A7.CS/2017
			 WHEN @pIdContrato = 10056	THEN 75	--AREA 14 CNH-R02-L01-A14.CS/2017
			 WHEN @pIdContrato = 10057	THEN 87	--AREA	CNH-R02-L04-AP-CS-G05/2018
		END,
		1
UNION
	SELECT
		2,
		'Contenido Nacional',
		CASE WHEN @pIdContrato = 10049	THEN 23 -- AREA 10 CNH-R02-L01-A10.CS/2017
			 WHEN @pIdContrato = 10050	THEN 25 -- AREA	CNH-R03-L01-G-CS-01/2018
			 WHEN @pIdContrato = 10054	THEN 0	--AREA 1 CNH-R01-L02-A1/2015
			 WHEN @pIdContrato = 10055	THEN 23	--AREA 7 CNH-R02-L01-A7.CS/2017
			 WHEN @pIdContrato = 10056	THEN 25	--AREA 14 CNH-R02-L01-A14.CS/2017
			 WHEN @pIdContrato = 10057	THEN 13	--AREA	CNH-R02-L04-AP-CS-G05/2018
		END,
		1

	end

	if @nombreGrafica ='grafChartEvaluacion'
	begin 
		insert into	#tmp
		SELECT
		1,
		'Porcentaje Pena Convencional',
		CASE WHEN @pIdContrato = 10049	THEN 67 -- AREA 10 CNH-R02-L01-A10.CS/2017
			 WHEN @pIdContrato = 10050	THEN 65 -- AREA	CNH-R03-L01-G-CS-01/2018
			 WHEN @pIdContrato = 10054	THEN 0	--AREA 1 CNH-R01-L02-A1/2015
			 WHEN @pIdContrato = 10055	THEN 80	--AREA 7 CNH-R02-L01-A7.CS/2017
			 WHEN @pIdContrato = 10056	THEN 65	--AREA 14 CNH-R02-L01-A14.CS/2017
			 WHEN @pIdContrato = 10057	THEN 77	--AREA	CNH-R02-L04-AP-CS-G05/2018
		END,
		1
		UNION
		SELECT
			2,
			'Contenido Nacional',
			CASE WHEN @pIdContrato = 10049	THEN 33 -- AREA 10 CNH-R02-L01-A10.CS/2017
				 WHEN @pIdContrato = 10050	THEN 35 -- AREA	CNH-R03-L01-G-CS-01/2018
				 WHEN @pIdContrato = 10054	THEN 0	--AREA 1 CNH-R01-L02-A1/2015
				 WHEN @pIdContrato = 10055	THEN 20	--AREA 7 CNH-R02-L01-A7.CS/2017
				 WHEN @pIdContrato = 10056	THEN 35	--AREA 14 CNH-R02-L01-A14.CS/2017
				 WHEN @pIdContrato = 10057	THEN 23	--AREA	CNH-R02-L04-AP-CS-G05/2018
			END,
			1
	end 

	if @nombreGrafica ='grafSeriePeriodoDesarrollo'
	begin 
		
			INSERT INTO #tmp
	SELECT
		1, 'Inicio Periodo',
		CASE WHEN @pIdContrato = 10049	THEN 12 -- AREA 10 CNH-R02-L01-A10.CS/2017
			 WHEN @pIdContrato = 10050	THEN 15 -- AREA	CNH-R03-L01-G-CS-01/2018
			 WHEN @pIdContrato = 10054	THEN 0	--AREA 1 CNH-R01-L02-A1/2015
			 WHEN @pIdContrato = 10055	THEN 13	--AREA 7 CNH-R02-L01-A7.CS/2017
			 WHEN @pIdContrato = 10056	THEN 15	--AREA 14 CNH-R02-L01-A14.CS/2017
			 WHEN @pIdContrato = 10057	THEN 3	--AREA	CNH-R02-L04-AP-CS-G05/2018
		END,
		1

	INSERT INTO #tmp
	SELECT
		2, 'Primer Año',
		CASE WHEN @pIdContrato = 10049	THEN 12 -- AREA 10 CNH-R02-L01-A10.CS/2017
			 WHEN @pIdContrato = 10050	THEN 15 -- AREA	CNH-R03-L01-G-CS-01/2018
			 WHEN @pIdContrato = 10054	THEN 0	--AREA 1 CNH-R01-L02-A1/2015
			 WHEN @pIdContrato = 10055	THEN 13	--AREA 7 CNH-R02-L01-A7.CS/2017
			 WHEN @pIdContrato = 10056	THEN 15	--AREA 14 CNH-R02-L01-A14.CS/2017
			 WHEN @pIdContrato = 10057	THEN 3	--AREA	CNH-R02-L04-AP-CS-G05/2018
		END,
		1

	INSERT INTO #tmp
	SELECT
		3, 'Primer Año',
		CASE WHEN @pIdContrato = 10049	THEN 17 -- AREA 10 CNH-R02-L01-A10.CS/2017
			 WHEN @pIdContrato = 10050	THEN 15 -- AREA	CNH-R03-L01-G-CS-01/2018
			 WHEN @pIdContrato = 10054	THEN 0	--AREA 1 CNH-R01-L02-A1/2015
			 WHEN @pIdContrato = 10055	THEN 13	--AREA 7 CNH-R02-L01-A7.CS/2017
			 WHEN @pIdContrato = 10056	THEN 15	--AREA 14 CNH-R02-L01-A14.CS/2017
			 WHEN @pIdContrato = 10057	THEN 3	--AREA	CNH-R02-L04-AP-CS-G05/2018
		END,
		2

	INSERT INTO #tmp
	SELECT
		4, 'CN Año 2025',
		CASE WHEN @pIdContrato = 10049	THEN 17 -- AREA 10 CNH-R02-L01-A10.CS/2017
			 WHEN @pIdContrato = 10050	THEN 15 -- AREA	CNH-R03-L01-G-CS-01/2018
			 WHEN @pIdContrato = 10054	THEN 0	--AREA 1 CNH-R01-L02-A1/2015
			 WHEN @pIdContrato = 10055	THEN 13	--AREA 7 CNH-R02-L01-A7.CS/2017
			 WHEN @pIdContrato = 10056	THEN 15	--AREA 14 CNH-R02-L01-A14.CS/2017
			 WHEN @pIdContrato = 10057	THEN 3	--AREA	CNH-R02-L04-AP-CS-G05/2018
		END,
		2

	INSERT INTO #tmp
	SELECT
		3, 'CN hasta fin Periodo',
		CASE WHEN @pIdContrato = 10049	THEN 35 -- AREA 10 CNH-R02-L01-A10.CS/2017
			 WHEN @pIdContrato = 10050	THEN 25 -- AREA	CNH-R03-L01-G-CS-01/2018
			 WHEN @pIdContrato = 10054	THEN 0	--AREA 1 CNH-R01-L02-A1/2015
			 WHEN @pIdContrato = 10055	THEN 13	--AREA 7 CNH-R02-L01-A7.CS/2017
			 WHEN @pIdContrato = 10056	THEN 15	--AREA 14 CNH-R02-L01-A14.CS/2017
			 WHEN @pIdContrato = 10057	THEN 3	--AREA	CNH-R02-L04-AP-CS-G05/2018
		END,
		3

	INSERT INTO #tmp
	SELECT
		5, 'CN Año 2025',
		CASE WHEN @pIdContrato = 10049	THEN 17 -- AREA 10 CNH-R02-L01-A10.CS/2017
			 WHEN @pIdContrato = 10050	THEN 15 -- AREA	CNH-R03-L01-G-CS-01/2018
			 WHEN @pIdContrato = 10054	THEN 0	--AREA 1 CNH-R01-L02-A1/2015
			 WHEN @pIdContrato = 10055	THEN 13	--AREA 7 CNH-R02-L01-A7.CS/2017
			 WHEN @pIdContrato = 10056	THEN 15	--AREA 14 CNH-R02-L01-A14.CS/2017
			 WHEN @pIdContrato = 10057	THEN 3	--AREA	CNH-R02-L04-AP-CS-G05/2018
		END,
		3

	end 

	/*TABLA CON INFORMACIÓN*/
	select	id,
			Titulo,
			Valor,
			Serie
	from	#tmp
END