USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_ENT_ImportacionEntregablesEditables]    Script Date: 29/10/2021 10:08:26 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  Alexander Gomez 
-- Create date: <26/08/2021>  
-- Description: <Actualizacion de los registros existentes>  
-- =============================================  
ALTER PROCEDURE [dbo].[SP_ENT_ImportacionEntregablesEditables] 
	@Layout dbo.Entregables_Importacion_Edicion_01 READONLY,
	@IdContrato INT,
	@IdUsuario INT
AS
BEGIN
	
	DECLARE @ERRORES NVARCHAR(MAX) = '';
	DECLARE @CONTADORAFECTADOS INT = 0;
	DECLARE @CONTADORERRORES INT = 0;
	DECLARE @CONT_RE INT = 1;
	DECLARE @CONT_RE_CORRECTOS INT = 1;
	DECLARE @CONT_TOTAL INT = 0;
	DECLARE @CONT_TOTAL_CORRECTO INT = 0;
	DECLARE @IDENTREGABLE INT;
	DECLARE @IDCONFIGURACION INT;
	DECLARE @ERROES_TABLE TABLE (ID INT IDENTITY(1,1),IdEntregables INT, Error NVARCHAR(MAX));
	DECLARE @DATOS_TABLE TABLE (ID INT IDENTITY(1,1),IdEntregables INT);

	--VERIFICACION DE REGISTROS NO VALIDOS
	INSERT INTO @ERROES_TABLE
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la licencia no es aceptable.</li>'
	FROM @Layout 
	WHERE Licencia = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la Producción compartida no es aceptable.</li>'
	FROM @Layout 
	WHERE ProduccionCompartida = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la Producción compartida farm Outs no es aceptable.</li>'
	FROM @Layout 
	WHERE TCProducionCompartidaFarmOuts = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> el terrestre  no es aceptable.</li>'
	FROM @Layout 
	WHERE UGTerrestre = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la costa fuera no es aceptable.</li>'
	FROM @Layout 
	WHERE UGCostaFuera = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> los reguladores no es aceptable.</li>'
	FROM @Layout 
	WHERE REReguladores = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la administración de contratos no es aceptable.</li>'
	FROM @Layout 
	WHERE APAdministracionContratos = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> el pozo de alivio no es aceptable.</li>'
	FROM @Layout 
	WHERE APPozoAlivio = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> el pozo de alivio no es aceptable.</li>'
	FROM @Layout 
	WHERE APPozoAlivio = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> el Cierre/ Desmantelamiento/ Abandono no es aceptable.</li>'
	FROM @Layout 
	WHERE APCierreDesmantelamientoAbandono = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la perforación no es aceptable.</li>'
	FROM @Layout 
	WHERE APPerforacion = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la terminación no es aceptable.</li>'
	FROM @Layout 
	WHERE APTerminacion = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la actividad producción no es aceptable.</li>'
	FROM @Layout 
	WHERE APActProduccion = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la estimulación no es aceptable.</li>'
	FROM @Layout 
	WHERE APEstimulacion = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la construcción de camino no es aceptable.</li>'
	FROM @Layout 
	WHERE APConstruccionCamino = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la construcción de localización no es aceptable.</li>'
	FROM @Layout 
	WHERE APConstruccionLocalizacion = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la rehabilitación de camino no es aceptable.</li>'
	FROM @Layout 
	WHERE APRehabilitacionCamino = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la rehabilitación de localización no es aceptable.</li>'
	FROM @Layout 
	WHERE APRehabilitacionLocalizacion = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la toma de información sismica no es aceptable.</li>'
	FROM @Layout 
	WHERE APTomaInformacionSismica = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> el corte de nucleos no es aceptable.</li>'
	FROM @Layout 
	WHERE APCorteNucleos = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la construcción de linea de descarga no es aceptable.</li>'
	FROM @Layout 
	WHERE APConstruccionLineaDescarga = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> el sistema artificial de producción no es aceptable.</li>'
	FROM @Layout 
	WHERE APSistemaArtificialProduccion = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> el medición de pozos no es aceptable.</li>'
	FROM @Layout 
	WHERE APMedicionPozos = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la toma de información de pozos no es aceptable.</li>'
	FROM @Layout 
	WHERE APTomaInformacionPozo = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la reparación mayor no es aceptable.</li>'
	FROM @Layout 
	WHERE APReparacionMayor = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la reparación menor no es aceptable.</li>'
	FROM @Layout 
	WHERE APReparacionMenor = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> el transporte de hidrocarburos no es aceptable.</li>'
	FROM @Layout 
	WHERE APTransporteHidrocarburos = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la quema de gas no es aceptable.</li>'
	FROM @Layout 
	WHERE APQuemaGas = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> el desarrollo no es aceptable.</li>'
	FROM @Layout 
	WHERE Desarrollo = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la Exploracion no es aceptable.</li>'
	FROM @Layout 
	WHERE Exploracion = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la Evaluacion no es aceptable.</li>'
	FROM @Layout 
	WHERE Evaluacion = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la Transicion no es aceptable.</li>'
	FROM @Layout 
	WHERE Transicion = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> el Abandono Area no es aceptable.</li>'
	FROM @Layout 
	WHERE AbandonoArea = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> el Abandono Pozo no es aceptable.</li>'
	FROM @Layout 
	WHERE AbandonoPozo = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la licencia farm outs no es aceptable.</li>'
	FROM @Layout 
	WHERE TCLicenciaFarmOuts = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> los operadores no es aceptable.</li>'
	FROM @Layout 
	WHERE REOperadores = ''
	UNION
	SELECT
		IdEntregable,'<li>En el Entregable <strong>#'+ CAST(IdEntregable AS nvarchar) + '</strong> la prueba de producción no es aceptable.</li>'
	FROM @Layout 
	WHERE APPruebaProduccion = '';

	SET @CONT_TOTAL = (SELECT COUNT(1) FROM @ERROES_TABLE);

	WHILE @CONT_TOTAL >= @CONT_RE
	BEGIN
		
		SET @ERRORES = @ERRORES + (SELECT Error FROM @ERROES_TABLE WHERE ID = @CONT_RE)
		SET @CONT_RE = @CONT_RE + 1;

	END

	INSERT @DATOS_TABLE
	SELECT
		IdEntregable
	FROM @Layout
	WHERE IdEntregable NOT IN (SELECT IdEntregable FROM @ERROES_TABLE)

	--ACTUALIZACION DE LOS REGISTROS CORRECTOS
	UPDATE E
	SET	 E.TCLicencia = (CASE WHEN L.Licencia = 'SI' THEN 1 ELSE 0 END),
		 E.TCProducionCompartida = CASE WHEN L.ProduccionCompartida = 'SI' THEN 1 ELSE 0 END,
		 E.TCLicenciaFarmOuts = CASE WHEN L.TCLicenciaFarmOuts = 'SI' THEN 1 ELSE 0 END,
		 E.TCProducionCompartidaFarmOuts = CASE WHEN L.TCProducionCompartidaFarmOuts = 'SI' THEN 1 ELSE 0 END,
		 E.UGTerrestre = CASE WHEN L.UGTerrestre = 'SI' THEN 1 ELSE 0 END,
		 E.UGCostaFuera = CASE WHEN L.UGCostaFuera = 'SI' THEN 1 ELSE 0 END,
		 E.REReguladores = CASE WHEN L.REReguladores = 'SI' THEN 1 ELSE 0 END,
		 E.REOperadores = CASE WHEN L.REOperadores = 'SI' THEN 1 ELSE 0 END,
		 E.APAdministracionContratos = CASE WHEN L.APAdministracionContratos = 'SI' THEN 1 ELSE 0 END,
		 E.APPozoAlivio = CASE WHEN L.APPozoAlivio = 'SI' THEN 1 ELSE 0 END,
		 E.APCierreDesmantelamientoAbandono = CASE WHEN L.APCierreDesmantelamientoAbandono = 'SI' THEN 1 ELSE 0 END,
		 E.APPerforacion = CASE WHEN L.APPerforacion = 'SI' THEN 1 ELSE 0 END,
		 E.APTerminacion = CASE WHEN L.APTerminacion = 'SI' THEN 1 ELSE 0 END,
		 E.APActProduccion  = CASE WHEN L.APActProduccion = 'SI' THEN 1 ELSE 0 END,
		 E.APEstimulacion  = CASE WHEN L.APEstimulacion = 'SI' THEN 1 ELSE 0 END,
		 E.APPruebaProduccion  = CASE WHEN L.APPruebaProduccion = 'SI' THEN 1 ELSE 0 END,
		 E.APConstruccionCamino  = CASE WHEN L.APConstruccionCamino = 'SI' THEN 1 ELSE 0 END,
		 E.APConstruccionLocalizacion  = CASE WHEN L.APConstruccionLocalizacion = 'SI' THEN 1 ELSE 0 END,
		 E.APRehabilitacionCamino = CASE WHEN L.APRehabilitacionCamino = 'SI' THEN 1 ELSE 0 END,
		 E.APRehabilitacionLocalizacion = CASE WHEN L.APRehabilitacionLocalizacion = 'SI' THEN 1 ELSE 0 END,
		 E.APTomaInformacionSismica = CASE WHEN L.APTomaInformacionSismica = 'SI' THEN 1 ELSE 0 END,
		 E.APCorteNucleos  = CASE WHEN L.APCorteNucleos = 'SI' THEN 1 ELSE 0 END,
		 E.APConstruccionLineaDescarga = CASE WHEN L.APConstruccionLineaDescarga = 'SI' THEN 1 ELSE 0 END,
		 E.APSistemaArtificialProduccion  = CASE WHEN L.APSistemaArtificialProduccion = 'SI' THEN 1 ELSE 0 END,
		 E.APMedicionPozos  = CASE WHEN L.APMedicionPozos = 'SI' THEN 1 ELSE 0 END,
		 E.APTomaInformacionPozo  = CASE WHEN L.APTomaInformacionPozo = 'SI' THEN 1 ELSE 0 END,
		 E.APReparacionMayor  = CASE WHEN L.APReparacionMayor = 'SI' THEN 1 ELSE 0 END,
		 E.APReparacionMenor  = CASE WHEN L.APReparacionMenor = 'SI' THEN 1 ELSE 0 END,
		 E.APTransporteHidrocarburos  = CASE WHEN L.APTransporteHidrocarburos = 'SI' THEN 1 ELSE 0 END,
		 E.APQuemaGas = CASE WHEN L.APQuemaGas = 'SI' THEN 1 ELSE 0 END
	FROM dbo.EN_Entregable AS E
	JOIN @Layout AS L ON E.IdEntregable = L.IdEntregable
	WHERE E.IdEntregable IN (SELECT IdEntregables FROM @DATOS_TABLE) AND
		 L.IdEntregable <> '' AND
		 L.Licencia <> '' AND
		 L.ProduccionCompartida <> '' AND
		 L.TCProducionCompartidaFarmOuts <> '' AND
		 L.UGTerrestre <> '' AND
		 L.UGCostaFuera <> '' AND
		 L.REReguladores <> '' AND
		 L.APAdministracionContratos <> '' AND
		 L.APPozoAlivio <> '' AND
		 L.APCierreDesmantelamientoAbandono <> '' AND
		 L.APPerforacion <> '' AND
		 L.APTerminacion <> '' AND
		 L.APActProduccion <> '' AND
		 L.APEstimulacion <> '' AND
		 L.APConstruccionCamino <> '' AND
		 L.APConstruccionLocalizacion <> '' AND
		 L.APRehabilitacionCamino <> '' AND
		 L.APRehabilitacionLocalizacion <> '' AND
		 L.APTomaInformacionSismica <> '' AND
		 L.APCorteNucleos <> '' AND
		 L.APConstruccionLineaDescarga <> '' AND
		 L.APSistemaArtificialProduccion <> '' AND
		 L.APMedicionPozos <> '' AND
		 L.APTomaInformacionPozo <> '' AND
		 L.APReparacionMayor <> '' AND
		 L.APReparacionMenor <> '' AND
		 L.APTransporteHidrocarburos <> '' AND
		 L.APQuemaGas <> '';

	SET @CONT_TOTAL_CORRECTO = (SELECT COUNT(1) FROM @DATOS_TABLE);

	WHILE @CONT_TOTAL_CORRECTO >= @CONT_RE_CORRECTOS
	BEGIN
		
		SET @IDENTREGABLE = (SELECT IdEntregables FROM @DATOS_TABLE where ID = @CONT_RE_CORRECTOS);
		SET @IDCONFIGURACION = (SELECT IdEntregable FROM EN_Entregable_ConfigAdicional where IdEntregable = @IDENTREGABLE);

		IF ISNULL(@IDCONFIGURACION,0) = 0
		BEGIN

			INSERT INTO EN_Entregable_ConfigAdicional
			SELECT
				 L.IdEntregable,
				 CASE WHEN L.Desarrollo = 'SI' THEN 1 ELSE 0 END,
				 CASE WHEN L.Exploracion = 'SI' THEN 1 ELSE 0 END,
				 CASE WHEN L.Evaluacion = 'SI' THEN 1 ELSE 0 END,
				 CASE WHEN L.Transicion = 'SI' THEN 1 ELSE 0 END,
				 CASE WHEN L.AbandonoArea = 'SI' THEN 1 ELSE 0 END,
				 CASE WHEN L.AbandonoPozo = 'SI' THEN 1 ELSE 0 END
			FROM @Layout AS L
			WHERE L.IdEntregable = @IDENTREGABLE;

		END
		ELSE 
		BEGIN

			UPDATE EC
			SET EC.Desarrollo = CASE WHEN L.Desarrollo = 'SI' THEN 1 ELSE 0 END,
				 EC.Exploracion = CASE WHEN L.Exploracion = 'SI' THEN 1 ELSE 0 END,
				 EC.Evaluacion = CASE WHEN L.Evaluacion = 'SI' THEN 1 ELSE 0 END,
				 EC.Transicion = CASE WHEN L.Transicion = 'SI' THEN 1 ELSE 0 END,
				 EC.AbandonoArea = CASE WHEN L.AbandonoArea = 'SI' THEN 1 ELSE 0 END,
				 EC.AbandonoPozo = CASE WHEN L.AbandonoPozo = 'SI' THEN 1 ELSE 0 END
			FROM dbo.EN_Entregable_ConfigAdicional AS EC
			JOIN @Layout AS L ON EC.IdEntregable = L.IdEntregable
			WHERE L.IdEntregable = @IDENTREGABLE;

		END

		SET @CONT_RE_CORRECTOS = @CONT_RE_CORRECTOS + 1;

	END

	

	--CONTADOR DE CORRECTOS
	SET @CONTADORAFECTADOS = (SELECT COUNT(1) FROM @Layout AS L
							  WHERE L.IdEntregable <> '' AND
									 L.Licencia <> '' AND
									 L.ProduccionCompartida <> '' AND
									 L.TCProducionCompartidaFarmOuts <> '' AND
									 L.UGTerrestre <> '' AND
									 L.UGCostaFuera <> '' AND
									 L.REReguladores <> '' AND
									 L.APAdministracionContratos <> '' AND
									 L.APPozoAlivio <> '' AND
									 L.APCierreDesmantelamientoAbandono <> '' AND
									 L.APPerforacion <> '' AND
									 L.APTerminacion <> '' AND
									 L.APActProduccion <> '' AND
									 L.APEstimulacion <> '' AND
									 L.APConstruccionCamino <> '' AND
									 L.APConstruccionLocalizacion <> '' AND
									 L.APRehabilitacionCamino <> '' AND
									 L.APRehabilitacionLocalizacion <> '' AND
									 L.APTomaInformacionSismica <> '' AND
									 L.APCorteNucleos <> '' AND
									 L.APConstruccionLineaDescarga <> '' AND
									 L.APSistemaArtificialProduccion <> '' AND
									 L.APMedicionPozos <> '' AND
									 L.APTomaInformacionPozo <> '' AND
									 L.APReparacionMayor <> '' AND
									 L.APReparacionMenor <> '' AND
									 L.APTransporteHidrocarburos <> '' AND
									 L.APQuemaGas <> '' AND
									 L.Desarrollo <> '' AND
									 L.Exploracion <> '' AND
									 L.Evaluacion <> '' AND
									 L.Transicion <> '' AND
									 L.AbandonoArea <> '' AND
									 L.AbandonoPozo <> '');
	
	--CONTADOR DE ERRORES
	SET @CONTADORERRORES = (SELECT COUNT(1) FROM @ERROES_TABLE);

	SELECT @CONTADORERRORES AS ERRORES,
			@CONTADORAFECTADOS AS AFECTADOS,
			@ERRORES AS TEXTOERRORES
END
