DROP PROCEDURE IF exists p_EN_ObtenerEntregable
GO
--======================================================
-- LUIS DAVID
-- SE CONTROLA LOS NULOS PARA NO GENERAR ERROR EN LA CONSULTA
CREATE PROCEDURE [dbo].[p_EN_ObtenerEntregable]
	@pIdEntregable INT
AS
BEGIN
SELECT e.IdRegulador,
       NombreRegulador,
       e.IdFrecuenciaEntregable,
       FrecuenciaEntregable,
       e.IdEntregable,
       e.DocumentoEntregable,
	   ISNULL(e.DeliverableName,'') as DocumentoEntregableIngles,
       e.IdMarcoLegal,
       ml.MarcoLegal,
       e.TituloAnexo,
       e.Capitulo,
       e.Descripcion,
       e.Seccion,
       e.Articulo,
       e.Inciso,
       e.Apartado,
       e.Observaciones,
       e.ArchivoNormatividad,
       e.ArchivoEntregable,
       e.IdRegulador,
       e.IdEtapa,
       e.IdReceptorEntregable,
       e.IdResponsableGenerador,
       e.IdFrecuenciaEntregable,
       e.TiempoEntrega,
       e.IdTiempoRespuesta,
       e.FechaPublicacion,
       e.FechaModificacion,
       e.CreadoPor,
       e.CreadoEn,
       e.ModificadoPor,
       e.ModificadoEn,
       IsActivo = CAST(ISNULL(e.IsActivo, 0) AS BIT),
       e.IsEliminado,
       e.Consecutivo,
       ISNULL(e.TCLicencia,0) AS TCLicencia,
       ISNULL(e.TCProducionCompartida,0) AS TCProducionCompartida,
       ISNULL(e.TCLicenciaFarmOuts,0) AS TCLicenciaFarmOuts,
       ISNULL(e.TCProducionCompartidaFarmOuts,0) AS TCProducionCompartidaFarmOuts,
       ISNULL(e.UGTerrestre,0) AS UGTerrestre,
       ISNULL(e.UGCostaFuera,0) AS UGCostaFuera,
       ISNULL(e.REReguladores,0) AS REReguladores,
       ISNULL(e.REOperadores,0) AS REOperadores,
       ISNULL(e.APAdministracionContratos,0) AS APAdministracionContratos,
       ISNULL(e.APPozoAlivio,0) AS APPozoAlivio,
       ISNULL(e.APCierreDesmantelamientoAbandono,0) AS APCierreDesmantelamientoAbandono,
       ISNULL(e.APPerforacion,0) AS APPerforacion,
       ISNULL(e.APTerminacion,0) AS APTerminacion ,
       ISNULL(e.APActProduccion,0) AS APActProduccion,
       ISNULL(e.APEstimulacion,0) AS APEstimulacion,
       ISNULL(e.APPruebaProduccion,0) AS APPruebaProduccion,
       ISNULL(e.APConstruccionCamino,0) AS APConstruccionCamino,
       ISNULL(e.APConstruccionLocalizacion,0) AS APConstruccionLocalizacion,
       ISNULL(e.APRehabilitacionCamino,0) AS APRehabilitacionCamino,
       ISNULL(e.APRehabilitacionLocalizacion,0) AS APRehabilitacionLocalizacion,
       ISNULL(e.APTomaInformacionSismica,0) AS APTomaInformacionSismica,
       ISNULL(e.APCorteNucleos,0) AS APCorteNucleos,
       ISNULL(e.APConstruccionLineaDescarga,0) AS APConstruccionLineaDescarga,
       ISNULL(e.APSistemaArtificialProduccion,0) AS APSistemaArtificialProduccion,
       ISNULL(e.APMedicionPozos,0) AS APMedicionPozos,
       ISNULL(e.APTomaInformacionPozo,0) AS APTomaInformacionPozo,
       ISNULL(e.APReparacionMayor,0) AS APReparacionMayor,
       ISNULL(e.APReparacionMenor,0) AS APReparacionMenor,
       ISNULL(e.APTransporteHidrocarburos,0) AS APTransporteHidrocarburos,
       ISNULL(e.APQuemaGas,0) AS APQuemaGas,
       ISNULL(et.Etapa, 'Entregable Interno del Contrato') AS Etapa,
	   ISNULL(Desarrollo,0) AS Desarrollo,
	   ISNULL(Exploracion,0) AS Exploracion,
	   ISNULL(Evaluacion,0) AS Evaluacion,
	   ISNULL(Transicion,0) AS Transicion,
	   ISNULL(AbandonoArea,0) AS AbandonoArea,
	   ISNULL(AbandonoPozo,0) AS AbandonoPozo, 
       CASE
           WHEN APPozoAlivio = 1 THEN
               'Pozo de alivio'
           WHEN APCierreDesmantelamientoAbandono = 1 THEN
               'Abandono'
           WHEN APPerforacion = 1 THEN
               'Perforación'
           WHEN APTerminacion = 1 THEN
               'Terminación'
           WHEN APActProduccion = 1 THEN
               'Actividades de Producción'
           WHEN APEstimulacion = 1 THEN
               'Estimulación'
           WHEN APPruebaProduccion = 1 THEN
               'Prueba de Producción'
           WHEN APConstruccionCamino = 1 THEN
               'Construcción de Camino'
           WHEN APConstruccionLocalizacion = 1 THEN
               'Construcción de Localizacion'
           WHEN APTomaInformacionSismica = 1 THEN
               'Toma de Información Sísmica'
           WHEN APCorteNucleos = 1 THEN
               'Corte de Nucleos'
           WHEN APConstruccionLineaDescarga = 1 THEN
               'Construcción de Lineas de descargas'
           WHEN APSistemaArtificialProduccion = 1 THEN
               'Sistemas Artificiales de Producción'
           WHEN APTomaInformacionPozo = 1 THEN
               'Medición de Pozos'
           WHEN APReparacionMayor = 1 THEN
               'Reparación Mayor'
           WHEN APReparacionMenor = 1 THEN
               'Reparación Menor'
           WHEN APTransporteHidrocarburos = 1 THEN
               'Transporte de Hidrocarburos'
           WHEN APAdministracionContratos = 1 THEN
               'Administración de Contratos'
           WHEN APQuemaGas = 1 THEN
               'Quema de Gas'
          WHEN BitInterno = 1 THEN 'Entregable Interno'
			ELSE 'No Especificado'
       END AS ActividadPetrolera,
		Formato,
		ISNULL(NombreClasificacion,'') as  NombreClasificacion, 
		ISNULL(e.IdClasificacion ,10000) as IdClasificacion,
		CAST(ISNULL(e.RequiereRespuesta, 0) AS BIT) as RequiereRespuesta, 
		Actividad ,
		Proceso ,
		ISNULL(DFI.IdFormatoFichaTecnica,0) as Fichatecnica,--Fichatecnica
		ISNULL(DF.IdFormatoFichaTecnica,0) as FormatoArchivo--Formato,
	FROM EN_Entregable e
	INNER JOIN EN_MarcoLegal ml (NOLOCK)
		ON ml.IdMarcoLegal = e.IdMarcoLegal
		AND E.BITJOA = 0
	INNER JOIN EN_FrecuenciaEntregable (NOLOCK)
		ON e.IdFrecuenciaEntregable = EN_FrecuenciaEntregable.IdFrecuenciaEntregable
	LEFT JOIN CO_Regulador (NOLOCK)
		ON e.IdRegulador = CO_Regulador.IdRegulador
	LEFT JOIN dbo.EN_Etapa et (NOLOCK)
		ON e.IdEtapa = et.IdEtapa
	LEFT JOIN en_clasificacion c (NOLOCK)
		ON e.IdClasificacion=c.IdClasificacion
	LEFT JOIN EN_DocumentoFormatoFichaTecnica DFI (NOLOCK)
		ON e.IdEntregable=DFI.IdEntregable AND DFI.idTipoFormatoFichaTecnica=10000--FichaTecnica
	LEFT JOIN EN_DocumentoFormatoFichaTecnica DF (NOLOCK)
		ON e.IdEntregable=DF.IdEntregable AND DF.idTipoFormatoFichaTecnica=10001--Formato
	LEFT JOIN EN_Entregable_ConfigAdicional AS CA
		on e.IdEntregable = CA.IdEntregable
	WHERE @pIdEntregable IN ( 0, e.IdEntregable )
--		  AND ISNULL(e.IsEliminado, 0) = 0
	ORDER BY IdEntregable DESC;
END
