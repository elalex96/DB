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
-- Create date: 14-07-2021
-- Description: Se agrego linea de tiempo de perforación
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ArmadoLineaDelTiempoPerforacion] --SP_EN_ArmadoLineaDelTiempoPerforacion 10050,10019
@IdContrato INT, 
@IdUsuario  INT 
AS
BEGIN
    SET NOCOUNT ON;
	SET language Spanish;

	
--/*
--10049	CNH-R02-L01-A10.CS/2017		A10
--10050	CNH-R03-L01-G-CS-01/2018	A28
--10054	CNH-R01-L02-A1/2015			A1
--10055	CNH-R02-L01-A7.CS/2017		A7
--10056	CNH-R02-L01-A14.CS/2017		A14
--10057	CNH-R02-L04-AP-CS-G05/2018	A24
--*/
     
		--SET @IdContrato = 10057;
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
																		<div class="tl-panel"><span class="bg-blue padding-5"> Inicio ' 
																		+ CONVERT(varchar,CAST('20170925' AS datetime),106) +
																		'</span></div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 100px; height: 23px; text-align: center">
																		<p style="color: #3498db"><strong style="background: white;">Etapa de Transición de Arranque</strong></p>
																	</div>',
																	1,
																	300);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES (dbo.FN_EN_SumaDiasHabiles('20170925', 120),'<div class="tl-row" style="width: 200px; height: 23px">
																									<div class="tl-item">
																										<div class="tl-bullet bg-blue"></div>
																										<div class="tl-panel"><span class="bg-blue padding-5"> Finaliza ' 
																										+ CONVERT(varchar,(dbo.FN_EN_SumaDiasHabiles('20170925', 120)),106) +
																										'</span> </div>
																										</div>
																									</div>',
																									1,
																									200);

			--PERFORACION
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20191007','<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-green"></div>
																			<div class="tl-panel"><span class="bg-green padding-5"> Inicio '
																				+ CONVERT(varchar,CAST('20191007' AS datetime),106) +
																			'</span></div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 300px; height: 23px; text-align: center">
																		<p style="color: #2ecc71"><strong style="background: white;">Perforación del Pozo ' + LTRIM(@Pozos) + '</strong></p>
																	</div>',
																	2,
																	500);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20200204','<div class="tl-row" style="width: 200px; height: 23px">
																										<div class="tl-item">
																											<div class="tl-bullet bg-green"></div>
																											<div class="tl-panel"><span class="bg-green padding-5"> Finaliza '
																												+ CONVERT(varchar,CAST('20200204' AS datetime),106) +
																											'</span></div>
																										</div>
																									</div>',
																									2,
																									200);
			
			--PERIODO
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20180925','<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"><span class="bg-purple padding-5"> Inicio ' +
																			CONVERT(varchar,CAST('20180925' AS datetime),106) +
																			'</span></div>
																			</div>
																		</div>
																		<div class="tl-row" style="width: 65px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong style="background: white;">Periodo de ' + @Periodo + '</strong></p>
																		</div>',
																		3,
																		265);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20220925','<div class="tl-row" style="width: 65px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong style="background: white;">Periodo de ' + @Periodo + '</strong></p>
																		</div>
																	<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"><span class="bg-purple padding-5"> Finaliza ' + 
																			CONVERT(varchar,CAST('20220925' AS datetime),106) +
																			'</span></div>
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
																		<div class="tl-panel"><span class="bg-blue padding-5"> Inicio ' 
																		+ CONVERT(varchar,CAST('20180627' AS datetime),106) +
																		'</span></div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 100px; height: 23px; text-align: center">
																		<p style="color: #3498db"><strong style="background: white;">Etapa de Transición de Arranque</strong></p>
																	</div>',
																	1,
																	300);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES (dbo.FN_EN_SumaDiasHabiles('20180627', 120),'<div class="tl-row" style="width: 200px; height: 23px">
																									<div class="tl-item">
																										<div class="tl-bullet bg-blue"></div>
																										<div class="tl-panel"><span class="bg-blue padding-5"> Finaliza ' 
																										+ CONVERT(varchar,(dbo.FN_EN_SumaDiasHabiles('20170925', 120)),106) +
																										'</span> </div>
																										</div>
																									</div>',
																									1,
																									200);
			--PERFORACION
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20191007','<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-green"></div>
																			<div class="tl-panel"><span class="bg-green padding-5"> Inicio '
																				+ CONVERT(varchar,CAST('20191007' AS datetime),106) +
																			'</span></div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 300px; height: 23px; text-align: center">
																		<p style="color: #2ecc71"><strong style="background: white;">Perforación del Pozo ' + LTRIM(@Pozos) + '</strong></p>
																	</div>',
																	2,
																	500);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20200204','<div class="tl-row" style="width: 200px; height: 23px">
																										<div class="tl-item">
																											<div class="tl-bullet bg-green"></div>
																											<div class="tl-panel"><span class="bg-green padding-5"> Finaliza '
																												+ CONVERT(varchar,CAST('20200204' AS datetime),106) +
																											'</span></div>
																										</div>
																									</div>',
																									2,
																									200);
			--PERIODO
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20190521','<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"><span class="bg-purple padding-5"> Inicio ' +
																			CONVERT(varchar,CAST('20190521' AS datetime),106) +
																			'</span></div>
																			</div>
																		</div>
																		<div class="tl-row" style="width: 65px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong style="background: white;">Periodo de ' + @Periodo + '</strong></p>
																		</div>',
																		3,
																		265);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20230521', '<div class="tl-row" style="width: 65px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong style="background: white;">Periodo de ' + @Periodo + '</strong></p>
																		</div>
																	<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"><span class="bg-purple padding-5"> Finaliza ' + 
																			CONVERT(varchar,CAST('20230521' AS datetime),106) +
																			'</span></div>
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
																		<div class="tl-panel"><span class="bg-blue padding-5"> Inicio ' 
																		+ CONVERT(varchar,CAST('20151130' AS datetime),106) +
																		'</span></div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 100px; height: 23px; text-align: center">
																		<p style="color: #3498db"><strong style="background: white;">Etapa de Transición de Arranque</strong></p>
																	</div>',1,300);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES (dbo.FN_EN_SumaDiasHabiles('20151130', 90),'<div class="tl-row" style="width: 200px; height: 23px">
																									<div class="tl-item">
																										<div class="tl-bullet bg-blue"></div>
																										<div class="tl-panel"><span class="bg-blue padding-5"> Finaliza ' 
																										+ CONVERT(varchar,(dbo.FN_EN_SumaDiasHabiles('20151130', 120)),106) +
																										'</span></div>
																										</div>
																									</div>',1,200);
			--PERFORACION
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20191007','<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-green"></div>
																			<div class="tl-panel"><span class="bg-green padding-5"> Inicio '
																				+ CONVERT(varchar,CAST('20191007' AS datetime),106) +
																			'</span></div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 300px; height: 23px; text-align: center">
																		<p style="color: #2ecc71"><strong style="background: white;">Perforación del Pozo ' + LTRIM(@Pozos) + '</strong></p>
																	</div>',2,500);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20200204','<div class="tl-row" style="width: 200px; height: 23px">
																										<div class="tl-item">
																											<div class="tl-bullet bg-green"></div>
																											<div class="tl-panel"><span class="bg-green padding-5"> Finaliza '
																												+ CONVERT(varchar,CAST('20200204' AS datetime),106) +
																											'</span></div>
																										</div>
																									</div>',2,200);
			--PERIODO
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20180810', '<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"><span class="bg-purple padding-5"> Inicio ' +
																			CONVERT(varchar,CAST('20180810' AS datetime),106) +
																			'</span></div>
																			</div>
																		</div>
																		<div class="tl-row" style="width: 70px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong style="background: white;">Periodo de ' + @Periodo + '</strong></p>
																		</div>',3,270);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20401130','<div class="tl-row" style="width: 70px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong style="background: white;">Periodo de ' + @Periodo + '</strong></p>
																		</div>
																	<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"><span class="bg-purple padding-5"> Finaliza ' + 
																			CONVERT(varchar,CAST('20401130' AS datetime),106) +
																			'</span></div>
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
																		<div class="tl-panel"><span class="bg-blue padding-5"> Inicio ' 
																		+ CONVERT(varchar,CAST('20170925' AS datetime),106) +
																		'</span></div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 100px; height: 23px; text-align: center">
																		<p style="color: #3498db"><strong style="background: white;">Etapa de Transición de Arranque</strong></p>
																	</div>',
																	1,
																	300);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES (dbo.FN_EN_SumaDiasHabiles('20170925', 90),'<div class="tl-row" style="width: 200px; height: 23px">
																									<div class="tl-item">
																										<div class="tl-bullet bg-blue"></div>
																										<div class="tl-panel"><span class="bg-blue padding-5"> Finaliza ' 
																										+ CONVERT(varchar,(dbo.FN_EN_SumaDiasHabiles('20151130', 120)),106) +
																										'</span></div>
																										</div>
																									</div>',1,
																									200);
			--PERFORACION
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20191007','<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-green"></div>
																			<div class="tl-panel"><span class="bg-green padding-5"> Inicio '
																				+ CONVERT(varchar,CAST('20191007' AS datetime),106) +
																			'</span></div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 300px; height: 23px; text-align: center">
																		<p style="color: #2ecc71"><strong style="background: white;">Perforación del Pozo ' + LTRIM(@Pozos) + '</strong></p>
																	</div>',2,200);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20200204','<div class="tl-row" style="width: 200px; height: 23px">
																										<div class="tl-item">
																											<div class="tl-bullet bg-green"></div>
																											<div class="tl-panel"><span class="bg-green padding-5"> Finaliza '
																												+ CONVERT(varchar,CAST('20200204' AS datetime),106) +
																											'</span></div>
																										</div>
																									</div>',2,200);
			--PERIODO
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20180925','<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"><span class="bg-purple padding-5"> Inicio ' +
																			CONVERT(varchar,CAST('20180925' AS datetime),106) +
																			'</span></div>
																			</div>
																		</div>
																		<div class="tl-row" style="width: 80px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong style="background: white;">Periodo de ' + @Periodo + '</strong></p>
																		</div>',3,280);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20220925','<div class="tl-row" style="width: 80px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong style="background: white;">Periodo de ' + @Periodo + '</strong></p>
																		</div>
																	<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"><span class="bg-purple padding-5"> Finaliza ' + 
																			CONVERT(varchar,CAST('20220925' AS datetime),106) +
																			'</span></div>
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
																		<div class="tl-panel"><span class="bg-blue padding-5"> Inicio ' 
																		+ CONVERT(varchar,CAST('20170925' AS datetime),106) +
																		'</span></div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 100px; height: 23px; text-align: center">
																		<p style="color: #3498db"><strong style="background: white;">Etapa de Transición de Arranque</strong></p>
																	</div>',1,300);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES (dbo.FN_EN_SumaDiasHabiles('20170925', 90),'<div class="tl-row" style="width: 200px; height: 23px">
																									<div class="tl-item">
																										<div class="tl-bullet bg-blue"></div>
																										<div class="tl-panel"><span class="bg-blue padding-5"> Finaliza ' 
																										+ CONVERT(varchar,(dbo.FN_EN_SumaDiasHabiles('20170925', 120)),106) +
																										'</span></div>
																										</div>
																									</div>',1,200);
			--PERFORACION
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20191007','<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-green"></div>
																			<div class="tl-panel"><span class="bg-green padding-5"> Inicio '
																				+ CONVERT(varchar,CAST('20191007' AS datetime),106) +
																			'</span></div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 300px; height: 23px; text-align: center">
																		<p style="color: #2ecc71"><strong style="background: white;">Perforación del Pozo ' + LTRIM(@Pozos) + '</strong></p>
																	</div>',2,500);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20200204','<div class="tl-row" style="width: 200px; height: 23px">
																										<div class="tl-item">
																											<div class="tl-bullet bg-green"></div>
																											<div class="tl-panel"><span class="bg-green padding-5"> Finaliza '
																												+ CONVERT(varchar,CAST('20200204' AS datetime),106) +
																											'</span></div>
																										</div>
																									</div>',2,200);
			--PERIODO
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20180925','<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"><span class=" bg-purple padding-5"> Inicio ' +
																			CONVERT(varchar,CAST('20180925' AS datetime),106) +
																			'</span></div>
																			</div>
																		</div>
																		<div class="tl-row" style="width: 65px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong style="background: white;">Periodo de ' + @Periodo + '</strong></p>
																		</div>',3,265);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20220925','<div class="tl-row" style="width: 65px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong style="background: white;">Periodo de ' + @Periodo + '</strong></p>
																		</div>
																	<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"><span class=" bg-purple padding-5">  Finaliza ' + 
																			CONVERT(varchar,CAST('20220925' AS datetime),106) +
																			'</span></div>
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
																		<div class="tl-panel"><span class="bg-blue padding-5"> Inicio ' 
																		+ CONVERT(varchar,CAST('20180507' AS datetime),106) +
																		'</span></div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 100px; height: 23px; text-align: center">
																		<p style="color: #3498db"><strong style="background: white;">Etapa de Transición de Arranque</strong></p>
																	</div>',1,300);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES (dbo.FN_EN_SumaDiasHabiles('20180507', 90),'<div class="tl-row" style="width: 200px; height: 23px">
																									<div class="tl-item">
																										<div class="tl-bullet bg-blue"></div>
																										<div class="tl-panel"><span class="bg-blue padding-5"> Finaliza ' 
																										+ CONVERT(varchar,(dbo.FN_EN_SumaDiasHabiles('20180507', 120)),106) +
																										'</span> </div>
																										</div>
																									</div>',1,200);
			--PERFORACION
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20191007','<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-green"></div>
																			<div class="tl-panel"><span class="bg-green padding-5"> Inicio '
																				+ CONVERT(varchar,CAST('20191007' AS datetime),106) +
																			'</span></div>
																		</div>
																	</div>
																	<div class="tl-row" style="width: 300px; height: 23px; text-align: center">
																		<p style="color: #2ecc71"><strong style="background: white;">Perforación del Pozo ' + LTRIM(@Pozos) + '</strong></p>
																	</div>',2,500);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20200204','<div class="tl-row" style="width: 200px; height: 23px">
																										<div class="tl-item">
																											<div class="tl-bullet bg-green"></div>
																											<div class="tl-panel"><span class="bg-green padding-5"> Finaliza '
																												+ CONVERT(varchar,CAST('20200204' AS datetime),106) +
																											'</span></div>
																										</div>
																									</div>',2,200);
			--PERIODO
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20190724','<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"><span class="bg-purple padding-5"> Inicio ' +
																			CONVERT(varchar,CAST('20190724' AS datetime),106) +
																			'</span></div>
																			</div>
																		</div>
																		<div class="tl-row" style="width: 65px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong style="background: white;">Periodo de ' + @Periodo + '</strong></p>
																		</div>',3,265);
			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) VALUES ('20230724','<div class="tl-row" style="width: 65px; height: 23px; text-align: center">
																			<p style="color: #7a3ecc"><strong style="background: white;">Periodo de ' + @Periodo + '</strong></p>
																		</div>
																	<div class="tl-row" style="width: 200px; height: 23px">
																		<div class="tl-item">
																			<div class="tl-bullet bg-purple"></div>
																			<div class="tl-panel"><span class="bg-purple padding-5"> Finaliza ' + 
																			CONVERT(varchar,CAST('20230724' AS datetime),106) +
																			'</span></div>
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