USE [Adinco]
GO

/****** Object:  UserDefinedTableType [dbo].[Entregables_Importacion_Edicion_01]    Script Date: 28/10/2021 01:11:33 p. m. ******/
CREATE TYPE [dbo].[Entregables_Importacion_Edicion_01] AS TABLE(
	[IdEntregable] [nvarchar](50) NULL,
	[Licencia] [nvarchar](10) NULL,
	[ProduccionCompartida] [nvarchar](50) NULL,
	[TCLicenciaFarmOuts] [nvarchar](50) NULL,
	[TCProducionCompartidaFarmOuts] [nvarchar](50) NULL,
	[UGTerrestre] [nvarchar](50) NULL,
	[UGCostaFuera] [nvarchar](50) NULL,
	[REReguladores] [nvarchar](50) NULL,
	[REOperadores] [nvarchar](50) NULL,
	[APAdministracionContratos] [nvarchar](10) NULL,
	[APPozoAlivio] [nvarchar](10) NULL,
	[APCierreDesmantelamientoAbandono] [nvarchar](10) NULL,
	[APPerforacion] [nvarchar](10) NULL,
	[APTerminacion] [nvarchar](10) NULL,
	[APActProduccion] [nvarchar](10) NULL,
	[APEstimulacion] [nvarchar](10) NULL,
	[APPruebaProduccion] [nvarchar](10) NULL,
	[APConstruccionCamino] [nvarchar](10) NULL,
	[APConstruccionLocalizacion] [nvarchar](10) NULL,
	[APRehabilitacionCamino] [nvarchar](10) NULL,
	[APRehabilitacionLocalizacion] [nvarchar](10) NULL,
	[APTomaInformacionSismica] [nvarchar](10) NULL,
	[APCorteNucleos] [nvarchar](10) NULL,
	[APConstruccionLineaDescarga] [nvarchar](10) NULL,
	[APSistemaArtificialProduccion] [nvarchar](10) NULL,
	[APMedicionPozos] [nvarchar](10) NULL,
	[APTomaInformacionPozo] [nvarchar](10) NULL,
	[APReparacionMayor] [nvarchar](10) NULL,
	[APReparacionMenor] [nvarchar](10) NULL,
	[APTransporteHidrocarburos] [nvarchar](10) NULL,
	[APQuemaGas] [nvarchar](10) NULL,
	[Desarrollo] [nvarchar](10) NULL,
	[Exploracion] [nvarchar](10) NULL,
	[Evaluacion] [nvarchar](10) NULL,
	[Transicion] [nvarchar](10) NULL,
	[AbandonoArea] [nvarchar](10) NULL,
	[AbandonoPozo] [nvarchar](10) NULL
)
GO


