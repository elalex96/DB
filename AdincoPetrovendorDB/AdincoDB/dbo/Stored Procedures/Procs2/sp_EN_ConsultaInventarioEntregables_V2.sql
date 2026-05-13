CREATE PROCEDURE dbo.sp_EN_ConsultaInventarioEntregables_V2
    @IdContrato INT,
    @IdUsuario INT,
    @ResponsableGenerador INT = 0,
    @ActividadPetrolera INT = 0
AS
BEGIN
-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:
-- =============================================
-- Modificación Author:		Reyna O.
-- Modificación día: 	24-01-2019
-- Modificación descripcion: Se añadio Join a contratoEntregable, Rondas y contrato, para ver solamente los 
--	entregables vigentes para ese contrato
-- Se quito Substring del campo 'DocumentoEntregable' para que el usuario pueda visualizar todo el texto
-- =============================================
-- Modificacion R. Portales 
-- Se agregó una tabla temporal la cual almacena cada uno de los dos resultados posibles contenidos dentro del if principal, al final solo se exluyen 
-- aquellos registros que no son requeridos si es que se solicitan los registors Terrestres o costa afuera
-- =============================================
-- 20190430		BAAC	Se optimiza para evitar los ifs
-- =============================================

SET NOCOUNT ON
-- =============================================

CREATE TABLE	#tmp
(
	IdRonda									int,			IdContratoEntregable					int,
	IdEntregable							int,			Consecutivo								varchar(6000),
	Regulador								varchar(6000),	MarcoLegal								varchar(6000),
	Articulo								varchar(6000),	DocumentoEntregable						varchar(6000),
	Etapa									varchar(6000),	ReceptorEntregable						varchar(6000),
	ResponsableGenerador					varchar(6000),	FrecuenciaEntregable					varchar(6000),
	TiempoEntrega							varchar(6000),	TiempoRespuesta							varchar(6000),
	ReguladorOperador						varchar(6000),	REReguladores							int,
	REOperadores							int,			APAdministracionContratos				int,
	APPozoAlivio							int,			APCierreDesmantelamientoAbandono		int,
	APPerforacion							int,			APTerminacion							int,
	APActProduccion							int,			APEstimulacion							int,
	APPruebaProduccion						int,			APConstruccionCamino					int,
	APConstruccionLocalizacion				int,			APRehabilitacionCamino					int,
	APRehabilitacionLocalizacion			int,			APTomaInformacionSismica				int,
	APCorteNucleos							int,			APConstruccionLineaDescarga				int,
	APSistemaArtificialProduccion			int,			APMedicionPozos							int,
	APTomaInformacionPozo					int,			APReparacionMayor						int,
	APReparacionMenor						int,			APTransporteHidrocarburos				int,
	APQuemaGas								int,			TituloAnexo								varchar(6000),
	Capitulo								varchar(6000),	UGTerrestre								int,
	UGCostaFuera							int
	PRIMARY KEY (IdEntregable)
)

DECLARE
	@IdRonda	INT,
	@Licencia	INT,
	@ProduccionCompartida INT,
	@UGTerreste	INT,
	@UGCostaFuera	INT,
	@REReguladores INT = 0,
	@REOperadores INT = 0
--Actividad Petrolera
--TipoContrato
--2	Producción Compartida
--3	Licencia

SELECT
	@UGTerreste	=	CASE WHEN AC.IdUbicacionAC = 10000 THEN 1 ELSE 0 END,
	@UGCostaFuera		=	CASE WHEN AC.IdUbicacionAC <> 10000 THEN 1 ELSE 0 END,
	@IdRonda	=	C.IdRonda,
	@Licencia	=	CASE WHEN C.IdTipoContrato = 3 THEN 1 ELSE 0 END,
	@ProduccionCompartida	= CASE WHEN C.IdTipoContrato = 2 THEN 1 ELSE 0 END,
	@REReguladores	=	CASE WHEN @ResponsableGenerador = 2 THEN 1 ELSE 0 END,
	@REOperadores	=	CASE WHEN @ResponsableGenerador = 1 THEN 1 ELSE 0 END
FROM
	dbo.CO_Contrato C
JOIN
	dbo.CO_AreaContractual	AC
	ON C.IdAreaContractual = AC.IdAreaContractual
	AND C.IdContrato = @IdContrato
--WHERE
--	C.IdContrato = @IdContrato

IF @IdContrato = 3
BEGIN
-- SE QUITAN VALIDACIONES PARA MOSTRAR TODOS LOS ENTREGABLS EN EL CONTRATO MEXICO
	INSERT INTO #tmp
	SELECT      
		0 AS idRonda,
		0 as IdContratoEntregable,
		EN.IdEntregable,
		EN.Consecutivo,
		R.Regulador,
		ML.MarcoLegal AS MarcoLegal,
		SUBSTRING(EN.Articulo,0,1000) AS Articulo,
		EN.DocumentoEntregable AS DocumentoEntregable,
		ET.Etapa,
		RE.ReceptorEntregable,
		RG.ResponsableGenerador,
		FE.FrecuenciaEntregable,
		SUBSTRING(EN.TiempoEntrega, 0, 120) AS TiempoEntrega,
		TR.TiempoRespuesta,
		CASE
			WHEN EN.REReguladores = 1 THEN 'Regulador'
			ELSE 'Operador' 
		END AS ReguladorOperador,
		EN.REReguladores,
		EN.REOperadores,
		EN.APAdministracionContratos,
		EN.APPozoAlivio,
		EN.APCierreDesmantelamientoAbandono,
		EN.APPerforacion,
		EN.APTerminacion,
		EN.APActProduccion,
		EN.APEstimulacion,
		EN.APPruebaProduccion,
		EN.APConstruccionCamino,
		EN.APConstruccionLocalizacion,
		EN.APRehabilitacionCamino,
		EN.APRehabilitacionLocalizacion,
		EN.APTomaInformacionSismica,
		EN.APCorteNucleos,
		EN.APConstruccionLineaDescarga,
		EN.APSistemaArtificialProduccion,
		EN.APMedicionPozos,
		EN.APTomaInformacionPozo,
		EN.APReparacionMayor,
		EN.APReparacionMenor,
		EN.APTransporteHidrocarburos,
		EN.APQuemaGas,
		EN.TituloAnexo AS TituloAnexo,
		EN.Capitulo AS Capitulo,
		EN.UGTerrestre,
		EN.UGCostaFuera
	FROM
		EN_Entregable AS EN
	--JOIN
	--	EN_EntregableRonda ER
	--	ON ER.idRonda	=	@IdRonda
	--	AND EN.IdEntregable	=	ER.idEntregable
	LEFT JOIN
		EN_MarcoLegal AS ML
		ON ML.IdMarcoLegal           = EN.IdMarcoLegal
	LEFT JOIN
		CO_Regulador AS R
		ON R.IdRegulador             = EN.IdRegulador
	LEFT JOIN
		EN_ReceptorEntregable AS RE
		ON RE.IdReceptorEntregable   = EN.IdReceptorEntregable
	LEFT JOIN
		EN_ResponsableGenerador AS RG
		ON RG.IdResponsableGenerador = EN.IdResponsableGenerador
	LEFT JOIN
		EN_FrecuenciaEntregable AS FE
		ON FE.IdFrecuenciaEntregable = EN.IdFrecuenciaEntregable
	LEFT JOIN
		EN_TiempoRespuesta AS TR
		ON EN.IdTiempoRespuesta      = TR.IdTiempoRespuesta
	LEFT JOIN
		EN_Etapa AS ET
		ON ET.IdEtapa               = EN.IdEtapa
	WHERE
		EN.REReguladores	>=	@REReguladores
		AND EN.REOperadores		>=	@REOperadores
		AND	ISNULL(EN.IsEliminado, 0) = 0
		AND EN.BITJOA = 0
	ORDER BY EN.IdEntregable

END
ELSE
BEGIN

	INSERT INTO #tmp
	SELECT      
		ER.idRonda,
		0 as IdContratoEntregable,
		EN.IdEntregable,
		EN.Consecutivo,
		R.Regulador,
		ML.MarcoLegal AS MarcoLegal,
		SUBSTRING(EN.Articulo,0,500) AS Articulo,
		EN.DocumentoEntregable AS DocumentoEntregable,
		ET.Etapa,
		RE.ReceptorEntregable,
		RG.ResponsableGenerador,
		FE.FrecuenciaEntregable,
		SUBSTRING(EN.TiempoEntrega, 0, 120) AS TiempoEntrega,
		TR.TiempoRespuesta,
		CASE
			WHEN EN.REReguladores = 1 THEN 'Regulador'
			ELSE 'Operador' 
		END AS ReguladorOperador,
		EN.REReguladores,
		EN.REOperadores,
		EN.APAdministracionContratos,
		EN.APPozoAlivio,
		EN.APCierreDesmantelamientoAbandono,
		EN.APPerforacion,
		EN.APTerminacion,
		EN.APActProduccion,
		EN.APEstimulacion,
		EN.APPruebaProduccion,
		EN.APConstruccionCamino,
		EN.APConstruccionLocalizacion,
		EN.APRehabilitacionCamino,
		EN.APRehabilitacionLocalizacion,
		EN.APTomaInformacionSismica,
		EN.APCorteNucleos,
		EN.APConstruccionLineaDescarga,
		EN.APSistemaArtificialProduccion,
		EN.APMedicionPozos,
		EN.APTomaInformacionPozo,
		EN.APReparacionMayor,
		EN.APReparacionMenor,
		EN.APTransporteHidrocarburos,
		EN.APQuemaGas,
		EN.TituloAnexo AS TituloAnexo,
		EN.Capitulo AS Capitulo,
		EN.UGTerrestre,
		EN.UGCostaFuera
	FROM
		EN_Entregable AS EN
	JOIN
		EN_EntregableRonda ER
		ON ER.idRonda	=	@IdRonda
		AND EN.IdEntregable	=	ER.idEntregable
		AND	EN.TCProducionCompartida	>=	@ProduccionCompartida
		AND EN.UGTerrestre		>=	@UGTerreste
		AND EN.UGCostaFuera		>=	@UGCostaFuera
		AND EN.REReguladores	>=	@REReguladores
		AND EN.REOperadores		>=	@REOperadores
		AND	ISNULL(EN.IsEliminado, 0) = 0
		AND EN.BITJOA = 0
		AND EN.TCLicencia			>= @Licencia
		AND EN.BitInterno = 0
	LEFT JOIN
		EN_MarcoLegal AS ML
		ON ML.IdMarcoLegal           = EN.IdMarcoLegal
	LEFT JOIN
		CO_Regulador AS R
		ON R.IdRegulador             = EN.IdRegulador
	LEFT JOIN
		EN_ReceptorEntregable AS RE
		ON RE.IdReceptorEntregable   = EN.IdReceptorEntregable
	LEFT JOIN
		EN_ResponsableGenerador AS RG
		ON RG.IdResponsableGenerador = EN.IdResponsableGenerador
	LEFT JOIN
		EN_FrecuenciaEntregable AS FE
		ON FE.IdFrecuenciaEntregable = EN.IdFrecuenciaEntregable
	LEFT JOIN
		EN_TiempoRespuesta AS TR
		ON EN.IdTiempoRespuesta      = TR.IdTiempoRespuesta
	LEFT JOIN
		EN_Etapa AS ET
		ON ET.IdEtapa               = EN.IdEtapa
--	WHERE
	ORDER BY
		EN.IdEntregable
END

/*
--Determinar Actividad Petrolera
--1		Pozo de alivio
--2		Abandono
--3		Perforación
--4		Terminación
--5		Actividades de Producción
--6		Estimulación
--7		Prueba de Producción
--8		Construcción de Camino
--9		Construcción de Local
izac
ion
--10	Reabilitación de Camino
--11	Reabilitación de Localización
--12	Toma de Información Sísmica
--13	Corte de Nucleos
--14	Construcción de Lineas de descargas
--15	Sistemas Artificiales de Producción
--16	Medición de Pozos
--17	Toma de Información en

 Pozos
--18	Reparación Mayor
--19	Reparación Menor
--20	Transporte de Hidrocarburos
--21	Administración de Contratos
--22	Quema de Gas
--23	Todos
*/

    IF @ActividadPetrolera = 1
    BEGIN
		DELETE #tmp WHERE APPozoAlivio = 0
    END
    
	IF @ActividadPetrolera = 2
    BEGIN
        DELETE #tmp WHERE APCierreDesmantelamientoAbandono = 0
    END
    
	IF @ActividadPetrolera = 3
    BEGIN
        DELETE #tmp WHERE APPerforacion = 0
    END

    IF @ActividadPetrolera = 4
    BEGIN
		DELETE #tmp WHERE APTerminacion = 0
    END

    IF @ActividadPetrolera = 5
    BEGIN
		DELETE #tmp WHERE APActProduccion = 0
    END
    
	IF @ActividadPetrolera = 6
    BEGIN
		DELETE #tmp WHERE APEstimulacion = 0
    END
    
	IF @ActividadPetrolera = 7
    BEGIN
		DELETE #tmp WHERE APPruebaProduccion = 0
    END

    IF @ActividadPetrolera = 8
    BEGIN
		DELETE #tmp WHERE APConstruccionCamino = 0
    END
    
	IF @ActividadPetrolera = 9
    BEGIN
		DELETE #tmp WHERE APConstruccionLocalizacion = 0
    END

    IF @ActividadPetrolera = 10
    BEGIN
		DELETE #tmp WHERE APRehabilitacionCamino = 0
    END

    IF @ActividadPetrolera = 11
    BEGIN
		DELETE #tmp WHERE APRehabilitacionLocalizacion  = 0
    END

    IF @ActividadPetrolera = 12
    BEGIN
		DELETE #tmp WHERE APTomaInformacionSismica = 0
	END
    
	IF @ActividadPetrolera = 13
    BEGIN
	
	DELETE #tmp WHERE APCorteNucleos = 0
    END

    IF @ActividadPetrolera = 14
    BEGIN
		DELETE #tmp WHERE APConstruccionLineaDescarga = 0
    END

    IF @ActividadPetrolera = 15
    BEGIN
		DELETE #tmp WHERE APSistemaArtificialProduccion = 0
    END
 
 	IF @ActividadPetrolera = 16
    BEGIN
		DELETE #tmp WHERE APMedicionPozos = 0
    END

    IF @ActividadPetrolera = 17
    BEGIN
		DELETE #tmp WHERE APTomaInformacionPozo = 0
    END
    
	IF @ActividadPetrolera = 18
    BEGIN
		DELETE #tmp WHERE APReparacionMayor = 0
    END
    
	IF @ActividadPetrolera = 19
    BEGIN
		DELETE #tmp WHERE APReparacionMenor = 0
    END
    
	IF @ActividadPetrolera = 20
    BEGIN
		DELETE #tmp WHERE APTransporteHidrocarburos = 0
    END
    
	IF @ActividadPetrolera = 21
	BEGIN
		DELETE #tmp WHERE APAdministracionContratos = 0
    END
    
	IF @ActividadPetrolera = 22
    BEGIN
		DELETE #tmp WHERE APQuemaGas = 0
    END

   	SELECT
		IdRonda,
		IdContratoEntregable,
		IdEntregable,
		Consecutivo,
		Regulador,
		MarcoLegal,
		Articulo,
		DocumentoEntregable,
		Etapa,
		ReceptorEntregable,
		ResponsableGenerador,
		FrecuenciaEntregable,
		TiempoEntrega,
		TiempoRespuesta,
		ReguladorOperador,
		TituloAnexo,
		Capitulo
	FROM
		#tmp
	ORDER BY DocumentoEntregable
END