USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_EN_ArmadoLineaDelTiempoPerforacion'
)
    DROP PROCEDURE SP_EN_ArmadoLineaDelTiempoPerforacion;
GO 
/****** Object:  StoredProcedure [dbo].[SP_EN_ArmadoLineaDelTiempoPerforacion]    Script Date: 19/05/2021 11:10:23 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Daniel Ac
-- Create date: 20-05-2021
-- Description: Se agrego linea de tiempo de perforación
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ArmadoLineaDelTiempoPerforacion] --SP_EN_ArmadoLineaDelTiempoPerforacion 10050,10019
@IdContrato INT, 
@IdUsuario  INT 
AS
BEGIN
    SET NOCOUNT ON;
	SET language Spanish;

    --ESTE CONFIGURACIÓN ES ESTATICA PARA ARMADO DE PERFORACIÓN
	--DECLARE @HTML VARCHAR(MAX)=''
	--DECLARE @ETAIni	VARCHAR(500),
	--	@ETAFin VARCHAR(500),
	--	@NotificaPlanPlus1	VARCHAR(500),
		--@Pozos	VARCHAR(250),
		--@Periodo	VARCHAR(50),
	--	@PeriodoIni	VARCHAR(500),
	--	@PeriodoFin	VARCHAR(500);

--		DECLARE @IdContrato INT = 10049;

--		DECLARE @TABLADATOS TABLE (FECHA DATETIME);

--		IF @IdContrato = 10049
--		BEGIN 
--			--ETA
--			INSERT INTO @TABLADATOS (FECHA) VALUES ('20170925');
--			INSERT INTO @TABLADATOS (FECHA) VALUES (dbo.FN_EN_SumaDiasHabiles('20170925', 120));
--			--NOTIFICANPLUS
--			INSERT INTO @TABLADATOS (FECHA) VALUES ('20180810');
--			--PERIODO
--			INSERT INTO @TABLADATOS (FECHA) VALUES ('20180925');
--			INSERT INTO @TABLADATOS (FECHA) VALUES ('20220925');
--		END

--		SELECT * FROM @TABLADATOS ORDER BY FECHA ASC

--SELECT
	
--	@ETAIni =	CASE WHEN @IdContrato = 10049	THEN 'Inicio 25 de Septiembre de 2017'	--A10
--			WHEN @IdContrato = 10050	THEN 'Inicio 27 de Junio de 2018'		--A28
--			WHEN @IdContrato = 10054	THEN 'Inicio 30 de Noviembre de 2015'		--A1
--			WHEN @IdContrato = 10055	THEN 'Inicio 25 de Septiembre de 2017'	--A7
--			WHEN @IdContrato = 10056	THEN 'Inicio 25 de Septiembre de 2017'	--A14
--			WHEN @IdContrato = 10057	THEN 'Inicio 7 de Mayo de 2018'			--A24
--		END,
--	@ETAFin	= CASE WHEN @IdContrato = 10049	THEN 'Finaliza ' + LTRIM(DATEPART(DAY,dbo.FN_EN_SumaDiasHabiles('20170925', 120))) + ' de ' + DATENAME(MONTH,dbo.FN_EN_SumaDiasHabiles('20170925', 120)) + ' de ' + LTRIM(DATEPART(YEAR,dbo.FN_EN_SumaDiasHabiles('20170925', 120)))	--A10
--			WHEN @IdContrato = 10050	THEN 'Finaliza ' + LTRIM(DATEPART(DAY,dbo.FN_EN_SumaDiasHabiles('20180627', 120))) + ' de ' + DATENAME(MONTH,dbo.FN_EN_SumaDiasHabiles('20180627', 120)) + ' de ' + LTRIM(DATEPART(YEAR,dbo.FN_EN_SumaDiasHabiles('20180627', 120)))	--A28
--			WHEN @IdContrato = 10054	THEN 'Finaliza ' + LTRIM(DATEPART(DAY,dbo.FN_EN_SumaDiasHabiles('20151130', 90))) + ' de ' + DATENAME(MONTH,dbo.FN_EN_SumaDiasHabiles('20151130', 90)) + ' de ' + LTRIM(DATEPART(YEAR,dbo.FN_EN_SumaDiasHabiles('20151130', 90)))		--A1
--			WHEN @IdContrato = 10055	THEN 'Finaliza ' + LTRIM(DATEPART(DAY,dbo.FN_EN_SumaDiasHabiles('20170925', 120))) + ' de ' + DATENAME(MONTH,dbo.FN_EN_SumaDiasHabiles('20170925', 120)) + ' de ' + LTRIM(DATEPART(YEAR,dbo.FN_EN_SumaDiasHabiles('20170925', 120)))	--A7
--			WHEN @IdContrato = 10056	THEN 'Finaliza ' + LTRIM(DATEPART(DAY,dbo.FN_EN_SumaDiasHabiles('20170925', 180))) + ' de ' + DATENAME(MONTH,dbo.FN_EN_SumaDiasHabiles('20170925', 180)) + ' de ' + LTRIM(DATEPART(YEAR,dbo.FN_EN_SumaDiasHabiles('20170925', 180)))	--A14
--			WHEN @IdContrato = 10057	THEN 'Finaliza ' + LTRIM(DATEPART(DAY,dbo.FN_EN_SumaDiasHabiles('20180507', 120))) + ' de ' + DATENAME(MONTH,dbo.FN_EN_SumaDiasHabiles('20180507', 120)) + ' de ' + LTRIM(DATEPART(YEAR,dbo.FN_EN_SumaDiasHabiles('20180507', 120)))	--A24
--		END,
--	@NotificaPlanPlus1 = CASE WHEN @IdContrato = 10049	THEN 'Inicio 10 de Octubre de 2018'	--A10
--			WHEN @IdContrato = 10050	THEN 'Inicio 4 de Junio de 2019'		--A28
--			WHEN @IdContrato = 10054	THEN 'Inicio 25 de Junio de 2016'		--A1
--			WHEN @IdContrato = 10055	THEN 'Inicio 10 de Octubre de 2018'	--A7
--			WHEN @IdContrato = 10056	THEN 'Inicio 10 de Octubre de 2018'	--A14
--			WHEN @IdContrato = 10057	THEN 'Inicio 3 de Agosto de 2019'			--A24
--		END,
--	@Pozos	= CASE WHEN @IdContrato = 10049	THEN 'Sáasken-1EXP'	--A10
--			WHEN @IdContrato = 10050	THEN 'NA'		--A28
--			WHEN @IdContrato = 10054	THEN 'Amoca-2DEL, Amoca-3DEL, Amoca-4DEL, Tecoalli-2DEL, Miztón-2DEL, Miztón-3DES, Miztón-5DES, Miztón-7DES'		--A1
--			WHEN @IdContrato = 10055	THEN 'Ehécatl-1EXP'	--A7
--			WHEN @IdContrato = 10056	THEN 'NA'	--A14
--			WHEN @IdContrato = 10057	THEN 'NA'			--A24
--	END,
--	@Periodo	=	CASE WHEN @IdContrato = 10049	THEN 'Exploración'	--A10
--			WHEN @IdContrato = 10050	THEN 'Exploración'		--A28
--			WHEN @IdContrato = 10054	THEN 'Desarrollo/Primera modificación'		--A1
--			WHEN @IdContrato = 10055	THEN 'Exploración/Primera modificación'	--A7
--			WHEN @IdContrato = 10056	THEN 'Exploración'	--A14
--			WHEN @IdContrato = 10057	THEN 'Exploración'			--A24
--	END,
--	@PeriodoIni	=	CASE WHEN @IdContrato = 10049	THEN 'Inicio 25 de Septiembre de 2018'	--A10
--			WHEN @IdContrato = 10050	THEN 'Inicio 21 de Mayo de 2019'		--A28
--			WHEN @IdContrato = 10054	THEN 'Inicio 10 de Agosto de 2018'		--A1
--			WHEN @IdContrato = 10055	THEN 'Inicio 25 de Septiembre de 2018'	--A7
--			WHEN @IdContrato = 10056	THEN 'Inicio 25 de Septiembre de 2018'	--A14
--			WHEN @IdContrato = 10057	THEN 'Inicio 24 de Julio de 2019'			--A24
--	END,
--	@PeriodoFin	=	CASE WHEN @IdContrato = 10049	THEN 'Finaliza 25 de Septiembre de 2022'	--A10
--			WHEN @IdContrato = 10050	THEN 'Finaliza 21 de Mayo de 2023'		--A28
--			WHEN @IdContrato = 10054	THEN 'Finaliza 30 de Noviembre de 2040'		--A1
--			WHEN @IdContrato = 10055	THEN 'Finaliza 25 de Septiembre de 2022'	--A7
--			WHEN @IdContrato = 10056	THEN 'Finaliza 25 de Septiembre de 2022'	--A14
--			WHEN @IdContrato = 10057	THEN 'Finaliza 24 de Julio de 2023'			--A24
--	END

--	SET @HTML=N'<br><div class="timeline-box timeline-horizontal" style="width: 2400px; height: 100px">
--         <!-- Primer Periodo-->
--        <div class="tl-row" style="width: 85px; height: 23px">
--        </div>
--        <div class="tl-row" style="width: 200px; height: 23px">
--            <div class="tl-item">
--                <div class="tl-bullet bg-blue"></div>
--                <div class="tl-panel">' + LTRIM(@ETAIni) +
----                    Inicio 25 de Septiembre de 2017
--                '</div>
--            </div>
--        </div>
--        <div class="tl-row" style="width: 100px; height: 23px; text-align: center">
--            <p style="color: #3498db"><strong>Etapa de Transición de Arranque</strong></p>
--        </div>
--        <div class="tl-row" style="width: 200px; height: 23px">
--            <div class="tl-item">
--                <div class="tl-bullet bg-blue"></div>
--                <div class="tl-panel">' + LTRIM(@ETAFin) +
----                    Finaliza 20 de Marzo de 2018
--                '</div>
--            </div>
--        </div>
--         <!-- Segundo Periodo-->
--        <div class="tl-row" style="width: 160px; height: 23px">
--        </div>
--        <div class="tl-row" style="width: 200px; height: 23px">
--            <div class="tl-item">
--                <div class="tl-bullet bg-purple"></div>
--                <div class="tl-panel">' + LTRIM(@PeriodoIni) +
----                    Inicio 10 de Octubre de 2018
--                '</div>
--            </div>
--        </div>
--        <div class="tl-row" style="width: 200px; height: 23px; text-align: center">
--            <p style="color: #7a3ecc"><strong>Periodo de ' + LTRIM(@Periodo) + '</strong></p>
--        </div>
--        <div class="tl-row" style="width: 55px; height: 23px">
--        </div>
--        <div class="tl-row" style="width: 200px; height: 23px">
--            <div class="tl-item">
--                <div class="tl-bullet bg-green"></div>
--                <div class="tl-panel">
--                    Inicio 07 de Octubre de 2019
--                </div>
--            </div>
--        </div>
--        <!-- Tercer Periodo-->
--        <div class="tl-row" style="width: 300px; height: 23px; text-align: center">
--            <p style="color: #2ecc71"><strong>Perforación del Pozo ' + LTRIM(@Pozos) + '</strong></p>
--        </div>
--        <div class="tl-row" style="width: 200px; height: 23px">
--            <div class="tl-item">
--                <div class="tl-bullet bg-green"></div>
--                <div class="tl-panel">
--                    Finaliza 04 de Febrero de 2020
--                </div>
--            </div>
--        </div>
--        <div class="tl-row" style="width: 200px; height: 23px">
--            <div class="tl-item">
--                <div class="tl-bullet bg-purple"></div>
--                <div class="tl-panel">' + LTRIM(@PeriodoFin) +
----                    Finaliza 10 de Octubre de 2022
--                '</div>
--            </div>
--        </div>
--    </div><br>'

--	SELECT @HTML AS HtmlArmado

--/*
--10049	CNH-R02-L01-A10.CS/2017		A10
--10050	CNH-R03-L01-G-CS-01/2018	A28
--10054	CNH-R01-L02-A1/2015			A1
--10055	CNH-R02-L01-A7.CS/2017		A7
--10056	CNH-R02-L01-A14.CS/2017		A14
--10057	CNH-R02-L04-AP-CS-G05/2018	A24
--*/
     
		--SET @IdContrato = 10054;
		DECLARE @HTML NVARCHAR(MAX);
		DECLARE @TEXTO NVARCHAR(MAX);
		DECLARE @CONT INT = 1;
		DECLARE @TOTAL INT;
		DECLARE @TABLADATOS TABLE (FECHA DATETIME,TEXTO NVARCHAR(MAX), NOGRUPOINTERVALO INT, WIDTH_ITEM INT);
		DECLARE @TABLAID TABLE (ID INT IDENTITY(1,1),FECHA DATETIME,TEXTO NVARCHAR(MAX), NOGRUPOINTERVALO INT,WIDTH_ITEM INT);
		DECLARE @TABLA_ORDENGRUPO TABLE (NUEVO_GRUPO INT IDENTITY(1,1),FECHA DATETIME,NUMERO_GRUPO INT);
		DECLARE @Pozos	VARCHAR(250);
		DECLARE @Periodo	VARCHAR(50);
		DECLARE @TotalGrupos INT 
		DECLARE @ContadorGrupo INT 
		DECLARE @ContadorGrupoActual INT
		DECLARE @ITEM_SPACE NVARCHAR(MAX) 
		DECLARE @WIDTH_ITEM NVARCHAR(MAX) 
		DECLARE @HTML_FINAL NVARCHAR(MAX) 

		IF @IdContrato = 10049  --(CHECK)
		BEGIN 

			SET @Pozos = 'Sáasken-1EXP';
			SET @Periodo = 'Exploración';
			--ETA
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20170925','<div class="tl-row" style="width: 200px; height: 23px">
																	<div class="tl-item">
																		<div class="tl-bullet bg-blue"></div>
																		<div class="tl-panel"> Inicio ' 
																		+ CONVERT(varchar,CAST('20170925' AS datetime),106) +
																		'</div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 100px; height: 23px; text-align: center">
																		<p style="color: #3498db"><strong>Etapa de Transición de Arranque</strong></p>
																	</div>',
																	1,
																	300);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES (dbo.FN_EN_SumaDiasHabiles('20170925', 120),'<div class="tl-row" style="width: 200px; height: 23px">
																									<div class="tl-item">
																										<div class="tl-bullet bg-blue"></div>
																										<div class="tl-panel"> Finaliza ' 
																										+ CONVERT(varchar,(dbo.FN_EN_SumaDiasHabiles('20170925', 120)),106) +
																										' </div>
																										</div>
																									</div>',
																									1,
																									200);

			--PERFORACION
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20191007','<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-green"></div>
																			<div class="tl-panel"> Inicio '
																				+ CONVERT(varchar,CAST('20191007' AS datetime),106) +
																			'</div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 300px; height: 23px; text-align: center">
																		<p style="color: #2ecc71"><strong>Perforación del Pozo ' + LTRIM(@Pozos) + '</strong></p>
																	</div>',
																	2,
																	500);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20200204','<div class="tl-row" style="width: 200px; height: 23px">
																										<div class="tl-item">
																											<div class="tl-bullet bg-green"></div>
																											<div class="tl-panel"> Finaliza '
																												+ CONVERT(varchar,CAST('20200204' AS datetime),106) +
																											'</div>
																										</div>
																									</div>',
																									2,
																									200);
			
			--PERIODO
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20180925','<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"> Inicio ' +
																			CONVERT(varchar,CAST('20180925' AS datetime),106) +
																			'</div>
																			</div>
																		</div>
																		<div class="tl-row" style="width: 65px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong>Periodo de ' + @Periodo + '</strong></p>
																		</div>',
																		3,
																		265);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20220925','<div class="tl-row" style="width: 65px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong>Periodo de ' + @Periodo + '</strong></p>
																		</div>
																	<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"> Finaliza ' + 
																			CONVERT(varchar,CAST('20220925' AS datetime),106) +
																			'</div>
																		</div>
																	</div>',
																	3,
																	265);
		END

		IF @IdContrato = 10050 --(CHECK)
		BEGIN 

			SET @Pozos = 'N/A';
			SET @Periodo = 'Exploración';
			--ETA
			INSERT INTO @TABLADATOS (FECHA, TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20180627','<div class="tl-row" style="width: 200px; height: 23px">
																	<div class="tl-item">
																		<div class="tl-bullet bg-blue"></div>
																		<div class="tl-panel"> Inicio ' 
																		+ CONVERT(varchar,CAST('20180627' AS datetime),106) +
																		'</div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 100px; height: 23px; text-align: center">
																		<p style="color: #3498db"><strong>Etapa de Transición de Arranque</strong></p>
																	</div>',
																	1,
																	300);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES (dbo.FN_EN_SumaDiasHabiles('20180627', 120),'<div class="tl-row" style="width: 200px; height: 23px">
																									<div class="tl-item">
																										<div class="tl-bullet bg-blue"></div>
																										<div class="tl-panel"> Finaliza ' 
																										+ CONVERT(varchar,(dbo.FN_EN_SumaDiasHabiles('20170925', 120)),106) +
																										' </div>
																										</div>
																									</div>',
																									1,
																									200);
			--PERFORACION
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20191007','<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-green"></div>
																			<div class="tl-panel"> Inicio '
																				+ CONVERT(varchar,CAST('20191007' AS datetime),106) +
																			'</div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 300px; height: 23px; text-align: center">
																		<p style="color: #2ecc71"><strong>Perforación del Pozo ' + LTRIM(@Pozos) + '</strong></p>
																	</div>',
																	2,
																	500);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20200204','<div class="tl-row" style="width: 200px; height: 23px">
																										<div class="tl-item">
																											<div class="tl-bullet bg-green"></div>
																											<div class="tl-panel"> Finaliza '
																												+ CONVERT(varchar,CAST('20200204' AS datetime),106) +
																											'</div>
																										</div>
																									</div>',
																									2,
																									200);
			--PERIODO
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20190521','<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"> Inicio ' +
																			CONVERT(varchar,CAST('20190521' AS datetime),106) +
																			'</div>
																			</div>
																		</div>
																		<div class="tl-row" style="width: 65px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong>Periodo de ' + @Periodo + '</strong></p>
																		</div>',
																		3,
																		265);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20230521', '<div class="tl-row" style="width: 65px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong>Periodo de ' + @Periodo + '</strong></p>
																		</div>
																	<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"> Finaliza ' + 
																			CONVERT(varchar,CAST('20230521' AS datetime),106) +
																			'</div>
																		</div>
																	</div>',
																	3,
																	265);

			


		END

		IF @IdContrato = 10054 --(CHECK)
		BEGIN 
			SET @Pozos = 'Amoca-2DEL, Amoca-3DEL, Amoca-4DEL, Tecoalli-2DEL, Miztón-2DEL, Miztón-3DES, Miztón-5DES, Miztón-7DES';
			SET @Periodo = 'Desarrollo/Primera modificación';
			--ETA
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20151130','<div class="tl-row" style="width: 200px; height: 23px">
																	<div class="tl-item">
																		<div class="tl-bullet bg-blue"></div>
																		<div class="tl-panel"> Inicio ' 
																		+ CONVERT(varchar,CAST('20151130' AS datetime),106) +
																		'</div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 100px; height: 23px; text-align: center">
																		<p style="color: #3498db"><strong>Etapa de Transición de Arranque</strong></p>
																	</div>',1,300);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES (dbo.FN_EN_SumaDiasHabiles('20151130', 90),'<div class="tl-row" style="width: 200px; height: 23px">
																									<div class="tl-item">
																										<div class="tl-bullet bg-blue"></div>
																										<div class="tl-panel"> Finaliza ' 
																										+ CONVERT(varchar,(dbo.FN_EN_SumaDiasHabiles('20151130', 120)),106) +
																										' </div>
																										</div>
																									</div>',1,200);
			--PERFORACION
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20191007','<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-green"></div>
																			<div class="tl-panel"> Inicio '
																				+ CONVERT(varchar,CAST('20191007' AS datetime),106) +
																			'</div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 300px; height: 23px; text-align: center">
																		<p style="color: #2ecc71"><strong>Perforación del Pozo ' + LTRIM(@Pozos) + '</strong></p>
																	</div>',2,500);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20200204','<div class="tl-row" style="width: 200px; height: 23px">
																										<div class="tl-item">
																											<div class="tl-bullet bg-green"></div>
																											<div class="tl-panel"> Finaliza '
																												+ CONVERT(varchar,CAST('20200204' AS datetime),106) +
																											'</div>
																										</div>
																									</div>',2,200);
			--PERIODO
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20180810', '<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"> Inicio ' +
																			CONVERT(varchar,CAST('20180810' AS datetime),106) +
																			'</div>
																			</div>
																		</div>
																		<div class="tl-row" style="width: 70px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong>Periodo de ' + @Periodo + '</strong></p>
																		</div>',3,270);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20401130','<div class="tl-row" style="width: 70px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong>Periodo de ' + @Periodo + '</strong></p>
																		</div>
																	<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"> Finaliza ' + 
																			CONVERT(varchar,CAST('20401130' AS datetime),106) +
																			'</div>
																		</div>
																	</div>',3,270);
		END

		IF @IdContrato = 10055 --(CHECK)
		BEGIN 
			SET @Pozos = 'Ehécatl-1EXP';
			SET @Periodo = 'Exploración/Primera modificación';
			--ETA
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20170925','<div class="tl-row" style="width: 200px; height: 23px">
																	<div class="tl-item">
																		<div class="tl-bullet bg-blue"></div>
																		<div class="tl-panel"> Inicio ' 
																		+ CONVERT(varchar,CAST('20170925' AS datetime),106) +
																		'</div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 100px; height: 23px; text-align: center">
																		<p style="color: #3498db"><strong>Etapa de Transición de Arranque</strong></p>
																	</div>',
																	1,
																	300);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES (dbo.FN_EN_SumaDiasHabiles('20170925', 90),'<div class="tl-row" style="width: 200px; height: 23px">
																									<div class="tl-item">
																										<div class="tl-bullet bg-blue"></div>
																										<div class="tl-panel"> Finaliza ' 
																										+ CONVERT(varchar,(dbo.FN_EN_SumaDiasHabiles('20151130', 120)),106) +
																										' </div>
																										</div>
																									</div>',1,
																									200);
			--PERFORACION
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20191007','<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-green"></div>
																			<div class="tl-panel"> Inicio '
																				+ CONVERT(varchar,CAST('20191007' AS datetime),106) +
																			'</div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 300px; height: 23px; text-align: center">
																		<p style="color: #2ecc71"><strong>Perforación del Pozo ' + LTRIM(@Pozos) + '</strong></p>
																	</div>',2,200);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20200204','<div class="tl-row" style="width: 200px; height: 23px">
																										<div class="tl-item">
																											<div class="tl-bullet bg-green"></div>
																											<div class="tl-panel"> Finaliza '
																												+ CONVERT(varchar,CAST('20200204' AS datetime),106) +
																											'</div>
																										</div>
																									</div>',2,200);
			--PERIODO
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20180925','<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"> Inicio ' +
																			CONVERT(varchar,CAST('20180925' AS datetime),106) +
																			'</div>
																			</div>
																		</div>
																		<div class="tl-row" style="width: 80px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong>Periodo de ' + @Periodo + '</strong></p>
																		</div>',3,280);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20220925','<div class="tl-row" style="width: 80px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong>Periodo de ' + @Periodo + '</strong></p>
																		</div>
																	<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"> Finaliza ' + 
																			CONVERT(varchar,CAST('20220925' AS datetime),106) +
																			'</div>
																		</div>
																	</div>',3,280);
		END

		IF @IdContrato = 10056 --(CHECK)
		BEGIN 
			SET @Pozos = 'N/A';
			SET @Periodo = 'Exploración';
			--ETA
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20170925','<div class="tl-row" style="width: 200px; height: 23px">
																	<div class="tl-item">
																		<div class="tl-bullet bg-blue"></div>
																		<div class="tl-panel"> Inicio ' 
																		+ CONVERT(varchar,CAST('20170925' AS datetime),106) +
																		'</div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 100px; height: 23px; text-align: center">
																		<p style="color: #3498db"><strong>Etapa de Transición de Arranque</strong></p>
																	</div>',1,300);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES (dbo.FN_EN_SumaDiasHabiles('20170925', 90),'<div class="tl-row" style="width: 200px; height: 23px">
																									<div class="tl-item">
																										<div class="tl-bullet bg-blue"></div>
																										<div class="tl-panel"> Finaliza ' 
																										+ CONVERT(varchar,(dbo.FN_EN_SumaDiasHabiles('20170925', 120)),106) +
																										' </div>
																										</div>
																									</div>',1,200);
			--PERFORACION
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20191007','<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-green"></div>
																			<div class="tl-panel"> Inicio '
																				+ CONVERT(varchar,CAST('20191007' AS datetime),106) +
																			'</div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 300px; height: 23px; text-align: center">
																		<p style="color: #2ecc71"><strong>Perforación del Pozo ' + LTRIM(@Pozos) + '</strong></p>
																	</div>',2,500);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20200204','<div class="tl-row" style="width: 200px; height: 23px">
																										<div class="tl-item">
																											<div class="tl-bullet bg-green"></div>
																											<div class="tl-panel"> Finaliza '
																												+ CONVERT(varchar,CAST('20200204' AS datetime),106) +
																											'</div>
																										</div>
																									</div>',2,200);
			--PERIODO
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20180925','<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"> Inicio ' +
																			CONVERT(varchar,CAST('20180925' AS datetime),106) +
																			'</div>
																			</div>
																		</div>
																		<div class="tl-row" style="width: 65px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong>Periodo de ' + @Periodo + '</strong></p>
																		</div>',3,265);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20220925','<div class="tl-row" style="width: 65px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong>Periodo de ' + @Periodo + '</strong></p>
																		</div>
																	<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"> Finaliza ' + 
																			CONVERT(varchar,CAST('20220925' AS datetime),106) +
																			'</div>
																		</div>
																	</div>',3,265);
		END

		IF @IdContrato = 10057 --(CHECK)
		BEGIN 
			SET @Pozos = 'N/A';
			SET @Periodo = 'Exploración';
			--ETA
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20180507','<div class="tl-row" style="width: 200px; height: 23px">
																	<div class="tl-item">
																		<div class="tl-bullet bg-blue"></div>
																		<div class="tl-panel"> Inicio ' 
																		+ CONVERT(varchar,CAST('20180507' AS datetime),106) +
																		'</div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 100px; height: 23px; text-align: center">
																		<p style="color: #3498db"><strong>Etapa de Transición de Arranque</strong></p>
																	</div>',1,300);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES (dbo.FN_EN_SumaDiasHabiles('20180507', 90),'<div class="tl-row" style="width: 200px; height: 23px">
																									<div class="tl-item">
																										<div class="tl-bullet bg-blue"></div>
																										<div class="tl-panel"> Finaliza ' 
																										+ CONVERT(varchar,(dbo.FN_EN_SumaDiasHabiles('20180507', 120)),106) +
																										' </div>
																										</div>
																									</div>',1,200);
			--PERFORACION
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20191007','<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-green"></div>
																			<div class="tl-panel"> Inicio '
																				+ CONVERT(varchar,CAST('20191007' AS datetime),106) +
																			'</div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 300px; height: 23px; text-align: center">
																		<p style="color: #2ecc71"><strong>Perforación del Pozo ' + LTRIM(@Pozos) + '</strong></p>
																	</div>',2,500);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20200204','<div class="tl-row" style="width: 200px; height: 23px">
																										<div class="tl-item">
																											<div class="tl-bullet bg-green"></div>
																											<div class="tl-panel"> Finaliza '
																												+ CONVERT(varchar,CAST('20200204' AS datetime),106) +
																											'</div>
																										</div>
																									</div>',2,200);
			--PERIODO
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20190724','<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"> Inicio ' +
																			CONVERT(varchar,CAST('20190724' AS datetime),106) +
																			'</div>
																			</div>
																		</div>
																		<div class="tl-row" style="width: 65px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong>Periodo de ' + @Periodo + '</strong></p>
																		</div>',3,265);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20230724','<div class="tl-row" style="width: 65px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong>Periodo de ' + @Periodo + '</strong></p>
																		</div>
																	<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"> Finaliza ' + 
																			CONVERT(varchar,CAST('20230724' AS datetime),106) +
																			'</div>
																		</div>
																	</div>',3,265);
		END

		/*AGREGAR LOS ITEMS POR ORDEN DE FECHA*/
		INSERT INTO @TABLAID
		SELECT 
			FECHA,
			TEXTO,
			NOGRUPOINTERVALO,
			WIDTH_ITEM
		FROM @TABLADATOS
		ORDER BY FECHA ASC
		
		/*OBTENER UN NUEVO GRUPO PARA LOS ITEMS DEACUERDO A LA FECHA MINIMA POR GRUPO*/
		INSERT INTO @TABLA_ORDENGRUPO(NUMERO_GRUPO,FECHA)
		SELECT 		
		NOGRUPOINTERVALO,
		MIN(FECHA)
		FROM @TABLADATOS
		GROUP BY NOGRUPOINTERVALO
		ORDER BY MIN(FECHA) ASC
		
		/*REASIGNAR EL ORDEN DE DIBUJADO DE LAS LINEAS DE TIEMPO*/
		UPDATE TB
		SET TB.NOGRUPOINTERVALO=TBG.NUEVO_GRUPO
		FROM @TABLAID TB
		JOIN @TABLA_ORDENGRUPO TBG
		ON TB.NOGRUPOINTERVALO=TBG.NUMERO_GRUPO
				
		SET @TotalGrupos = (SELECT COUNT(1) FROM @TABLA_ORDENGRUPO) --> OBTENER CANTIDAD DE GRUPOS DE ITEMS --> CADA GRUPO ES ETAPA, PERIODO, PERFO --> Y CADA UNA REPRESENTA UNA LINEA DE TIEMPO
		SET @ContadorGrupo = 1
		SET @ContadorGrupoActual = 0
		SET @ITEM_SPACE = N'<div class="tl-row" style="width: ##WIDTH##px; height:23px"></div>'
		SET @WIDTH_ITEM =''
		SET @HTML_FINAL =''

		/*RECORRER EL TOTAL DE GRUPOS UN GRUPO ES UNA LINEA DE TIEMPO*/
		WHILE @TotalGrupos>= @ContadorGrupo
		BEGIN 
		   
		    SET @HTML = '<br>
						<div class="timeline-box timeline-horizontal" style="width: 2400px; height: 100px">
							<div class="tl-row" style="width: 85px; height: 23px">
						</div>';

			/*RECORRER TODOS LOS INTERVALO(ITEMS)S Y  SOLO DIBUJAR DONDE LE CORRESPONDA AL GRUPO DEL INTERVARLO ACTUAL, SI NO LE CORRESPONDE
			SOLO AGREGAR EL DIV DEFAULT @ITEM_SPACE CON EL WIDTH QUE LE CORRESPONDERIA AL ITEM DEL INTERVALO QUE SE OMITE*/

			SET @TOTAL = (SELECT COUNT(1) FROM @TABLAID);
			SET @CONT	= 1
			--> LA LISTA DE ITEMS SE TIENE QUE RECORRER PARA SABER CUANTO DE ESPACIO LE CORRESPONDE  A CADA ITEM QUE NO SE DIBUJA <--> PARA DEJAR EL ESPACIO
			WHILE @TOTAL >= @CONT
			BEGIN
		        
				SELECT @ContadorGrupoActual=NOGRUPOINTERVALO --> OBTENER EL GRUPO A DIBUJAR
				FROM @TABLAID WHERE ID = @CONT 

				IF @ContadorGrupoActual=@ContadorGrupo
				BEGIN
					SET @TEXTO = (SELECT TEXTO FROM @TABLAID WHERE ID = @CONT);--> AGREGAR EL TEXTO DEL ITEM QUE CORRESPONSE DIBUJAR
				END 
				ELSE
				BEGIN
					SET @WIDTH_ITEM = CAST(ISNULL((SELECT WIDTH_ITEM FROM @TABLAID WHERE ID = @CONT),0) AS NVARCHAR(MAX));
					SET @TEXTO = REPLACE(@ITEM_SPACE,'##WIDTH##',@WIDTH_ITEM) --> SUSTITUIR EL WIDTH QUE TENDRIA EL ITEM QUE SE DIBUJARIA 
				END 

				SET @HTML = CONCAT(@HTML,@TEXTO);

				SET @CONT = @CONT + 1;
			END

			SET @HTML = CONCAT(@HTML,'</div><br>');

		    SET @HTML_FINAL = CONCAT(@HTML_FINAL,@HTML);
		    
			SET @ContadorGrupo = @ContadorGrupo + 1
		END


		SELECT @HTML_FINAL AS HtmlArmado;
END;
