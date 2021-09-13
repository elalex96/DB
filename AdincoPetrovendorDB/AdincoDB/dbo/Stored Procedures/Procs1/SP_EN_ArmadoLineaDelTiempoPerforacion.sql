-- =============================================
-- Author: Daniel Ac
-- Create date: 14-07-2021
-- Description: Se agrego linea de tiempo de perforación
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ArmadoLineaDelTiempoPerforacion] --10054,0
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
     	--COLORES DE LOS RECUADROS ORGANIZADOS POR PERIODO
		CREATE TABLE #BulletColor
		(
			IdBullet INT, 
			bgColor  VARCHAR(MAX)
		);

		--CONSULTA DE LOS PERIODOS
		create table #tmpPeriodos
		(   
			RowN INT IDENTITY(1,1),
			PeriodoID	INT,
			Color VARCHAR(100)
		)

		--CONSULTA DE TODOS LOS EVENTOS
		create table #Periodos
		(   
			NumRow INT IDENTITY(1,1),
			PeriodoID	INT,
			Color VARCHAR(100),
			Anio INT,
			Nombre VARCHAR(1000),
			Fecha DATE,
			Tipo VARCHAR(100)
		)

		--SET @IdContrato = 10057;
		DECLARE @HTML VARCHAR(MAX);
		DECLARE @TEXTO VARCHAR(MAX);
		DECLARE @CONT INT = 1;
		DECLARE @TOTAL INT;
		DECLARE @TABLADATOS TABLE (FECHA DATETIME,TEXTO VARCHAR(MAX), NOGRUPOINTERVALO INT, WIDTH_ITEM INT);
		DECLARE @TABLAID TABLE (ID INT IDENTITY(1,1),FECHA DATETIME,TEXTO VARCHAR(MAX), NOGRUPOINTERVALO INT,WIDTH_ITEM INT);
		DECLARE @TABLA_ORDENGRUPO TABLE (NUEVO_GRUPO INT IDENTITY(1,1),FECHA DATETIME,NUMERO_GRUPO INT);
		DECLARE @Pozos	VARCHAR(250);
		DECLARE @Periodo	VARCHAR(50);
		DECLARE @TotalGrupos INT 
		DECLARE @ContadorGrupo INT 
		DECLARE @ContadorGrupoActual INT
		DECLARE @ITEM_SPACE VARCHAR(MAX) 
		DECLARE @WIDTH_ITEM VARCHAR(MAX) 
		DECLARE @HTML_FINAL VARCHAR(MAX)
		DECLARE @CONTPERIODOS INT = 1;
		DECLARE @CONTPERIODOST INT; 
		DECLARE @COLOR VARCHAR(100);
		DECLARE @NOMBREEVENTO VARCHAR(1000);
		DECLARE @FECHA DATE;
		DECLARE @PERIODOID INT;

		INSERT INTO #BulletColor
		VALUES(5, '#C6E5B1'),--VERDE CLARO
				(6, '#BBBBBB'),--GRIS CLARO
				(7, '#9FBAD5'),--AZUL CLARO
				(4, '#91B2FD'),--ROJO CLARO
				(1, '#CAB1CB'),--MORADO CLARO
				(2, '#96BCEB'),--NARANJA CLARO
				(3, '#73B1FF'),--AZUL
				(8, '#BBBBBB'),--GRIS
				(9, '#85689e'),--MORADO
				(10, '#BBBBBB'),--GRISS
				(11, '#73B1FF');--AZUL

		INSERT INTO #tmpPeriodos (PeriodoID)
		SELECT
			EtapaId
		FROM CO_ContratoEtapas
			WHERE ContratoId = @IdContrato
			AND Activo = 1

		--ASIGNACION DE LOS COLORES A LOS PERIODOS
		UPDATE TP
		SET TP.Color = BP.bgColor
		FROM #tmpPeriodos AS TP
		JOIN #BulletColor AS BP ON TP.RowN = BP.IdBullet

 		INSERT INTO #Periodos (PeriodoID, Color, Anio,Nombre,Fecha,Tipo)
		SELECT
			PC.EtapaId,
			TP.Color,
			YEAR(PC.FechaInicio),
			E.Etapa,
			PC.FechaInicio,
			'Inicio'
		FROM CO_ContratoEtapas AS PC
		JOIN #tmpPeriodos AS TP ON PC.EtapaId = TP.PeriodoID
		JOIN EN_Etapa E
			ON	PC.EtapaId = E.IdEtapa
		WHERE PC.ContratoId = @IdContrato
		AND PC.Activo = 1
		AND PC.FechaInicio IS NOT NULL
		UNION
		SELECT
			PC.EtapaId,
			TP.Color,
			YEAR(PC.FechaFin),
			E.Etapa,
			PC.FechaFin,
			'Fin'
		FROM CO_ContratoEtapas AS PC
		JOIN #tmpPeriodos AS TP ON PC.EtapaId = TP.PeriodoID
		JOIN EN_Etapa E
			ON	PC.EtapaId = E.IdEtapa
		WHERE PC.ContratoId = @IdContrato
		AND PC.Activo = 1
		AND PC.FechaFin	IS NOT NULL

		SET @CONTPERIODOST = (SELECT COUNT(RowN) FROM #tmpPeriodos);

		WHILE @CONTPERIODOS <= @CONTPERIODOST
		BEGIN

			SET @PERIODOID = (SELECT TOP 1 PeriodoID FROM #tmpPeriodos WHERE RowN = @CONTPERIODOS);
			
			SELECT 
				@COLOR = Color,
				@FECHA = Fecha,
				@NOMBREEVENTO = Nombre
			FROM #Periodos
			WHERE PeriodoID = @PERIODOID
			AND Tipo = 'Inicio'

			INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) 
			VALUES (CAST(@FECHA AS datetime),'<div class="tl-row" style="width: 200px; height: 23px">
												<div class="tl-item">
													<div class="tl-bullet bg-blue" style="background-color:' + @COLOR + ';"></div>
													<div class="tl-panel"><span class="bg-blue padding-5" style="background-color:' + @COLOR + ';"> ' +
													CASE WHEN @FECHA < GETDATE() THEN 'Inició ' ELSE 'Inicia ' END
													+ ISNULL(FORMAT(@FECHA,'dd-MM-yyyy'),'') +
													'</span></div>
													</div>
												</div>
												<div class="tl-row" style="width: 100px; height: 23px; text-align: center">
													<p style="color: '+ @COLOR +'"><strong style="background: white;">' + @NOMBREEVENTO + '</strong></p>
												</div>',
												@CONTPERIODOS,
												300);

			SELECT 
				@COLOR = Color,
				@FECHA = Fecha,
				@NOMBREEVENTO = Nombre
			FROM #Periodos
			WHERE PeriodoID = @PERIODOID
			AND Tipo = 'Fin'

			IF @FECHA IS NOT NULL
			BEGIN
				
				INSERT INTO @TABLADATOS (FECHA,TEXTO,NOGRUPOINTERVALO,WIDTH_ITEM) 
				VALUES (CAST(@FECHA AS datetime),'<div class="tl-row" style="width: 200px; height: 23px">
													<div class="tl-item">
														<div class="tl-bullet bg-blue" style="background-color:' + @COLOR + ';"></div>
														<div class="tl-panel"><span class="bg-blue padding-5" style="background-color:' + @COLOR + ';"> ' + 
														CASE WHEN @FECHA < GETDATE() THEN 'Finalizó ' ELSE 'Finaliza ' END
														+ ISNULL(FORMAT(@FECHA,'dd-MM-yyyy'),'') +
														'</span> </div>
														</div>
													</div>',
													@CONTPERIODOS,
													200);
			END

			SET @CONTPERIODOS = @CONTPERIODOS + 1;

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
					SET @WIDTH_ITEM = CAST(ISNULL((SELECT WIDTH_ITEM FROM @TABLAID WHERE ID = @CONT),0) AS VARCHAR(MAX));
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
