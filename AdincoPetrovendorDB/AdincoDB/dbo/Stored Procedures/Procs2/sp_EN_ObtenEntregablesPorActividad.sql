-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Llama los entregables
-- =============================================
-- 11/11/2021 MC Ocultar entregables marcados como NA issue 468 entregables  
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ObtenEntregablesPorActividad] -- 3,10061,0,12108
    @idContrato INT,
    @idUsuario INT,
    @IdActividad INT,
    @idProceso INT --Para buscar Ronda
AS
BEGIN

    SET NOCOUNT ON;

        SELECT    DISTINCT ce.IdContratoEntregable, 
				   ISNULL(AE.Activo, 0) AS Activo,
                    DocumentoEntregable,
                    E.Descripcion,
                    Consecutivo,
                    Regulador,
                    ISNULL(MarcoLegal, '') AS MarcoLegal,
                    ISNULL(E.TiempoEntrega, '') AS TiempoEntrega,
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
						 --CP.Clave+' '+ CP.Nombre AS CatalogoProceso
						 '' AS CatalogoProceso
          FROM      EN_ActividadesEntregables AE
		  JOIN	
				EN_Entregable	E	
				ON AE.IdEntregable	=	E.IdEntregable
				AND AE.IdActividad	=	@IdActividad
				AND ISNULL(AE.Activo,0)	=	1
          JOIN      
				dbo.EN_ContratoEntregable CE
				ON	CE.IdContrato	=	@idContrato
				AND	E.IdEntregable	=	CE.IdEntregable
				AND ISNULL(CE.BitNA,0) <> 1
		 --LEFT JOIN 
			--	EN_CatalogoProcesosEntregables	CPE
			--	ON	CE.IdEntregable	=	CPE.IdEntregable
		 --LEFT JOIN 
			--	EN_CatalogoProcesos	CP
			--	ON	CPE.IdCatProceso	=	CP.IdCatProceso
         LEFT JOIN      
				dbo.EN_Etapa	et
				ON	E.IdEtapa	=	et.IdEtapa
          LEFT JOIN 
				CO_Regulador	R
				ON	E.IdRegulador	=	R.IdRegulador
          LEFT JOIN 
				EN_MarcoLegal	M
				ON	E.IdMarcoLegal	=	M.IdMarcoLegal
          LEFT JOIN 
				dbo.EN_FrecuenciaEntregable	FE
				ON	E.IdFrecuenciaEntregable	=	FE.IdFrecuenciaEntregable
         WHERE      
			ISNULL(E.IsEliminado, 0) = 0
			AND      (   E.IdFrecuenciaEntregable IN ( 10018, 10019, 10016, 10011, 10010, 10008, 10004, 10003, 10000 )
			OR			 E.BitInterno         = 1)
			AND			 CE.Activo            = 1
         ORDER BY 
			Activo DESC;
   
   
END;
