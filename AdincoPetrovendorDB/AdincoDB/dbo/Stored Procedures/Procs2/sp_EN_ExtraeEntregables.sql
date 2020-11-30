-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Llama los entregables
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeEntregables]  --3,10061,0,12108
    @idContrato INT,
    @idUsuario INT,
    @IdActividad INT, -- NUEVO
    @idProceso INT --Para buscar Ronda
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @IsProcesoEvento INT;
    SELECT @IsProcesoEvento = IsProcesoEvento
      FROM dbo.EN_Procesos
     WHERE IdProceso = @idProceso;


    IF (@IsProcesoEvento = 1)
    BEGIN
        SELECT    DISTINCT ce.IdContratoEntregable, 
                    E.IdEntregable,
					 ISNULL(AE.Activo, 0) AS Activo,
                    DocumentoEntregable,
                    E.Descripcion,
                    AE.IdActividad,
                    Consecutivo,
                    Regulador,
                    ISNULL(MarcoLegal, '') AS MarcoLegal,
                    ER.idRonda,
                    PR.IdRonda,
                    ISNULL(E.TiempoEntrega, '') AS TiempoEntrega,
                    Ro.Ronda AS RondaE,
                    ISNULL(FE.FrecuenciaEntregable, 'Entregable Interno del Contrato') AS FrecuenciaEntregable,
                    ISNULL(et.Etapa,'Entregable Interno del Contrato') AS Etapa,
                    CASE
                         WHEN APPozoAlivio = 1 THEN 'Pozo de alivio'
                         WHEN APCierreDesmantelamientoAbandono = 1 THEN 'Abandono'
                         WHEN APPerforacion = 1 THEN 'Perforación'
                         WHEN APTerminacion = 1 THEN 'Terminación'
                         WHEN APActProduccion = 1 THEN 'Actividades de Producción'
                         WHEN APEstimulacion = 1 THEN 'Estimulación'
                         WHEN APPruebaProduccion = 1 THEN 'Prueba de Producción'
                         WHEN APConstruccionCamino = 1 THEN 'Construcción de Camino'
                         WHEN APConstruccionLocalizacion = 1 THEN 'Construcción de Localizacion'
                         WHEN APTomaInformacionSismica = 1 THEN 'Toma de Información Sísmica'
                         WHEN APCorteNucleos = 1 THEN 'Corte de Nucleos'
                         WHEN APConstruccionLineaDescarga = 1 THEN 'Construcción de Lineas de descargas'
                         WHEN APSistemaArtificialProduccion = 1 THEN 'Sistemas Artificiales de Producción'
                         WHEN APTomaInformacionPozo = 1 THEN 'Medición de Pozos'
                         WHEN APReparacionMayor = 1 THEN 'Reparación Mayor'
                         WHEN APReparacionMenor = 1 THEN 'Reparación Menor'
                         WHEN APTransporteHidrocarburos = 1 THEN 'Transporte de Hidrocarburos'
                         WHEN APAdministracionContratos = 1 THEN 'Administración de Contratos'
                         WHEN APQuemaGas = 1 THEN 'Quema de Gas'
						 WHEN BitInterno = 1 THEN 'Entregable Interno'
                         ELSE 'No Especificado' END AS ActividadPetrolera,
						 CP.Clave+' '+ CP.Nombre AS CatalogoProceso
          FROM      EN_Entregable E
          LEFT JOIN EN_ActividadesEntregables AE
            ON E.IdEntregable           = AE.IdEntregable
           AND AE.IdActividad           = @IdActividad
          JOIN      dbo.EN_ProcesosRondas PR
            ON PR.IdProceso             = @idProceso
          JOIN      EN_EntregableRonda ER
            ON PR.IdRonda               = ER.idRonda
           AND E.IdEntregable           = ER.idEntregable
          JOIN      dbo.EN_Rondas Ro
            ON ER.idRonda               = Ro.idRonda
          JOIN      dbo.CO_Contrato C
            ON C.IdContrato             = @idContrato
           AND ER.idRonda               = C.IdRonda
          JOIN      dbo.EN_ContratoEntregable CE
            ON C.IdContrato             = CE.IdContrato
           AND ER.idEntregable          = CE.IdEntregable
		 LEFT JOIN EN_CatalogoProcesosEntregables CPE
			ON CE.IdEntregable			=CPE.IdEntregable
		 LEFT JOIN EN_CatalogoProcesos CP
			ON CPE.IdCatProceso			=CP.IdCatProceso
         LEFT JOIN      dbo.EN_Etapa et
            ON E.IdEtapa                = et.IdEtapa
          LEFT JOIN CO_Regulador R
            ON E.IdRegulador            = R.IdRegulador
          LEFT JOIN EN_MarcoLegal M
            ON E.IdMarcoLegal           = M.IdMarcoLegal
          LEFT JOIN dbo.EN_FrecuenciaEntregable FE
            ON E.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable
         WHERE      ISNULL(E.IsEliminado, 0) = 0
           AND      (   E.IdFrecuenciaEntregable IN ( 10018, 10016, 10011, 10010, 10008, 10004, 10003, 10000 ))
           AND      CE.Activo                = 1
         ORDER BY Activo DESC;

    END;
    ELSE
    BEGIN
        SELECT      DISTINCT ce.IdContratoEntregable, 
							E.IdEntregable,
                             ISNULL(AE.Activo, 0) AS Activo,
                             DocumentoEntregable,
                             E.Descripcion,
                             AE.IdActividad,
                             Consecutivo,
                             Regulador,
                             ISNULL(MarcoLegal, '') AS MarcoLegal,
                             ER.idRonda,
                             PR.IdRonda,
                             ISNULL(E.TiempoEntrega, '') AS TiempoEntrega,
                             Ro.Ronda AS RondaE,
                             ISNULL(FE.FrecuenciaEntregable, 'Entregable Interno del Contrato') AS FrecuenciaEntregable,
                             ISNULL(et.Etapa,'Entregable Interno del Contrato')AS Etapa,
							 	CASE 
					WHEN APPozoAlivio=1
					THEN 'Pozo de alivio'
					WHEN APCierreDesmantelamientoAbandono=1
					THEN 'Abandono'
					WHEN APPerforacion=1
					THEN 'Perforación'
					WHEN APTerminacion=1
					THEN 'Terminación'
					WHEN APActProduccion=1
					THEN 'Actividades de Producción'
					WHEN APEstimulacion=1
					THEN 'Estimulación'
					WHEN APPruebaProduccion=1
					THEN 'Prueba de Producción'
					WHEN APConstruccionCamino=1
					THEN 'Construcción de Camino'
					WHEN APConstruccionLocalizacion=1
					THEN 'Construcción de Localizacion'
					WHEN APTomaInformacionSismica=1
                    THEN 'Toma de Información Sísmica'
					WHEN APCorteNucleos=1
					THEN 'Corte de Nucleos'
                    WHEN APConstruccionLineaDescarga=1
                    THEN 'Construcción de Lineas de descargas'
					
                    WHEN APSistemaArtificialProduccion=1
                    THEN 'Sistemas Artificiales de Producción'
					
					WHEN APTomaInformacionPozo=1
                    THEN 'Medición de Pozos'
					WHEN APReparacionMayor=1
                    THEN 'Reparación Mayor'
					 WHEN APReparacionMenor=1
                    THEN 'Reparación Menor'
					WHEN APTransporteHidrocarburos=1
                    THEN 'Transporte de Hidrocarburos'
					WHEN APAdministracionContratos=1
                    THEN 'Administración de Contratos'
					 WHEN APQuemaGas=1
                    THEN 'Quema de Gas'
					WHEN BitInterno = 1 THEN 'Entregable Interno'
                    ELSE 'No Especificado' END AS ActividadPetrolera,
					CP.Clave+' '+ CP.Nombre AS CatalogoProceso
          FROM      EN_Entregable E
          LEFT JOIN EN_ActividadesEntregables AE
            ON E.IdEntregable           = AE.IdEntregable
           AND AE.IdActividad           = @IdActividad
          JOIN      dbo.EN_ProcesosRondas PR
            ON PR.IdProceso             = @idProceso
          JOIN      EN_EntregableRonda ER
            ON PR.IdRonda               = ER.idRonda
           AND E.IdEntregable           = ER.idEntregable
          JOIN      dbo.EN_Rondas Ro
            ON ER.idRonda               = Ro.idRonda
          JOIN      dbo.CO_Contrato C
           ON C.IdContrato             = @idContrato
           AND ER.idRonda               = C.IdRonda
          JOIN      dbo.EN_ContratoEntregable CE
			ON C.IdContrato             = CE.IdContrato
           AND ER.idEntregable          = CE.IdEntregable
		 LEFT JOIN EN_CatalogoProcesosEntregables CPE
			ON CE.IdEntregable			=CPE.IdEntregable
		 LEFT JOIN EN_CatalogoProcesos CP
			ON CPE.IdCatProceso			=CP.IdCatProceso
         LEFT JOIN      dbo.EN_Etapa et
            ON E.IdEtapa                = et.IdEtapa
          LEFT JOIN CO_Regulador R
            ON E.IdRegulador            = R.IdRegulador
          LEFT JOIN EN_MarcoLegal M
            ON E.IdMarcoLegal           = M.IdMarcoLegal
          LEFT JOIN dbo.EN_FrecuenciaEntregable FE
            ON E.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable
         WHERE      ISNULL(E.IsEliminado, 0) = 0
           AND      (   E.IdFrecuenciaEntregable NOT IN ( 10018, 10019, 10016, 10011, 10010, 10008, 10004, 10003, 10000 )
                   OR   E.BitInterno              = 1)
           AND      CE.Activo                     = 1
         ORDER BY Activo DESC;
    END;
END;




