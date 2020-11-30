CREATE PROCEDURE [dbo].[sp_EN_ConsultaResponsablesEntregables]--3,10061,1,0,0,1
    @IdContrato INT,
    @IdUsuario INT,
    @Activo INT,
    @BitPantallaArea INT,
    @BitProcesos INT,
    @BitTodos INT
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 
-- Description:	
-- =============================================
-- 20200117	BAAC	Se modifica para agregar las columnas que pidio Shell
-- =============================================
    SET NOCOUNT ON;

    CREATE TABLE #Areas
    (
        ID INT IDENTITY(1, 1),
        Area NVARCHAR(150)
    );

	CREATE TABLE #RelacionadosMostrar
	(
		IdRelacion		INT,
		IdEntregable	INT,
		Consecutivo		VARCHAR(60),
		Relacionados	VARCHAR(1500),
		PRIMARY KEY (IdRelacion, IdEntregable)
	)

	CREATE TABLE #RelacionadosNOMostrar
	(
		IdRelacion	INT,
		IdEntregable	INT,
		Consecutivo		VARCHAR(60),
		PRIMARY KEY (IdRelacion, IdEntregable)
	)

	CREATE TABLE #EntregablesConcat
	(
		IdRelacion	INT,
		Entregables	VARCHAR(1500)
	)

	INSERT INTO #RelacionadosMostrar
	(
		IdRelacion,
		IdEntregable
	)
	SELECT
		ER.IdRelacion,
		MIN(ER.idEntregable)
	FROM
		EN_EntregablesRelacionados	ER	(NOLOCK)
	JOIN
		EN_Entregable	E	(NOLOCK)
		ON	ER.IdEntregable	=	E.idEntregable
		AND E.BITJOA = 0
		AND ISNULL(E.IsEliminado, 0) = 0
		AND ER.Activo = 1
	JOIN
		CO_Contrato C
         ON C.IdContrato =	@IdContrato
    JOIN
		EN_EntregableRonda RONDA
        ON C.IdRonda = RONDA.idRonda
        AND E.IdEntregable = RONDA.idEntregable
	GROUP BY
		ER.IdRelacion

	UPDATE	RM
		SET	Consecutivo	=	E.Consecutivo
	FROM
		#RelacionadosMostrar	RM
	JOIN
		EN_Entregable	E
		ON	RM.IdEntregable	=	E.IdEntregable

	INSERT INTO #RelacionadosNOMostrar
	(
		IdRelacion,
		IdEntregable,
		Consecutivo
	)
	SELECT
		ER.IdRelacion,
		ER.IdEntregable,
		E.Consecutivo
	FROM
		EN_EntregablesRelacionados	ER	(NOLOCK)
	JOIN
		EN_Entregable	E	(NOLOCK)
		ON	ER.IdEntregable	=	E.idEntregable
		AND ISNULL(E.IsEliminado, 0) = 0
		AND		ER.Activo = 1
	JOIN
		CO_Contrato C
        ON C.IdContrato =	@IdContrato
    JOIN
		EN_EntregableRonda RONDA
        ON C.IdRonda = RONDA.idRonda
        AND E.IdEntregable = RONDA.idEntregable
	LEFT JOIN
		#RelacionadosMostrar	EM
		ON	ER.IdRelacion	=	EM.IdRelacion
		AND	ER.IdEntregable	=	EM.IdEntregable
	WHERE
		EM.IdEntregable	IS NULL

	INSERT INTO #EntregablesConcat
	(
		IdRelacion,
		Entregables
	)
	SELECT
		IdRelacion,
		STUFF(( SELECT  ', '+ Consecutivo FROM #RelacionadosNOMostrar A
				WHERE B.IdRelacion = A.IdRelacion FOR XML PATH('')),1 ,1, '')  Members
	FROM
		#RelacionadosNOMostrar B
	GROUP BY
		IdRelacion

	UPDATE M
		SET Relacionados	=	LTRIM(RTRIM(C.Entregables))
	FROM
		#RelacionadosMostrar	M
	JOIN
		#EntregablesConcat	C
		ON	M.IdRelacion	=	C.IdRelacion


    IF (@BitPantallaArea = 0) --Administracion
    BEGIN
        IF (@BitProcesos = 0 AND @BitTodos = 0)
        BEGIN

			SELECT CE.IdContratoEntregable,
                   CE.IdContrato,
                   ISNULL(FE.FrecuenciaEntregable, '') AS FrecuenciaEntregable,
					CASE WHEN 	ISNULL(EM.Relacionados,'') <> ''
						THEN LTRIM(RTRIM(EN.Consecutivo)) + ' Relacionados: ' + EM.Relacionados
					ELSE	EN.Consecutivo	END	AS	Consecutivo,
                   ISNULL(ML.MarcoLegal, '') AS MarcoLegal,
                   CE.IdEntregable,
                   ISNULL(are.NombreArea, '') AS AreaResponsable, --CE.AreaResponsable,
                   CE.FechaLimiteEntrega,
                   CE.DiasElaboracion,
                   CE.DiasRevision,
                   CE.DiasAprobacion,
                   CE.DiasAlerta,
                   CE.ReceptorAlerta,
                   CE.CreadoPor,
                   CE.CreadoEl,
                   CE.ModificadoPor,
                   CE.ModificadoEl,
                   ISNULL(CE.Activo, 0) AS Activo,
                   CE.FechaLimiteEntregaRegulador,
				   LTRIM(COUNT(DISTINCT AE.ActividadID)) + ' - ' + LTRIM(COUNT(DISTINCT AR.ActividadID)) + ' - '
                   + LTRIM(COUNT(DISTINCT AP.ActividadID)) AS Configuracion,
                   ISNULL(R.ReceptorEntregable, '') AS ReceptorEntregable,
                   ISNULL(EN.Descripcion, '') AS Descripcion,
                   ISNULL(UE.Nombre, '') AS usuarioElaborador,
                   dbo.fnGetRevisoresEntregable(AE.IdContratoEntregable) AS UsuariosRevisores,
                   ISNULL(UA.Nombre, '') AS usuarioAprobador,
					CASE
                       WHEN APPozoAlivio = 1 THEN	'Pozo de alivio'
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
                       ELSE 'No Especificado'
                   END AS ActividadPetrolera,
                   ISNULL(et.Etapa, 'No Especificada') AS Etapa,
				   ISNULL(CE.Subfuncion,'') AS Subfuncion,
				   CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')
						ELSE ISNULL(FP.Nombre,'') --+ ' (' + CE.FocalPoint + ')'
					END		AS FocalPoint,
					CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
						ELSE ISNULL(AC.Nombre,'') --+ ' (' + CE.AccountableCompliance + ')'
					END		AS AccountableCompliance,
					CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
						ELSE ISNULL(ACC.Nombre,'') --+ ' (' + CE.Accountable + ')'
					END		AS Accountable,
					ISNULL(ECA.Desarrollo,0)  AS Desarrollo,
					ISNULL(ECA.Exploracion,0) AS Exploracion,
					ISNULL(ECA.Evaluacion,0)  AS Evaluacion,
					ISNULL(ECA.Transicion,0)  AS Transicion,
					ISNULL(ECA.AbandonoArea,0) AS AbandonoArea,
					ISNULL(ECA.AbandonoPozo,0) AS AbandonoPozo
            FROM EN_ContratoEntregable AS CE
                JOIN EN_Entregable AS EN
                    ON CE.IdEntregable = EN.IdEntregable
                       AND CE.IdContrato = @IdContrato
					   AND EN.BITJOA = 0
					   AND ISNULL(EN.IsEliminado, 0) = 0
					   AND ISNULL(CE.Activo, 0) = @Activo
                JOIN CO_Contrato C
                    ON C.IdContrato =	@IdContrato
                JOIN EN_EntregableRonda ER
                    ON C.IdRonda = ER.idRonda
                       AND EN.IdEntregable = ER.idEntregable
                LEFT JOIN dbo.EN_Actividad AE
                    ON CE.IdContratoEntregable = AE.IdContratoEntregable
                       AND AE.EstadoID = 10000
                LEFT JOIN dbo.AP_Usuario UE
                    ON AE.idUsuario = UE.UsuarioID
                LEFT JOIN dbo.EN_Actividad AR
                    ON CE.IdContratoEntregable = AR.IdContratoEntregable
                       AND AR.EstadoID = 10001
                LEFT JOIN dbo.EN_Actividad AP
                    ON CE.IdContratoEntregable = AP.IdContratoEntregable
                       AND AP.EstadoID = 10002
                LEFT JOIN dbo.AP_Usuario UA
                    ON AP.idUsuario = UA.UsuarioID
                LEFT JOIN [EN_FrecuenciaEntregable] AS FE
                    ON EN.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable
                LEFT JOIN EN_MarcoLegal AS ML
                    ON EN.IdMarcoLegal = ML.IdMarcoLegal
                LEFT JOIN dbo.EN_ReceptorEntregable R
                    ON EN.IdReceptorEntregable = R.IdReceptorEntregable
                LEFT JOIN dbo.EN_Area are
                    ON CE.IdArea = are.idArea
                LEFT JOIN dbo.EN_Etapa et
					ON EN.IdEtapa = et.IdEtapa
                LEFT JOIN EN_CatalogoProcesosEntregables CPE
                    ON CE.IdEntregable = CPE.IdEntregable
				LEFT JOIN
					AP_USUARIO FP		-- OBTENER NOMBRE DEL FOCAL POINT
					ON	CE.FocalPoint	=	FP.Usuario
				LEFT JOIN
					AP_USUARIO AC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
					ON	CE.AccountableCompliance	=	AC.Usuario
				LEFT JOIN
					AP_USUARIO ACC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE
					ON	CE.Accountable	=	ACC.Usuario
				LEFT JOIN
					#RelacionadosNOMostrar	ENM
					ON	EN.IdEntregable	=	ENM.IdEntregable
				LEFT JOIN
					#RelacionadosMostrar	EM
					ON	EN.IdEntregable	=	EM.IdEntregable
				LEFT JOIN 
					EN_ENTREGABLE_CONFIGADICIONAL ECA
					ON EN.IdEntregable=ECA.IdEntregable
            WHERE 
                  ISNULL(ML.Activo, 0) = 1
                  AND
                  (   CPE.IdCatProceso IS NULL
                      OR CPE.BitPrincipal = 1
                  )
				  AND ENM.IdEntregable IS NULL
            GROUP BY CE.IdContratoEntregable,
                     CE.IdContrato,
                     FE.FrecuenciaEntregable,
                     CASE WHEN 	ISNULL(EM.Relacionados,'') <> ''
						THEN LTRIM(RTRIM(EN.Consecutivo)) + ' Relacionados: ' + EM.Relacionados
					ELSE	EN.Consecutivo	END,
                     ISNULL(ML.MarcoLegal, ''),
                     CE.IdEntregable,
                     ISNULL(are.NombreArea, ''), --CE.AreaResponsable,
                     CE.FechaLimiteEntrega,
                     CE.DiasElaboracion,
                     CE.DiasRevision,
                     CE.DiasAprobacion,
					CE.DiasAlerta,
                     CE.ReceptorAlerta,
                     CE.CreadoPor,
                     CE.CreadoEl,
                     CE.ModificadoPor,
                     CE.ModificadoEl,
                     ISNULL(CE.Activo, 0),
                     CE.FechaLimiteEntregaRegulador,
                     ISNULL(R.ReceptorEntregable, ''),
                     ISNULL(EN.Descripcion, ''),
                     ISNULL(UE.Nombre, ''),
                     AE.IdContratoEntregable,
                     ISNULL(UA.Nombre, ''),
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
                         ELSE 'No Especificado'
                     END,
                     ISNULL(et.Etapa, 'No Especificada'),
					 ISNULL(CE.Subfuncion,''),
					 CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')
						ELSE ISNULL(FP.Nombre,'') --+ ' (' + CE.FocalPoint + ')'
					END,
					CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
						ELSE ISNULL(AC.Nombre,'') --+ ' (' + CE.AccountableCompliance + ')'
					END,
					CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
						ELSE ISNULL(ACC.Nombre,'') --+ ' (' + CE.Accountable + ')'
					END,
					ISNULL(ECA.Desarrollo,0),
					ISNULL(ECA.Exploracion,0),
					ISNULL(ECA.Evaluacion,0),
					ISNULL(ECA.Transicion,0),
					ISNULL(ECA.AbandonoArea,0),
					ISNULL(ECA.AbandonoPozo,0)
            ORDER BY 
					CE.IdContratoEntregable
					--COUNT(DISTINCT AE.ActividadID),
                     --COUNT(DISTINCT AR.ActividadID),
                     --COUNT(DISTINCT AP.ActividadID);
        END;
        IF (@BitProcesos = 1)
        BEGIN
            SELECT CE.IdContratoEntregable,
                   CE.IdContrato,
                   ISNULL(FE.FrecuenciaEntregable, '') AS FrecuenciaEntregable,
                   CASE WHEN 	ISNULL(EM.Relacionados,'') <> ''
						THEN LTRIM(RTRIM(EN.Consecutivo)) + ' Relacionados: ' + EM.Relacionados
					ELSE	EN.Consecutivo	END	AS	Consecutivo,
                   ISNULL(ML.MarcoLegal, '') AS MarcoLegal,
					CE.IdEntregable,
                   ISNULL(are.NombreArea, '') AS AreaResponsable, --CE.AreaResponsable,
                   CE.FechaLimiteEntrega,
                   CE.DiasElaboracion,
                   CE.DiasRevision,
                   CE.DiasAprobacion,
                   CE.DiasAlerta,
                   CE.ReceptorAlerta,
                   CE.CreadoPor,
                   CE.CreadoEl,
                   CE.ModificadoPor,
                   CE.ModificadoEl,
                   ISNULL(CE.Activo, 0) AS Activo,
                   CE.FechaLimiteEntregaRegulador,
                   LTRIM(COUNT(DISTINCT AE.ActividadID)) + ' - ' + LTRIM(COUNT(DISTINCT AR.ActividadID)) + ' - '
                   + LTRIM(COUNT(DISTINCT AP.ActividadID)) AS Configuracion,
                   ISNULL(R.ReceptorEntregable, '') AS ReceptorEntregable,
                   ISNULL(EN.Descripcion, '') AS Descripcion,
                   ISNULL(UE.Nombre, '') AS usuarioElaborador,
                   dbo.fnGetRevisoresEntregable(AE.IdContratoEntregable) AS UsuariosRevisores,
                   ISNULL(UA.Nombre, '') AS usuarioAprobador,
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
                       ELSE 'No Especificado'
                   END AS ActividadPetrolera,
                   ISNULL(et.Etapa, 'No Especificada') AS Etapa,
                   CP.Clave+' '+Substring(Replace(CP.Nombre,CP.Clave+' ',''),8,LEN(CP.Nombre)) AS CatProceso,
				   ISNULL(CE.Subfuncion,'') AS Subfuncion,
				   CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')
						ELSE ISNULL(FP.Nombre,'') --+ ' (' + CE.FocalPoint + ')'
					END		AS FocalPoint,
					CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
						ELSE ISNULL(AC.Nombre,'') --+ ' (' + CE.AccountableCompliance + ')'
					END		AS AccountableCompliance,
					CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
						ELSE ISNULL(ACC.Nombre,'') --+ ' (' + CE.Accountable + ')'
					END		AS Accountable
            FROM EN_ContratoEntregable AS CE	(NOLOCK)
                JOIN EN_Entregable AS EN	(NOLOCK)
                    ON CE.IdEntregable = EN.IdEntregable
                       AND CE.IdContrato = @IdContrato
					   AND EN.BITJOA = 0
					   AND ISNULL(EN.IsEliminado, 0) = 0
                JOIN CO_Contrato C	(NOLOCK)
                    ON C.IdContrato = @IdContrato
                JOIN EN_EntregableRonda ER	(NOLOCK)
                    ON C.IdRonda = ER.idRonda
                       AND EN.IdEntregable = ER.idEntregable
                JOIN EN_CatalogoProcesosEntregables CPE	(NOLOCK)
                    ON CE.IdEntregable = CPE.IdEntregable
                JOIN EN_CatalogoProcesos CP	(NOLOCK)
                    ON CPE.IdCatProceso = CP.IdCatProceso
                LEFT JOIN dbo.EN_Actividad AE
                    ON CE.IdContratoEntregable = AE.IdContratoEntregable
                       AND AE.EstadoID = 10000
                LEFT JOIN dbo.AP_Usuario UE
                    ON AE.idUsuario = UE.UsuarioID
                LEFT JOIN dbo.EN_Actividad AR
                    ON CE.IdContratoEntregable = AR.IdContratoEntregable
                       AND AR.EstadoID = 10001
                LEFT JOIN dbo.EN_Actividad AP
                    ON CE.IdContratoEntregable = AP.IdContratoEntregable
                       AND AP.EstadoID = 10002
                LEFT JOIN dbo.AP_Usuario UA
                    ON AP.idUsuario = UA.UsuarioID
                LEFT JOIN [EN_FrecuenciaEntregable] AS FE
                    ON EN.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable
                LEFT JOIN EN_MarcoLegal AS ML
                    ON EN.IdMarcoLegal = ML.IdMarcoLegal
                LEFT JOIN dbo.EN_ReceptorEntregable R
                    ON EN.IdReceptorEntregable = R.IdReceptorEntregable
               LEFT JOIN dbo.EN_Area are
                    ON CE.IdArea = are.idArea
                LEFT JOIN dbo.EN_Etapa et
                    ON EN.IdEtapa = et.IdEtapa
				LEFT JOIN
					AP_USUARIO FP		-- OBTENER NOMBRE DEL FOCAL POINT
					ON	CE.FocalPoint	=	FP.Usuario
				LEFT JOIN
					AP_USUARIO AC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
					ON	CE.AccountableCompliance	=	AC.Usuario
				LEFT JOIN
					AP_USUARIO ACC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE
					ON	CE.Accountable	=	ACC.Usuario
				LEFT JOIN
					#RelacionadosNOMostrar	ENM
					ON	EN.IdEntregable	=	ENM.IdEntregable
				LEFT JOIN
					#RelacionadosMostrar	EM
					ON	EN.IdEntregable	=	EM.IdEntregable
            WHERE 
                  ISNULL(ML.Activo, 0) = 1
				  AND ENM.IdEntregable IS NULL
            GROUP BY CE.IdContratoEntregable,
                     CE.IdContrato,
                     FE.FrecuenciaEntregable,
					CASE WHEN 	ISNULL(EM.Relacionados,'') <> ''
						THEN LTRIM(RTRIM(EN.Consecutivo)) + ' Relacionados: ' + EM.Relacionados
					ELSE	EN.Consecutivo	END,
                     ISNULL(ML.MarcoLegal, ''),
                     CE.IdEntregable,
                     ISNULL(are.NombreArea, ''), --CE.AreaResponsable,
                     CE.FechaLimiteEntrega,
                     CE.DiasElaboracion,
                     CE.DiasRevision,
                     CE.DiasAprobacion,
                     CE.DiasAlerta,
                     CE.ReceptorAlerta,
                     CE.CreadoPor,
                     CE.CreadoEl,
                     CE.ModificadoPor,
                     CE.ModificadoEl,
                     ISNULL(CE.Activo, 0),
                     CE.FechaLimiteEntregaRegulador,
                     ISNULL(R.ReceptorEntregable, ''),
                     ISNULL(EN.Descripcion, ''),
                     ISNULL(UE.Nombre, ''),
                     AE.IdContratoEntregable,
                     ISNULL(UA.Nombre, ''),
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
                         ELSE 'No Especificado'
                     END,
                     ISNULL(et.Etapa, 'No Especificada'),
                     CP.Nombre,CP.Clave,
					 ISNULL(CE.Subfuncion,''),
					 CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')
						ELSE ISNULL(FP.Nombre,'') --+ ' (' + CE.FocalPoint + ')'
					END,
					CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
						ELSE ISNULL(AC.Nombre,'') --+ ' (' + CE.AccountableCompliance + ')'
					END,
					CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
						ELSE ISNULL(ACC.Nombre,'') --+ ' (' + CE.Accountable + ')'
					END
            ORDER BY	CE.IdContratoEntregable
					-- COUNT(DISTINCT AE.ActividadID),
     --                COUNT(DISTINCT AR.ActividadID),
					--COUNT(DISTINCT AP.ActividadID);
        END;
        IF (@BitTodos = 1)
        BEGIN
            SELECT CE.IdContratoEntregable,
                   CE.IdContrato,
                   ISNULL(FE.FrecuenciaEntregable, '') AS FrecuenciaEntregable,
                   CASE WHEN 	ISNULL(EM.Relacionados,'') <> ''
						THEN LTRIM(RTRIM(EN.Consecutivo)) + ' Relacionados: ' + EM.Relacionados
						WHEN ISNULL(Compl.Consecutivo,'') <> ''
						THEN LTRIM(RTRIM(EN.Consecutivo)) + ' Relacionados: ' + Compl.Consecutivo
					ELSE	EN.Consecutivo	END AS Consecutivo,
                   ISNULL(ML.MarcoLegal, '') AS MarcoLegal,
                   CE.IdEntregable,
                   ISNULL(are.NombreArea, '') AS AreaResponsable, --CE.AreaResponsable,
                   CE.FechaLimiteEntrega,
                   CE.DiasElaboracion,
                   CE.DiasRevision,
                   CE.DiasAprobacion,
                   CE.DiasAlerta,
                   CE.ReceptorAlerta,
                   CE.CreadoPor,
                   CE.CreadoEl,
                   CE.ModificadoPor,
                   CE.ModificadoEl,
                   ISNULL(CE.Activo, 0) AS Activo,
                   CE.FechaLimiteEntregaRegulador,
                   LTRIM(COUNT(DISTINCT AE.ActividadID)) + ' - ' + LTRIM(COUNT(DISTINCT AR.ActividadID)) + ' - '
                   + LTRIM(COUNT(DISTINCT AP.ActividadID)) AS Configuracion,
                   ISNULL(R.ReceptorEntregable, '') AS ReceptorEntregable,
                   ISNULL(EN.Descripcion, '') AS Descripcion,
                   ISNULL(UE.Nombre, '') AS usuarioElaborador,
                   dbo.fnGetRevisoresEntregable(AE.IdContratoEntregable) AS UsuariosRevisores,
                   ISNULL(UA.Nombre, '') AS usuarioAprobador,
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
                       WHEN APReparacionMenor = 1 THEN	'Reparación Menor'
                       WHEN APTransporteHidrocarburos = 1 THEN	'Transporte de Hidrocarburos'
                       WHEN APAdministracionContratos = 1 THEN	'Administración de Contratos'
                       WHEN APQuemaGas = 1 THEN	'Quema de Gas'
                       WHEN BitInterno = 1 THEN	'Entregable Interno'
                       ELSE	'No Especificado'
                   END AS ActividadPetrolera,
                   ISNULL(et.Etapa, 'No Especificada') AS Etapa,
				   ISNULL(CE.Subfuncion,'') AS Subfuncion,
				   CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')
						ELSE ISNULL(FP.Nombre,'') --+ ' (' + CE.FocalPoint + ')'
					END		AS FocalPoint,
					CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
						ELSE ISNULL(AC.Nombre,'') --+ ' (' + CE.AccountableCompliance + ')'
					END		AS AccountableCompliance,
					CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
						ELSE ISNULL(ACC.Nombre,'') --+ ' (' + CE.Accountable + ')'
					END		AS Accountable,
					ISNULL(ECA.Desarrollo,0)  AS Desarrollo,
					ISNULL(ECA.Exploracion,0) AS Exploracion,
					ISNULL(ECA.Evaluacion,0)  AS Evaluacion,
					ISNULL(ECA.Transicion,0)  AS Transicion,
					ISNULL(ECA.AbandonoArea,0) AS AbandonoArea,
					ISNULL(ECA.AbandonoPozo,0) AS AbandonoPozo
            FROM EN_ContratoEntregable AS CE (NOLOCK)
                JOIN EN_Entregable AS EN	(NOLOCK)
               ON CE.IdEntregable = EN.IdEntregable
                     AND CE.IdContrato = @IdContrato
					 AND EN.BITJOA = 0
					 AND ISNULL(EN.IsEliminado, 0) = 0
                JOIN CO_Contrato C	(NOLOCK)
                    ON C.IdContrato = @IdContrato
                INNER JOIN EN_EntregableRonda ER	(NOLOCK)
                    ON C.IdRonda = ER.idRonda
                       AND EN.IdEntregable = ER.idEntregable
                LEFT JOIN dbo.EN_Actividad AE
                    ON CE.IdContratoEntregable = AE.IdContratoEntregable
                       AND AE.EstadoID = 10000
                LEFT JOIN dbo.AP_Usuario UE
                    ON AE.idUsuario = UE.UsuarioID
                LEFT JOIN dbo.EN_Actividad AR
                    ON CE.IdContratoEntregable = AR.IdContratoEntregable
                       AND AR.EstadoID = 10001
                LEFT JOIN dbo.EN_Actividad AP
                    ON CE.IdContratoEntregable = AP.IdContratoEntregable
                       AND AP.EstadoID = 10002
                LEFT JOIN dbo.AP_Usuario UA
                    ON AP.idUsuario = UA.UsuarioID
                LEFT JOIN [EN_FrecuenciaEntregable] AS FE
                    ON EN.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable
                LEFT JOIN EN_MarcoLegal AS ML
                    ON EN.IdMarcoLegal = ML.IdMarcoLegal
                LEFT JOIN dbo.EN_ReceptorEntregable R
                    ON EN.IdReceptorEntregable = R.IdReceptorEntregable
                LEFT JOIN dbo.EN_Area are
                    ON CE.IdArea = are.idArea
                LEFT JOIN dbo.EN_Etapa et
                    ON EN.IdEtapa = et.IdEtapa
				LEFT JOIN
					AP_USUARIO FP		-- OBTENER NOMBRE DEL FOCAL POINT
					ON	CE.FocalPoint	=	FP.Usuario
				LEFT JOIN
					AP_USUARIO AC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
					ON	CE.AccountableCompliance	=	AC.Usuario
				LEFT JOIN
					AP_USUARIO ACC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE
					ON	CE.Accountable	=	ACC.Usuario
				LEFT JOIN
					#RelacionadosNOMostrar	ENM
					ON	EN.IdEntregable	=	ENM.IdEntregable
				LEFT JOIN
					#RelacionadosMostrar	EM
					ON	EN.IdEntregable	=	EM.IdEntregable
				LEFT JOIN
					#RelacionadosMostrar	Compl
					ON	ENM.IdRelacion	=	Compl.IdRelacion
				LEFT JOIN 
					EN_ENTREGABLE_CONFIGADICIONAL ECA
					ON EN.IdEntregable	=	ECA.IdEntregable
            WHERE 
                  ISNULL(ML.Activo, 0) = 1
            GROUP BY CE.IdContratoEntregable,
                     CE.IdContrato,
                     FE.FrecuenciaEntregable,
                     CASE WHEN 	ISNULL(EM.Relacionados,'') <> ''
						THEN LTRIM(RTRIM(EN.Consecutivo)) + ' Relacionados: ' + EM.Relacionados
						WHEN ISNULL(Compl.Consecutivo,'') <> ''
						THEN LTRIM(RTRIM(EN.Consecutivo)) + ' Relacionados: ' + Compl.Consecutivo
					ELSE	EN.Consecutivo	END,
                     ISNULL(ML.MarcoLegal, ''),
                     CE.IdEntregable,
                     ISNULL(are.NombreArea, ''), --CE.AreaResponsable,
                     CE.FechaLimiteEntrega,
                     CE.DiasElaboracion,
                     CE.DiasRevision,
                     CE.DiasAprobacion,
                    CE.DiasAlerta,
					CE.ReceptorAlerta,
                     CE.CreadoPor,
                     CE.CreadoEl,
                     CE.ModificadoPor,
                     CE.ModificadoEl,
                     ISNULL(CE.Activo, 0),
                     CE.FechaLimiteEntregaRegulador,
                     ISNULL(R.ReceptorEntregable, ''),
                     ISNULL(EN.Descripcion, ''),
                     ISNULL(UE.Nombre, ''),
                     AE.IdContratoEntregable,
                     ISNULL(UA.Nombre, ''),
                     CASE
                         WHEN APPozoAlivio = 1 THEN  'Pozo de alivio'
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
                         WHEN APTransporteHidrocarburos = 1 THEN	'Transporte de Hidrocarburos'
                         WHEN APAdministracionContratos = 1 THEN	'Administración de Contratos'
                         WHEN APQuemaGas = 1 THEN	'Quema de Gas'
                         WHEN BitInterno = 1 THEN	'Entregable Interno'
                         ELSE	'No Especificado'
                     END,
                     ISNULL(et.Etapa, 'No Especificada'),
					 ISNULL(CE.Subfuncion,''),
					 CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')
						ELSE ISNULL(FP.Nombre,'') --+ ' (' + CE.FocalPoint + ')'
					END,
					CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
						ELSE ISNULL(AC.Nombre,'') --+ ' (' + CE.AccountableCompliance + ')'
					END,
					CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
						ELSE ISNULL(ACC.Nombre,'') --+ ' (' + CE.Accountable + ')'
					END,
					ISNULL(ECA.Desarrollo,0),
					ISNULL(ECA.Exploracion,0),
					ISNULL(ECA.Evaluacion,0),
					ISNULL(ECA.Transicion,0),
					ISNULL(ECA.AbandonoArea,0),
					ISNULL(ECA.AbandonoPozo,0)
            ORDER BY CE.IdContratoEntregable
					--COUNT(DISTINCT AE.ActividadID),
     --                COUNT(DISTINCT AR.ActividadID),
     --                COUNT(DISTINCT AP.ActividadID);
        END;
    END;
    ELSE
    BEGIN --Area 
        INSERT INTO #Areas (Area)
        SELECT REPLACE(P.NombrePermiso, 'Acceso a Entregables de ', '')
        FROM dbo.AP_PermisosUsuarios PU
            JOIN dbo.AP_Permiso P
                ON PU.IdPermiso = P.IdPermiso
        WHERE UsuarioID = @IdUsuario
              AND idContrato = @IdContrato
              AND P.BitActivo = 1
              AND PU.BitActivo = 1;

        IF (@BitProcesos = 0 AND @BitTodos = 0)
        BEGIN
            SELECT CE.IdContratoEntregable,
                   CE.IdContrato,
                   ISNULL(FE.FrecuenciaEntregable, '') AS FrecuenciaEntregable,
                EN.Consecutivo,
                   ISNULL(ML.MarcoLegal, '') AS MarcoLegal,
                   CE.IdEntregable,
                   ISNULL(are.NombreArea, '') AS AreaResponsable, --CE.AreaResponsable,
                   CE.FechaLimiteEntrega,
                   CE.DiasElaboracion,
                   CE.DiasRevision,
                   CE.DiasAprobacion,
                   CE.DiasAlerta,
                   CE.ReceptorAlerta,
                   CE.CreadoPor,
                   CE.CreadoEl,
                   CE.ModificadoPor,
                   CE.ModificadoEl,
                   ISNULL(CE.Activo, 0) AS Activo,
                   CE.FechaLimiteEntregaRegulador,
                   LTRIM(COUNT(DISTINCT AE.ActividadID)) + ' - ' + LTRIM(COUNT(DISTINCT AR.ActividadID)) + ' - '
                   + LTRIM(COUNT(DISTINCT AP.ActividadID)) AS Configuracion,
                   ISNULL(R.ReceptorEntregable, '') AS ReceptorEntregable,
                   ISNULL(EN.Descripcion, '') AS Descripcion,
                   ISNULL(UE.Nombre, '') AS usuarioElaborador,
                   dbo.fnGetRevisoresEntregable(AE.IdContratoEntregable) AS UsuariosRevisores,
                   ISNULL(UA.Nombre, '') AS usuarioAprobador,
                   CASE
                       WHEN APPozoAlivio = 1 THEN	'Pozo de alivio'
                       WHEN APCierreDesmantelamientoAbandono = 1 THEN	'Abandono'
                       WHEN APPerforacion = 1 THEN	'Perforación'
                       WHEN APTerminacion = 1 THEN	'Terminación'
                       WHEN APActProduccion = 1 THEN	'Actividades de Producción'
                       WHEN APEstimulacion = 1 THEN	'Estimulación'
                       WHEN APPruebaProduccion = 1 THEN	'Prueba de Producción'
					   WHEN APConstruccionCamino = 1 THEN	'Construcción de Camino'
                       WHEN APConstruccionLocalizacion = 1 THEN	'Construcción de Localizacion'
                       WHEN APTomaInformacionSismica = 1 THEN	'Toma de Información Sísmica'
                       WHEN APCorteNucleos = 1 THEN	'Corte de Nucleos'
                       WHEN APConstruccionLineaDescarga = 1 THEN	'Construcción de Lineas de descargas'
                       WHEN APSistemaArtificialProduccion = 1 THEN	'Sistemas Artificiales de Producción'
                       WHEN APTomaInformacionPozo = 1 THEN	'Medición de Pozos'
                       WHEN APReparacionMayor = 1 THEN	'Reparación Mayor'
                       WHEN APReparacionMenor = 1 THEN	'Reparación Menor'
                       WHEN APTransporteHidrocarburos = 1 THEN	'Transporte de Hidrocarburos'
                       WHEN APAdministracionContratos = 1 THEN	'Administración de Contratos'
                       WHEN APQuemaGas = 1 THEN	'Quema de Gas'
                       WHEN BitInterno = 1 THEN	'Entregable Interno'
                       ELSE	'No Especificado'
                   END AS ActividadPetrolera,
                   ISNULL(et.Etapa, 'No Especificada') AS Etapa,
				   ISNULL(CE.Subfuncion,'') AS Subfuncion,
				   CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')
						ELSE ISNULL(FP.Nombre,'') --+ ' (' + CE.FocalPoint + ')'
					END		AS FocalPoint,
					CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
						ELSE ISNULL(AC.Nombre,'') --+ ' (' + CE.AccountableCompliance + ')'
					END		AS AccountableCompliance,
					CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
						ELSE ISNULL(ACC.Nombre,'') --+ ' (' + CE.Accountable + ')'
					END		AS Accountable,
					ISNULL(ECA.Desarrollo,0)  AS Desarrollo,
					ISNULL(ECA.Exploracion,0) AS Exploracion,
					ISNULL(ECA.Evaluacion,0)  AS Evaluacion,
					ISNULL(ECA.Transicion,0)  AS Transicion,
					ISNULL(ECA.AbandonoArea,0) AS AbandonoArea,
					ISNULL(ECA.AbandonoPozo,0) AS AbandonoPozo
            --  SELECT      *
            FROM EN_ContratoEntregable AS CE	(NOLOCK)
                JOIN EN_Entregable AS EN	(NOLOCK)
                    ON CE.IdEntregable = EN.IdEntregable
                       AND CE.IdContrato = @IdContrato
					   AND EN.BITJOA = 0
					   AND ISNULL(EN.IsEliminado, 0) = 0
						AND ISNULL(CE.Activo, 0) = @Activo
                JOIN CO_Contrato C	(NOLOCK)
                    ON C.IdContrato = @IdContrato
                INNER JOIN EN_EntregableRonda ER	(NOLOCK)
                    ON C.IdRonda = ER.idRonda
                       AND EN.IdEntregable = ER.idEntregable
                JOIN dbo.EN_Area are	(NOLOCK)
                    ON CE.IdArea = are.idArea
                       AND are.idContrato = @IdContrato
                JOIN #Areas TAR	(NOLOCK)
                    ON are.NombreArea = TAR.Area
                LEFT JOIN dbo.EN_Actividad AE
                    ON CE.IdContratoEntregable = AE.IdContratoEntregable
                       AND AE.EstadoID = 10000
                LEFT JOIN dbo.AP_Usuario UE
                    ON AE.idUsuario = UE.UsuarioID
                LEFT JOIN dbo.EN_Actividad AR
                    ON CE.IdContratoEntregable = AR.IdContratoEntregable
                       AND AR.EstadoID = 10001
                LEFT JOIN dbo.EN_Actividad AP
                    ON CE.IdContratoEntregable = AP.IdContratoEntregable
                       AND AP.EstadoID = 10002
                LEFT JOIN dbo.AP_Usuario UA
                    ON AP.idUsuario = UA.UsuarioID
                LEFT JOIN [EN_FrecuenciaEntregable] AS FE
                    ON EN.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable
                LEFT JOIN EN_MarcoLegal AS ML
					ON EN.IdMarcoLegal = ML.IdMarcoLegal
				LEFT JOIN dbo.EN_ReceptorEntregable R
                    ON EN.IdReceptorEntregable = R.IdReceptorEntregable
                LEFT JOIN dbo.EN_Etapa et
                    ON EN.IdEtapa = et.IdEtapa
                LEFT JOIN EN_CatalogoProcesosEntregables CPE
                    ON CE.IdEntregable = CPE.IdEntregable
				LEFT JOIN
					AP_USUARIO FP		-- OBTENER NOMBRE DEL FOCAL POINT
					ON	CE.FocalPoint	=	FP.Usuario
				LEFT JOIN
					AP_USUARIO AC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
					ON	CE.AccountableCompliance	=	AC.Usuario
				LEFT JOIN
					AP_USUARIO ACC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE
					ON	CE.Accountable	=	ACC.Usuario
				LEFT JOIN
					#RelacionadosNOMostrar	ENM
					ON	EN.IdEntregable	=	ENM.IdEntregable
				LEFT JOIN
					#RelacionadosMostrar	EM
					ON	EN.IdEntregable	=	EM.IdEntregable
				LEFT JOIN 
					EN_ENTREGABLE_CONFIGADICIONAL ECA
					ON EN.IdEntregable	=	ECA.IdEntregable
            WHERE 
                  ISNULL(ML.Activo, 0) = 1
                 AND
                  (
                      CPE.IdCatProceso IS NULL
                      OR CPE.BitPrincipal = 1
                  )
            GROUP BY CE.IdContratoEntregable,
					CE.IdContrato,
                     FE.FrecuenciaEntregable,
                     EN.Consecutivo,
                     ISNULL(ML.MarcoLegal, ''),
                     CE.IdEntregable,
                     ISNULL(are.NombreArea, ''), --CE.AreaResponsable,
                     CE.FechaLimiteEntrega,
                     CE.DiasElaboracion,
                     CE.DiasRevision,
                     CE.DiasAprobacion,
                     CE.DiasAlerta,
                     CE.ReceptorAlerta,
                     CE.CreadoPor,
					 CE.CreadoEl,
					CE.ModificadoPor,
                     CE.ModificadoEl,
                     ISNULL(CE.Activo, 0),
                     CE.FechaLimiteEntregaRegulador,
                     ISNULL(R.ReceptorEntregable, ''),
                     ISNULL(EN.Descripcion, ''),
                     ISNULL(UE.Nombre, ''),
                     AE.IdContratoEntregable,
                     ISNULL(UA.Nombre, ''),
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
                         ELSE	'No Especificado'
                     END,
                     ISNULL(et.Etapa, 'No Especificada'),
					 ISNULL(CE.Subfuncion,''),
					 CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')
						ELSE ISNULL(FP.Nombre,'') --+ ' (' + CE.FocalPoint + ')'
					END,
					CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
						ELSE ISNULL(AC.Nombre,'') --+ ' (' + CE.AccountableCompliance + ')'
					END,
					CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
						ELSE ISNULL(ACC.Nombre,'') --+ ' (' + CE.Accountable + ')'
					END,
					ISNULL(ECA.Desarrollo,0),
					ISNULL(ECA.Exploracion,0),
					ISNULL(ECA.Evaluacion,0),
					ISNULL(ECA.Transicion,0),
					ISNULL(ECA.AbandonoArea,0),
					ISNULL(ECA.AbandonoPozo,0)
            ORDER BY CE.IdContratoEntregable
					--COUNT(DISTINCT AE.ActividadID),
     --                COUNT(DISTINCT AR.ActividadID),
     --                COUNT(DISTINCT AP.ActividadID);
        END;
        IF (@BitProcesos = 1)
        BEGIN
            SELECT CE.IdContratoEntregable,
                   CE.IdContrato,
                   ISNULL(FE.FrecuenciaEntregable, '') AS FrecuenciaEntregable,
                   CASE WHEN 	ISNULL(EM.Relacionados,'') <> ''
						THEN LTRIM(RTRIM(EN.Consecutivo)) + ' Relacionados: ' + EM.Relacionados
					ELSE	EN.Consecutivo	END	AS	Consecutivo,
                   ISNULL(ML.MarcoLegal, '') AS MarcoLegal,
                   CE.IdEntregable,
                   ISNULL(are.NombreArea, '') AS AreaResponsable, --CE.AreaResponsable,
                   CE.FechaLimiteEntrega,
                   CE.DiasElaboracion,
                   CE.DiasRevision,
                   CE.DiasAprobacion,
                   CE.DiasAlerta,
                   CE.ReceptorAlerta,
                   CE.CreadoPor,
                   CE.CreadoEl,
                   CE.ModificadoPor,
                   CE.ModificadoEl,
                   ISNULL(CE.Activo, 0) AS Activo,
                   CE.FechaLimiteEntregaRegulador,
                   LTRIM(COUNT(DISTINCT AE.ActividadID)) + ' - ' + LTRIM(COUNT(DISTINCT AR.ActividadID)) + ' - '
                   + LTRIM(COUNT(DISTINCT AP.ActividadID)) AS Configuracion,
                   ISNULL(R.ReceptorEntregable, '') AS ReceptorEntregable,
                   ISNULL(EN.Descripcion, '') AS Descripcion,
                   ISNULL(UE.Nombre, '') AS usuarioElaborador,
                   dbo.fnGetRevisoresEntregable(AE.IdContratoEntregable) AS UsuariosRevisores,
                   ISNULL(UA.Nombre, '') AS usuarioAprobador,
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
                       WHEN BitInterno = 1 THEN
                           'Entregable Interno'
                       ELSE
                           'No Especificado'
                   END AS ActividadPetrolera,
                   ISNULL(et.Etapa, 'No Especificada') AS Etapa,
                   CP.Clave+' '+Substring(Replace(CP.Nombre,CP.Clave+' ',''),8,LEN(CP.Nombre)) AS CatProceso,
				   ISNULL(CE.Subfuncion,'') AS Subfuncion,
				   CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')
						ELSE ISNULL(FP.Nombre,'') --+ ' (' + CE.FocalPoint + ')'
					END		AS FocalPoint,
					CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
						ELSE ISNULL(AC.Nombre,'') --+ ' (' + CE.AccountableCompliance + ')'
					END		AS AccountableCompliance,
					CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
						ELSE ISNULL(ACC.Nombre,'') --+ ' (' + CE.Accountable + ')'
					END		AS Accountable
            --  SELECT      *
            FROM EN_ContratoEntregable AS CE	(NOLOCK)
                JOIN EN_Entregable AS EN	(NOLOCK)
                    ON CE.IdEntregable = EN.IdEntregable
                      AND CE.IdContrato = @IdContrato
					  AND EN.BITJOA = 0
					  AND ISNULL(EN.IsEliminado, 0) = 0
                JOIN CO_Contrato C	(NOLOCK)
                    ON C.IdContrato = @IdContrato
                JOIN EN_EntregableRonda ER	(NOLOCK)
                    ON C.IdRonda = ER.idRonda
                       AND EN.IdEntregable = ER.idEntregable
              JOIN EN_CatalogoProcesosEntregables CPE	(NOLOCK)
                    ON CE.IdEntregable = CPE.IdEntregable
                JOIN EN_CatalogoProcesos CP	(NOLOCK)
                    ON CPE.IdCatProceso = CP.IdCatProceso
                JOIN dbo.EN_Area are	(NOLOCK)
                    ON CE.IdArea = are.idArea
                       AND are.idContrato = @IdContrato
                JOIN #Areas TAR
                    ON are.NombreArea = TAR.Area
                LEFT JOIN dbo.EN_Actividad AE
                    ON CE.IdContratoEntregable = AE.IdContratoEntregable
                       AND AE.EstadoID = 10000
                LEFT JOIN dbo.AP_Usuario UE
                    ON AE.idUsuario = UE.UsuarioID
                LEFT JOIN dbo.EN_Actividad AR
                    ON CE.IdContratoEntregable = AR.IdContratoEntregable
                       AND AR.EstadoID = 10001
                LEFT JOIN dbo.EN_Actividad AP
                    ON CE.IdContratoEntregable = AP.IdContratoEntregable
                       AND AP.EstadoID = 10002
                LEFT JOIN dbo.AP_Usuario UA
                    ON AP.idUsuario = UA.UsuarioID
                LEFT JOIN [EN_FrecuenciaEntregable] AS FE
                    ON EN.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable
                LEFT JOIN EN_MarcoLegal AS ML
                    ON EN.IdMarcoLegal = ML.IdMarcoLegal
                LEFT JOIN dbo.EN_ReceptorEntregable R
                ON EN.IdReceptorEntregable = R.IdReceptorEntregable
                LEFT JOIN dbo.EN_Etapa et
                    ON EN.IdEtapa = et.IdEtapa
				LEFT JOIN
					AP_USUARIO FP		-- OBTENER NOMBRE DEL FOCAL POINT
					ON	CE.FocalPoint	=	FP.Usuario
				LEFT JOIN
					AP_USUARIO AC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
					ON	CE.AccountableCompliance	=	AC.Usuario
				LEFT JOIN
					AP_USUARIO ACC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE
					ON	CE.Accountable	=	ACC.Usuario
				LEFT JOIN
					#RelacionadosNOMostrar	ENM
					ON	EN.IdEntregable	=	ENM.IdEntregable
				LEFT JOIN
					#RelacionadosMostrar	EM
					ON	EN.IdEntregable	=	EM.IdEntregable
            WHERE 
                  ISNULL(ML.Activo, 0) = 1
            GROUP BY CE.IdContratoEntregable,
                     CE.IdContrato,
                     FE.FrecuenciaEntregable,
                     CASE WHEN 	ISNULL(EM.Relacionados,'') <> ''
						THEN LTRIM(RTRIM(EN.Consecutivo)) + ' Relacionados: ' + EM.Relacionados
					ELSE	EN.Consecutivo	END,
                     ISNULL(ML.MarcoLegal, ''),
                     CE.IdEntregable,
                     ISNULL(are.NombreArea, ''), --CE.AreaResponsable,
                     CE.FechaLimiteEntrega,
                     CE.DiasElaboracion,
                     CE.DiasRevision,
                     CE.DiasAprobacion,
                     CE.DiasAlerta,
                     CE.ReceptorAlerta,
                     CE.CreadoPor,
                     CE.CreadoEl,
                     CE.ModificadoPor,
                     CE.ModificadoEl,
                     ISNULL(CE.Activo, 0),
                     CE.FechaLimiteEntregaRegulador,
                     ISNULL(R.ReceptorEntregable, ''),
                     ISNULL(EN.Descripcion, ''),
                     ISNULL(UE.Nombre, ''),
                     AE.IdContratoEntregable,
                     ISNULL(UA.Nombre, ''),
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
                         ELSE 'No Especificado'
                     END,
                     ISNULL(et.Etapa, 'No Especificada'),
                     CP.Nombre,CP.Clave,
					 ISNULL(CE.Subfuncion,''),
					 CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')
						ELSE ISNULL(FP.Nombre,'') --+ ' (' + CE.FocalPoint + ')'
					END,
					CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
						ELSE ISNULL(AC.Nombre,'') --+ ' (' + CE.AccountableCompliance + ')'
					END,
					CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
						ELSE ISNULL(ACC.Nombre,'') --+ ' (' + CE.Accountable + ')'
					END
            ORDER BY CE.IdContratoEntregable
					--COUNT(DISTINCT AE.ActividadID),
     --                COUNT(DISTINCT AR.ActividadID),
     --                COUNT(DISTINCT AP.ActividadID);
        END;
        IF (@BitTodos = 1)
        BEGIN
            SELECT CE.IdContratoEntregable,
                   CE.IdContrato,
                   ISNULL(FE.FrecuenciaEntregable, '') AS FrecuenciaEntregable,
                   CASE WHEN 	ISNULL(EM.Relacionados,'') <> ''
						THEN LTRIM(RTRIM(EN.Consecutivo)) + ' Relacionados: ' + ISNULL(EM.Relacionados,'')
						WHEN ISNULL(Compl.Consecutivo,'') <> ''
						THEN LTRIM(RTRIM(EN.Consecutivo)) + ' Relacionados: ' + ISNULL(Compl.Consecutivo,'')
					ELSE	EN.Consecutivo	END	AS Consecutivo,
                   ISNULL(ML.MarcoLegal, '') AS MarcoLegal,
                   CE.IdEntregable,
                   ISNULL(are.NombreArea, '') AS AreaResponsable, --CE.AreaResponsable,
                   CE.FechaLimiteEntrega,
                   CE.DiasElaboracion,
                   CE.DiasRevision,
                   CE.DiasAprobacion,
                   CE.DiasAlerta,
                   CE.ReceptorAlerta,
                   CE.CreadoPor,
                   CE.CreadoEl,
                   CE.ModificadoPor,
                   CE.ModificadoEl,
                   ISNULL(CE.Activo, 0) AS Activo,
                   CE.FechaLimiteEntregaRegulador,
                   LTRIM(COUNT(DISTINCT AE.ActividadID)) + ' - ' + LTRIM(COUNT(DISTINCT AR.ActividadID)) + ' - '
                   + LTRIM(COUNT(DISTINCT AP.ActividadID)) AS Configuracion,
                   ISNULL(R.ReceptorEntregable, '') AS ReceptorEntregable,
                   ISNULL(EN.Descripcion, '') AS Descripcion,
                   ISNULL(UE.Nombre, '') AS usuarioElaborador,
                   dbo.fnGetRevisoresEntregable(AE.IdContratoEntregable) AS UsuariosRevisores,
                   ISNULL(UA.Nombre, '') AS usuarioAprobador,
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
                       ELSE 'No Especificado'
                   END AS ActividadPetrolera,
                   ISNULL(et.Etapa, 'No Especificada') AS Etapa,
				   ISNULL(CE.Subfuncion,'') AS Subfuncion,
				   CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')
						ELSE ISNULL(FP.Nombre,'') --+ ' (' + CE.FocalPoint + ')'
					END		AS FocalPoint,
					CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
						ELSE ISNULL(AC.Nombre,'') --+ ' (' + CE.AccountableCompliance + ')'
					END		AS AccountableCompliance,
					CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
						ELSE ISNULL(ACC.Nombre,'') --+ ' (' + CE.Accountable + ')'
					END		AS Accountable,
					ISNULL(ECA.Desarrollo,0)  AS Desarrollo,
					ISNULL(ECA.Exploracion,0) AS Exploracion,
					ISNULL(ECA.Evaluacion,0)  AS Evaluacion,
					ISNULL(ECA.Transicion,0)  AS Transicion,
					ISNULL(ECA.AbandonoArea,0) AS AbandonoArea,
					ISNULL(ECA.AbandonoPozo,0) AS AbandonoPozo
            --  SELECT      *
            FROM EN_ContratoEntregable AS CE	(NOLOCK)
                JOIN EN_Entregable AS EN	(NOLOCK)
                    ON CE.IdEntregable = EN.IdEntregable
                       AND CE.IdContrato = @IdContrato
					   AND EN.BITJOA = 0
					   AND	ISNULL(EN.IsEliminado, 0) = 0
                JOIN CO_Contrato C	(NOLOCK)
                    ON C.IdContrato = @IdContrato
                INNER JOIN EN_EntregableRonda ER	(NOLOCK)
                    ON C.IdRonda = ER.idRonda
                       AND EN.IdEntregable = ER.idEntregable
                JOIN dbo.EN_Area are	(NOLOCK)
                    ON CE.IdArea = are.idArea
                       AND are.idContrato = @IdContrato
                JOIN #Areas TAR
                    ON are.NombreArea = TAR.Area
                LEFT JOIN dbo.EN_Actividad AE
                    ON CE.IdContratoEntregable = AE.IdContratoEntregable
                       AND AE.EstadoID = 10000
                LEFT JOIN dbo.AP_Usuario UE
                    ON AE.idUsuario = UE.UsuarioID
                LEFT JOIN dbo.EN_Actividad AR
                    ON CE.IdContratoEntregable = AR.IdContratoEntregable
                       AND AR.EstadoID = 10001
                LEFT JOIN dbo.EN_Actividad AP
                    ON CE.IdContratoEntregable = AP.IdContratoEntregable
                       AND AP.EstadoID = 10002
                LEFT JOIN dbo.AP_Usuario UA
					ON AP.idUsuario = UA.UsuarioID
                LEFT JOIN [EN_FrecuenciaEntregable] AS FE
                    ON EN.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable
                LEFT JOIN EN_MarcoLegal AS ML
                    ON EN.IdMarcoLegal = ML.IdMarcoLegal
                LEFT JOIN dbo.EN_ReceptorEntregable R
                    ON EN.IdReceptorEntregable = R.IdReceptorEntregable
                LEFT JOIN dbo.EN_Etapa et
                    ON EN.IdEtapa = et.IdEtapa
				LEFT JOIN
					AP_USUARIO FP		-- OBTENER NOMBRE DEL FOCAL POINT
					ON	CE.FocalPoint	=	FP.Usuario
				LEFT JOIN
					AP_USUARIO AC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
					ON	CE.AccountableCompliance	=	AC.Usuario
				LEFT JOIN
					AP_USUARIO ACC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE
					ON	CE.Accountable	=	ACC.Usuario
				LEFT JOIN
					#RelacionadosNOMostrar	ENM
					ON	EN.IdEntregable	=	ENM.IdEntregable
				LEFT JOIN
					#RelacionadosMostrar	EM
					ON	EN.IdEntregable	=	EM.IdEntregable
				LEFT JOIN
					#RelacionadosMostrar	Compl
					ON	ENM.IdRelacion	=	Compl.IdRelacion
				LEFT JOIN 
					EN_ENTREGABLE_CONFIGADICIONAL ECA
					ON EN.IdEntregable=ECA.IdEntregable
         WHERE 
                ISNULL(ML.Activo, 0) = 1
            GROUP BY CE.IdContratoEntregable,
                     CE.IdContrato,
                     FE.FrecuenciaEntregable,
                     CASE WHEN 	ISNULL(EM.Relacionados,'') <> ''
						THEN LTRIM(RTRIM(EN.Consecutivo)) + ' Relacionados: ' + ISNULL(EM.Relacionados,'')
						WHEN ISNULL(Compl.Consecutivo,'') <> ''
						THEN LTRIM(RTRIM(EN.Consecutivo)) + ' Relacionados: ' + ISNULL(Compl.Consecutivo,'')
					ELSE	EN.Consecutivo	END,
                     ISNULL(ML.MarcoLegal, ''),
                     CE.IdEntregable,
                     ISNULL(are.NombreArea, ''), --CE.AreaResponsable,
                     CE.FechaLimiteEntrega,
                     CE.DiasElaboracion,
                     CE.DiasRevision,
                     CE.DiasAprobacion,
                     CE.DiasAlerta,
					CE.ReceptorAlerta,
                     CE.CreadoPor,
                     CE.CreadoEl,
                     CE.ModificadoPor,
                     CE.ModificadoEl,
                     ISNULL(CE.Activo, 0),
                     CE.FechaLimiteEntregaRegulador,
                     ISNULL(R.ReceptorEntregable, ''),
                     ISNULL(EN.Descripcion, ''),
                     ISNULL(UE.Nombre, ''),
                     AE.IdContratoEntregable,
                     ISNULL(UA.Nombre, ''),
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
						 WHEN APTransporteHidrocarburos = 1 THEN
                             'Transporte de Hidrocarburos'
                         WHEN APAdministracionContratos = 1 THEN
                             'Administración de Contratos'
                         WHEN APQuemaGas = 1 THEN
                             'Quema de Gas'
                         WHEN BitInterno = 1 THEN
                             'Entregable Interno'
                         ELSE
                             'No Especificado'
                     END,
                     ISNULL(et.Etapa, 'No Especificada'),
					 ISNULL(CE.Subfuncion,''),
					 CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')
						ELSE ISNULL(FP.Nombre,'') --+ ' (' + CE.FocalPoint + ')'
					END,
					CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
						ELSE ISNULL(AC.Nombre,'') --+ ' (' + CE.AccountableCompliance + ')'
					END,
					CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
						ELSE ISNULL(ACC.Nombre,'') --+ ' (' + CE.Accountable + ')'
					END,
					ISNULL(ECA.Desarrollo,0),
					ISNULL(ECA.Exploracion,0),
					ISNULL(ECA.Evaluacion,0),
					ISNULL(ECA.Transicion,0),
					ISNULL(ECA.AbandonoArea,0),
					ISNULL(ECA.AbandonoPozo,0)
            ORDER BY CE.IdContratoEntregable
					--COUNT(DISTINCT AE.ActividadID),
     --                COUNT(DISTINCT AR.ActividadID),
     --                COUNT(DISTINCT AP.ActividadID);
        END;
    END;

END;