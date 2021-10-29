USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_EN_ConsultaEntregablesMarcoLegal]    Script Date: 28/10/2021 01:09:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 26/10/2021
-- Description:	Consulta de entregables para importacion por marco legal
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ConsultaEntregablesMarcoLegal]
	-- Add the parameters for the stored procedure here
	@IdContrato INT,
	@IdMarcoLegal INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT --Top 40
		E.IdEntregable,
		E.Consecutivo,
		E.DocumentoEntregable,
		ML.MarcoLegal,
		E.Articulo,
		CASE WHEN E.TCLicencia = 1 THEN 'SI' ELSE 'NO' END AS Licencia,
		CASE WHEN E.TCProducionCompartida = 1 THEN 'SI' ELSE 'NO' END AS ProduccionCompartida,
		CASE WHEN E.TCLicenciaFarmOuts = 1 THEN 'SI' ELSE 'NO' END,
		CASE WHEN E.TCProducionCompartidaFarmOuts = 1 THEN 'SI' ELSE 'NO' END AS TCProducionCompartidaFarmOuts,
		CASE WHEN E.UGTerrestre = 1 THEN 'SI' ELSE 'NO' END AS UGTerrestre,
		CASE WHEN E.UGCostaFuera = 1 THEN 'SI' ELSE 'NO' END AS UGCostaFuera,
		CASE WHEN E.REReguladores = 1 THEN 'SI' ELSE 'NO' END AS REReguladores,
		CASE WHEN E.REOperadores = 1 THEN 'SI' ELSE 'NO' END AS REOperadores,
		CASE WHEN E.APAdministracionContratos = 1 THEN 'SI' ELSE 'NO' END AS APAdministracionContratos,
		CASE WHEN E.APPozoAlivio = 1 THEN 'SI' ELSE 'NO' END AS APPozoAlivio,
		CASE WHEN E.APCierreDesmantelamientoAbandono = 1 THEN 'SI' ELSE 'NO' END AS APCierreDesmantelamientoAbandono,
		CASE WHEN E.APPerforacion = 1 THEN 'SI' ELSE 'NO' END AS APPerforacion,
		CASE WHEN E.APTerminacion = 1 THEN 'SI' ELSE 'NO' END AS APTerminacion,
		CASE WHEN E.APActProduccion = 1 THEN 'SI' ELSE 'NO' END AS APActProduccion,
		CASE WHEN E.APEstimulacion = 1 THEN 'SI' ELSE 'NO' END AS APEstimulacion,
		CASE WHEN E.APPruebaProduccion = 1 THEN 'SI' ELSE 'NO' END AS APPruebaProduccion,
		CASE WHEN E.APConstruccionCamino = 1 THEN 'SI' ELSE 'NO' END AS APConstruccionCamino,
		CASE WHEN E.APConstruccionLocalizacion = 1 THEN 'SI' ELSE 'NO' END AS APConstruccionLocalizacion,
		CASE WHEN E.APRehabilitacionCamino = 1 THEN 'SI' ELSE 'NO' END AS APRehabilitacionCamino,
		CASE WHEN E.APRehabilitacionLocalizacion = 1 THEN 'SI' ELSE 'NO' END AS APRehabilitacionLocalizacion,
		CASE WHEN E.APTomaInformacionSismica = 1 THEN 'SI' ELSE 'NO' END AS APTomaInformacionSismica,
		CASE WHEN E.APCorteNucleos = 1 THEN 'SI' ELSE 'NO' END AS APCorteNucleos,
		CASE WHEN E.APConstruccionLineaDescarga = 1 THEN 'SI' ELSE 'NO' END AS APConstruccionLineaDescarga,
		CASE WHEN E.APSistemaArtificialProduccion = 1 THEN 'SI' ELSE 'NO' END AS APSistemaArtificialProduccion,
		CASE WHEN E.APMedicionPozos = 1 THEN 'SI' ELSE 'NO' END AS APMedicionPozos,
		CASE WHEN E.APTomaInformacionPozo = 1 THEN 'SI' ELSE 'NO' END AS APTomaInformacionPozo,
		CASE WHEN E.APReparacionMayor = 1 THEN 'SI' ELSE 'NO' END AS APReparacionMayor,
		CASE WHEN E.APReparacionMenor = 1 THEN 'SI' ELSE 'NO' END AS APReparacionMenor,
		CASE WHEN E.APTransporteHidrocarburos = 1 THEN 'SI' ELSE 'NO' END AS APTransporteHidrocarburos,
		CASE WHEN E.APQuemaGas = 1 THEN 'SI' ELSE 'NO' END AS APTransporteHidrocarburos,
		CASE WHEN ECA.Desarrollo = 1 THEN 'SI' ELSE 'NO' END AS Desarrollo,
		CASE WHEN ECA.Exploracion = 1 THEN 'SI' ELSE 'NO' END AS Exploracion,
		CASE WHEN ECA.Evaluacion = 1 THEN 'SI' ELSE 'NO' END AS Evaluacion,
		CASE WHEN ECA.Transicion = 1 THEN 'SI' ELSE 'NO' END AS Transicion,
		CASE WHEN ECA.AbandonoArea = 1 THEN 'SI' ELSE 'NO' END AS AbandonoArea,
		CASE WHEN ECA.AbandonoPozo = 1 THEN 'SI' ELSE 'NO' END AS AbandonoPozo
	FROM dbo.EN_Entregable AS E	
		JOIN dbo.EN_ContratoEntregable AS CE ON E.IdEntregable = CE.IdEntregable AND CE.IdContrato = @IdContrato
		JOIN dbo.EN_MarcoLegal AS ML ON E.IdMarcoLegal = ML.IdMarcoLegal AND ML.IdMarcoLegal = @IdMarcoLegal
		JOIN dbo.EN_Entregable_ConfigAdicional AS ECA ON E.IdEntregable = ECA.IdEntregable

END
