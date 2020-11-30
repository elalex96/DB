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
       e.TCLicencia,
       e.TCProducionCompartida,
       e.TCLicenciaFarmOuts,
       e.TCProducionCompartidaFarmOuts,
       e.UGTerrestre,
       e.UGCostaFuera,
       e.REReguladores,
       e.REOperadores,
       e.APAdministracionContratos,
       e.APPozoAlivio,
       e.APCierreDesmantelamientoAbandono,
       e.APPerforacion,
       e.APTerminacion,
       e.APActProduccion,
       e.APEstimulacion,
       e.APPruebaProduccion,
       e.APConstruccionCamino,
       e.APConstruccionLocalizacion,
       e.APRehabilitacionCamino,
       e.APRehabilitacionLocalizacion,
       e.APTomaInformacionSismica,
       e.APCorteNucleos,
       e.APConstruccionLineaDescarga,
       e.APSistemaArtificialProduccion,
       e.APMedicionPozos,
       e.APTomaInformacionPozo,
       e.APReparacionMayor,
       e.APReparacionMenor,
       e.APTransporteHidrocarburos,
       e.APQuemaGas,
       ISNULL(et.Etapa, 'Entregable Interno del Contrato') AS Etapa,
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
	WHERE @pIdEntregable IN ( 0, e.IdEntregable )
--		  AND ISNULL(e.IsEliminado, 0) = 0
	ORDER BY IdEntregable DESC;
END

