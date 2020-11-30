CREATE PROCEDURE [dbo].[EN_EntregablesHistorial]--10061,3,0,0,0,1  
    @idUsuario INT,  
    @idContrato INT,  
    @BitPantallaArea INT,  
    @BitProcesos INT,  
    @BitTodos INT,
	@BitFinalizados INT  
AS  
BEGIN  
-- =============================================  
-- Author:  Reyna Olvera  
-- Create date: 09/04/2018  
-- Description: Para que el administrador de contratos  
-- =============================================  
-- 20200117 BAAC Se modifica para agregar las columnas que pidio Shell  
-- =============================================  
  
    SET NOCOUNT ON;  
    SET LANGUAGE spanish;  
  
    DECLARE @HoyMasTresAnios DATE;  
    SET @HoyMasTresAnios = DATEADD(YEAR, 2, GETDATE()); 

-- SI ES PERFIL DE SHELL Y SASISOPA SE MARCA EL BIT DE POR AREA
IF 0 < (SELECT COUNT(1)
FROM AP_Usuario U
JOIN AP_PerfilUsuario PU
	ON U.UsuarioId = PU.UsuarioID
JOIN AP_Perfil	P
	ON PU.PerfilID =	P.IdPerfil
WHERE U.USUARIOID = @idUsuario
AND P.IdContrato	=	@idContrato
AND P.DESCRIPCION LIKE '%SASISOPA%')
BEGIN
	SELECT @BitPantallaArea = 1
END
  
    CREATE TABLE #InstanciasEntregable  
    (  
        ID INT IDENTITY(1, 1),  
        idInstanciaEntregable INT,  
        IdContratoEntregable INT,  
        proceso VARCHAR(MAX)  
    );  
  
    CREATE TABLE #ResponsablesInstancias  
    (  
        ID INT IDENTITY(1, 1),  
        idInstanciaEntregable INT,  
        IdContratoEntregable INT,  
        Elaborador NVARCHAR(250),  
        Revisores NVARCHAR(250),  
        Aprobadores NVARCHAR(250),  
        proceso VARCHAR(MAX)  
    );  
  
    CREATE TABLE #Areas  
    (  
        ID INT IDENTITY(1, 1),  
        Area NVARCHAR(150)  
    );  
  
  
    IF (@BitProcesos = 0 AND @BitTodos = 0 AND @BitFinalizados	=	0)  
    BEGIN  
        INSERT INTO #InstanciasEntregable (idInstanciaEntregable, IdContratoEntregable, proceso)  
        SELECT I.idInstanciaEntregable,  
               I.IdContratoEntregable,  
               ''  
        FROM 
			EN_InstanciasEntregable I  
        JOIN 
			EN_ContratoEntregable CE  
			ON I.IdContratoEntregable = CE.IdContratoEntregable  
			AND CE.IdContrato = @idContrato
			AND CE.Activo = 1  
			AND I.Activo	=	1 
		JOIN
			EN_Actividad	A
			ON	I.ActividadID	=	A.ActividadID
			AND	A.EstadoID	<>	10003	--Aprobado Internamente   
		JOIN 
			dbo.EN_Entregable e  
			ON CE.IdEntregable = e.IdEntregable
			AND E.IsActivo = 1 
			AND E.BitJOA	=	0
		LEFT JOIN 
			dbo.EN_MarcoLegal ml  
			ON e.IdMarcoLegal = ml.IdMarcoLegal  
		LEFT JOIN 
			EN_CatalogoProcesosEntregables CPE  
			ON e.IdEntregable = CPE.IdEntregable  
        WHERE 
			CE.IdContrato = @idContrato  
            AND  
              (  
                  ml.Activo = 1  
                  OR e.BitInterno = 1  
              )  
              AND I.FechasLimiteElaboracion < @HoyMasTresAnios  
              AND CPE.IdCatProceso IS NULL 
			  ORDER BY FechasLimiteAprobacion ASC;  
    END;  
    ELSE IF (@BitProcesos = 1)  
    BEGIN  
        INSERT INTO #InstanciasEntregable (idInstanciaEntregable, IdContratoEntregable, proceso)  
        SELECT I.idInstanciaEntregable,  
               I.IdContratoEntregable,  
               C.Nombre AS CatNombre  
		FROM 
			EN_InstanciasEntregable I  
		JOIN 
			EN_ContratoEntregable CE  
			ON I.IdContratoEntregable = CE.IdContratoEntregable  
			AND	CE.IdContrato = @idContrato 
			AND CE.Activo = 1  
			AND I.Activo	=	1  
		JOIN 
			dbo.EN_Entregable e  
			ON CE.IdEntregable = e.IdEntregable 
			AND E.IsActivo = 1
			AND E.BitJOA	=	0 
		JOIN 
			EN_CatalogoProcesosEntregables CPE  
			ON e.IdEntregable = CPE.IdEntregable  
		JOIN 
			EN_catalogoProcesos C  
			ON CPE.idCatProceso = C.idCatProceso  
		LEFT JOIN 
			dbo.EN_MarcoLegal ml  
			ON e.IdMarcoLegal = ml.IdMarcoLegal  
		WHERE 
			CE.IdContrato = @idContrato  
              AND  
              (  
                  ml.Activo = 1  
                  OR e.BitInterno = 1  
              )  
        ORDER BY FechasLimiteAprobacion ASC;  
    END;  
    ELSE IF (@BitTodos = 1)  
    BEGIN  
        INSERT INTO #InstanciasEntregable (idInstanciaEntregable, IdContratoEntregable, proceso)  
        SELECT I.idInstanciaEntregable,  
               I.IdContratoEntregable,  
				''  
			FROM 
				EN_InstanciasEntregable I  
			JOIN 
				EN_ContratoEntregable CE  
				ON I.IdContratoEntregable = CE.IdContratoEntregable  
				AND CE.IdContrato = @idContrato  
				AND CE.Activo = 1   
			JOIN 
				dbo.EN_Entregable e  
				ON CE.IdEntregable = e.IdEntregable 
				AND E.IsActivo = 1
				AND E.BitJOA	=	0
			LEFT	JOIN 
				dbo.EN_MarcoLegal ml  
				ON e.IdMarcoLegal = ml.IdMarcoLegal  
			WHERE 
				CE.IdContrato = @idContrato 
              AND  
              (  
                  ml.Activo = 1  
                  OR e.BitInterno = 1  
              )  
        ORDER BY 
			FechasLimiteAprobacion ASC;  
    END 
	ELSE IF	(@BitFinalizados	=	1)  
	BEGIN
	    INSERT INTO #InstanciasEntregable (idInstanciaEntregable, IdContratoEntregable, proceso)  
        SELECT I.idInstanciaEntregable,  
               I.IdContratoEntregable,  
               ''  
        FROM 
		EN_InstanciasEntregable	I  
        JOIN 
			EN_ContratoEntregable	CE  
			ON	I.IdContratoEntregable	=	CE.IdContratoEntregable  
			AND	CE.IdContrato	=	@idContrato
			AND	CE.Activo	=	1
			AND	I.Activo	=	1  
		JOIN
			EN_Actividad	A
			ON	I.ActividadID	=	A.ActividadID
			AND	A.EstadoID	=	10003	--Aprobado Internamente    
		JOIN 
			dbo.EN_Entregable	e  
			ON	CE.IdEntregable	=	e.IdEntregable  
			AND	E.IsActivo	=	1
			AND E.BitJOA	=	0
        LEFT JOIN 
			dbo.EN_MarcoLegal ml  
			ON	e.IdMarcoLegal	=	ml.IdMarcoLegal  
        WHERE	CE.IdContrato	=	@idContrato 
              AND  
              (  
                  ml.Activo = 1  
                  OR e.BitInterno = 1  
              )  
        ORDER BY FechasLimiteAprobacion ASC; 
	END
  
  
    INSERT INTO #ResponsablesInstancias (idInstanciaEntregable, IdContratoEntregable, Elaborador, Revisores,  
                                         Aprobadores, proceso)  
    SELECT TI.idInstanciaEntregable,  
           TI.IdContratoEntregable,  
           CASE ISNULL(EXAE.idUsuario, '')  
               WHEN '' THEN  
                   UE.Nombre  
               ELSE  
                   UXE.Nombre  
           END AS Elaborador,  
           STUFF(  
           (  
               SELECT REPLACE(REPLACE(REPLACE(   ', ' + CASE ISNULL(EXAR.idUsuario, '')  
                                                            WHEN '' THEN  
                                                                UR.Nombre  
                                                            ELSE  
                                                                UXR.Nombre  
                                                        END,  
                                                 '</revisores>',  
                                                 ''  
                                             ),  
                                      'revisores>',  
                                      ''  
                                     ),  
                              '<revisores>',  
                              ''  
                             ) AS revisores  
				FROM #InstanciasEntregable TIR  
				JOIN 
					dbo.EN_Actividad AR  
					ON TIR.IdContratoEntregable = AR.IdContratoEntregable  
					AND AR.EstadoID = 10001  
				JOIN 
					dbo.AP_Usuario	UR  
					ON AR.idUsuario	=	UR.UsuarioID  
				LEFT	JOIN 
					dbo.EN_ExcepcionesActividad	EXAR  
					ON AR.ActividadID	=	EXAR.ActividadIDExcepcion  
					AND TIR.idInstanciaEntregable	=	EXAR.IdInstanciasEntregables  
				LEFT	JOIN 
					dbo.AP_Usuario	UXR  
					ON	EXAR.idUsuario	=	UXR.UsuarioID  
				WHERE	TI.idInstanciaEntregable	=	TIR.idInstanciaEntregable  
               FOR XML PATH('')  
           ),  
           1,  
           1,  
           ''  
                ) Nombres,  
           CASE ISNULL(EXAP.idUsuario, '')  
               WHEN '' THEN  
                   UP.Nombre  
               ELSE  
                   UXP.Nombre  
           END AS aprobadores,  
           TI.proceso  
    FROM #InstanciasEntregable TI  
        JOIN 
			dbo.EN_Actividad	AE  
			ON TI.IdContratoEntregable = AE.IdContratoEntregable  
			AND AE.EstadoID = 10000  
        JOIN 
			dbo.AP_Usuario	UE  
			ON AE.idUsuario = UE.UsuarioID  
        JOIN 
			dbo.EN_Actividad	AR  
			ON TI.IdContratoEntregable = AR.IdContratoEntregable  
			AND AR.EstadoID = 10001  
        JOIN 
			dbo.AP_Usuario	UR  
			ON AR.idUsuario = UR.UsuarioID  
        JOIN 
			dbo.EN_Actividad	AP  
			ON TI.IdContratoEntregable = AP.IdContratoEntregable  
			AND AP.EstadoID = 10002  
        JOIN 
			dbo.AP_Usuario	UP  
			ON AP.idUsuario = UP.UsuarioID  
        LEFT JOIN 
			dbo.EN_ExcepcionesActividad	EXAE  
			ON AE.ActividadID = EXAE.ActividadIDExcepcion  
			AND TI.idInstanciaEntregable = EXAE.IdInstanciasEntregables  
        LEFT JOIN 
			dbo.AP_Usuario	UXE  
			ON EXAE.idUsuario = UXE.UsuarioID  
        LEFT JOIN 
			dbo.EN_ExcepcionesActividad	EXAR  
			ON AR.ActividadID = EXAR.ActividadIDExcepcion  
			AND TI.idInstanciaEntregable = EXAR.IdInstanciasEntregables  
        LEFT JOIN 
			dbo.AP_Usuario	UXR  
			ON EXAR.idUsuario = UXR.UsuarioID  
        LEFT JOIN
			dbo.EN_ExcepcionesActividad	EXAP  
			ON AP.ActividadID = EXAP.ActividadIDExcepcion  
			AND TI.idInstanciaEntregable = EXAP.IdInstanciasEntregables  
        LEFT JOIN 
			dbo.AP_Usuario	UXP  
			ON EXAP.idUsuario = UXP.UsuarioID  
    GROUP BY TI.idInstanciaEntregable,  
             TI.IdContratoEntregable,  
             CASE ISNULL(EXAE.idUsuario, '')  
                 WHEN '' THEN  
                     UE.Nombre  
                 ELSE  
                     UXE.Nombre  
             END,  
             CASE ISNULL(EXAP.idUsuario, '')  
                 WHEN '' THEN  
                     UP.Nombre  
                 ELSE  
                     UXP.Nombre  
             END,TI.proceso  
    ORDER BY TI.idInstanciaEntregable;  
  
  
    IF (@BitPantallaArea = 0)  
    BEGIN  
        SELECT DISTINCT E.IdEntregable,  
               A.EstadoID,  
               CE.IdContratoEntregable,  
               I.idInstanciaEntregable AS idinstanciaEntregable,  
			   E.DocumentoEntregable  AS DocumentoEntregable,  
               FechasLimiteAprobacion, 
               E.Consecutivo,  
               ISNULL(ML.MarcoLegal, '') AS MarcoLegal,  
               ISNULL(E.TituloAnexo, '') AS TituloAnexo,  
               ISNULL(E.Capitulo, '') AS Capitulo,  
               ISNULL(are.NombreArea, '') AS AreaResponsable,  
               --CE.AreaResponsable,  
               Elaborador,  
               REPLACE(REPLACE(REPLACE(Revisores, '</revisores>', ''), '<revisores>', ''), 'revisores>,', '') AS revisores,  
               Aprobadores AS Aprobador,  
               ISNULL(EN_FrecuenciaEntregable.FrecuenciaEntregable, '') AS FrecuenciaEntregable,  
               ISNULL(CO_Regulador.Regulador, '') AS Regulador,  
               Es.NombreEstado AS Estatus,  
               REPLICATE('0',2-LEN(MONTH(I.FechaInicioElaboracion))) + LTRIM(MONTH(I.FechaInicioElaboracion)) + '-' + DATENAME(MONTH, I.FechaInicioElaboracion) AS mes,  
               YEAR(FechaCalculadaEntregaReg) AS anio,  
               ISNULL(ET.Etapa, 'No Especificada') AS Etapa,  
               ISNULL(I.FechaCalculadaEntregaReg, I.FechasLimiteAprobacion) AS FechaCalculadaEntregaReg,  
               REPLICATE('0',2-LEN(MONTH(I.FechaCalculadaEntregaReg))) + LTRIM(MONTH(I.FechaCalculadaEntregaReg)) + '-' +DATENAME(MONTH, I.FechaCalculadaEntregaReg) AS mesEntrega,  
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
			I.FechaRealEntregaRegulador AS FechaRealEntrega,  
			ISNULL(I.BitContieneAcuse, 0) AS BitContieneAcuse,  
			I.Activo AS ActivoInstancias,  
			TI.proceso AS CatProceso,  
			ISNULL(CE.Subfuncion,'') AS Subfuncion,  
			CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')  
			ELSE ISNULL(FP.Nombre,'') --+ ' (' + CE.FocalPoint + ')'  
			END  AS FocalPoint,  
			CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')  
			ELSE ISNULL(AC.Nombre,'') --+ ' (' + CE.AccountableCompliance + ')'  
			END  AS AccountableCompliance,  
			CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')  
			ELSE ISNULL(ACC.Nombre,'') --+ ' (' + CE.Accountable + ')'  
			END  AS Accountable,  
			ISNULL(ECA.Desarrollo,0)  AS Desarrollo,  
			ISNULL(ECA.Exploracion,0) AS Exploracion,  
			ISNULL(ECA.Evaluacion,0)  AS Evaluacion,  
			ISNULL(ECA.Transicion,0)  AS Transicion,  
			ISNULL(ECA.AbandonoArea,0) AS AbandonoArea,  
			ISNULL(ECA.AbandonoPozo,0) AS AbandonoPozo,
			ISNULL(P.NombreProceso+' - '+IPF .Descripcion,'')	AS  NombreProgramacionProcesos  
		FROM 
			#ResponsablesInstancias TI  
		JOIN 
			EN_InstanciasEntregable I  
			ON TI.idInstanciaEntregable = I.idInstanciaEntregable  
		JOIN 
			EN_Actividad A  
			ON I.ActividadID = A.ActividadID  
		JOIN 
			EN_ContratoEntregable CE  
			ON I.IdContratoEntregable = CE.IdContratoEntregable  
		INNER JOIN 
			EN_Entregable E  
			ON CE.IdEntregable = E.IdEntregable
			AND E.BitJOA	=	0
		JOIN 
			dbo.EN_Estado Es  
			ON A.EstadoID = Es.EstadoID  
		LEFT JOIN 
			EN_FrecuenciaEntregable  
			ON E.IdFrecuenciaEntregable = EN_FrecuenciaEntregable.IdFrecuenciaEntregable  
		LEFT JOIN 
			EN_MarcoLegal AS ML  
			ON E.IdMarcoLegal = ML.IdMarcoLegal  
		LEFT JOIN 
			CO_Regulador  
			ON E.IdRegulador = CO_Regulador.IdRegulador  
		LEFT JOIN 
			dbo.EN_Etapa ET 
			ON E.IdEtapa = ET.IdEtapa  
		LEFT JOIN 
			dbo.EN_Area are  
			ON CE.IdArea = are.idArea  
		LEFT JOIN  
			AP_USUARIO FP  -- OBTENER NOMBRE DEL FOCAL POINT  
			ON CE.FocalPoint = FP.Usuario  
		LEFT JOIN  
			AP_USUARIO AC  -- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE  
			ON CE.AccountableCompliance = AC.Usuario  
		LEFT JOIN  
			AP_USUARIO ACC  -- OBTENER EL NOMBRE DEL ACCOUNTABLE  
			ON CE.Accountable = ACC.Usuario  
		LEFT JOIN   
			EN_ENTREGABLE_CONFIGADICIONAL ECA  
			ON CE.IdEntregable = ECA.IdEntregable

		LEFT	JOIN
			EN_InstanciasEntregables_InstanciaActividad IEIA
			ON I.idInstanciaEntregable	=	IEIA.idInstanciaEntregable
		LEFT	JOIN
			EN_InstanciasActividades	IA
			ON	IEIA.idInstanciaActividad	=	IA.idInstanciaActividad
		LEFT JOIN 
			EN_InstanciasProcesosFecha	IPF
			ON	IA.IdInstanciasProcesos	=	IPF.IdInstanciasProcesos
		LEFT JOIN 
			EN_Procesos	P
			ON	IPF.IdProceso	=	P.IdProceso
		WHERE 
			CE.IdContrato = @idContrato 
			 AND E.IsActivo = 1  
		ORDER BY 
			FechasLimiteAprobacion ASC;  
    END;  
    ELSE  
    BEGIN  
        INSERT INTO #Areas (Area)  
        SELECT REPLACE(P.NombrePermiso, 'Acceso a Entregables de ', '')  
        FROM dbo.AP_PermisosUsuarios PU  
            JOIN dbo.AP_Permiso P  
                ON PU.IdPermiso = P.IdPermiso  
        WHERE UsuarioID = @idUsuario  
              AND idContrato = @idContrato  
              AND P.BitActivo = 1  
              AND PU.BitActivo = 1;  
  
        SELECT DISTINCT E.IdEntregable,  
               A.EstadoID,  
               CE.IdContratoEntregable,  
               I.idInstanciaEntregable AS idinstanciaEntregable,  
               E.DocumentoEntregable  AS DocumentoEntregable,  
               FechasLimiteAprobacion,  
               E.Consecutivo,  
               ISNULL(ML.MarcoLegal, '') AS MarcoLegal,  
               ISNULL(E.TituloAnexo, '') AS TituloAnexo,  
               ISNULL(E.Capitulo, '') AS Capitulo,  
               ISNULL(are.NombreArea, '') AS AreaResponsable,  
               Elaborador,  
               REPLACE(REPLACE(REPLACE(Revisores, '</revisores>', ''), '<revisores>', ''), 'revisores>,', '') AS revisores,  
               Aprobadores AS Aprobador,  
               ISNULL(EN_FrecuenciaEntregable.FrecuenciaEntregable, '') AS FrecuenciaEntregable,  
               ISNULL(CO_Regulador.Regulador, '') AS Regulador,  
               Es.NombreEstado AS Estatus,  
               REPLICATE('0',2-LEN(MONTH(I.FechaInicioElaboracion))) + LTRIM(MONTH(I.FechaInicioElaboracion)) + '-' + DATENAME(MONTH, FechaInicioElaboracion) AS mes,  
               YEAR(FechaCalculadaEntregaReg) AS anio,  
               ISNULL(ET.Etapa, 'No Especificada') AS Etapa,  
               ISNULL(I.FechaCalculadaEntregaReg, I.FechasLimiteAprobacion) AS FechaCalculadaEntregaReg,  
               REPLICATE('0',2-LEN(MONTH(I.FechaCalculadaEntregaReg))) + LTRIM(MONTH(I.FechaCalculadaEntregaReg)) + '-' +DATENAME(MONTH, I.FechaCalculadaEntregaReg) AS mesEntrega,  
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
               I.FechaRealEntregaRegulador AS FechaRealEntrega,  
               ISNULL(I.BitContieneAcuse, 0) AS BitContieneAcuse,  
               I.Activo AS ActivoInstancias,  
               TI.proceso AS CatProceso,  
      ISNULL(CE.Subfuncion,'') AS Subfuncion,  
    CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')  
     ELSE ISNULL(FP.Nombre,'') --+ ' (' + CE.FocalPoint + ')'  
    END  AS FocalPoint,  
    CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')  
     ELSE ISNULL(AC.Nombre,'') --+ ' (' + CE.AccountableCompliance + ')'  
    END  AS AccountableCompliance,  
    CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')  
     ELSE ISNULL(ACC.Nombre,'') --+ ' (' + CE.Accountable + ')'  
    END  AS Accountable,  
    ISNULL(ECA.Desarrollo,0)  AS Desarrollo,  
    ISNULL(ECA.Exploracion,0) AS Exploracion,  
    ISNULL(ECA.Evaluacion,0)  AS Evaluacion,  
    ISNULL(ECA.Transicion,0)  AS Transicion,  
    ISNULL(ECA.AbandonoArea,0) AS AbandonoArea,  
    ISNULL(ECA.AbandonoPozo,0) AS AbandonoPozo,
	ISNULL(P.NombreProceso+' - '+IPF .Descripcion,'')	AS  NombreProgramacionProcesos  
	FROM 
		#ResponsablesInstancias TI  
	JOIN 
		EN_InstanciasEntregable I  
		ON TI.idInstanciaEntregable = I.idInstanciaEntregable  
	JOIN 
		EN_ContratoEntregable CE  
		ON I.IdContratoEntregable = CE.IdContratoEntregable  
		AND CE.IdContrato = @idContrato  
	JOIN 
		EN_Entregable E  
		ON CE.IdEntregable = E.IdEntregable 
		AND E.BitJOA	=	0
	JOIN 
		EN_Actividad A  
		ON I.ActividadID = A.ActividadID  
	JOIN 
		dbo.EN_Area are  
		ON CE.IdArea = are.idArea  
		AND are.idContrato = @idContrato  
	JOIN 
		#Areas TAR  
		ON are.NombreArea = TAR.Area  
	JOIN 
		dbo.EN_Estado Es  
		ON A.EstadoID = Es.EstadoID  
	LEFT JOIN 
		EN_FrecuenciaEntregable  
		ON E.IdFrecuenciaEntregable = EN_FrecuenciaEntregable.IdFrecuenciaEntregable  
	LEFT JOIN 
		EN_MarcoLegal AS ML  
		ON E.IdMarcoLegal = ML.IdMarcoLegal  
	LEFT JOIN 
		CO_Regulador  
		ON E.IdRegulador = CO_Regulador.IdRegulador  
	LEFT JOIN dbo.EN_Etapa ET  
		ON E.IdEtapa = ET.IdEtapa  
	LEFT JOIN  
		AP_USUARIO FP  -- OBTENER NOMBRE DEL FOCAL POINT  
		ON CE.FocalPoint = FP.Usuario  
	LEFT JOIN  
		AP_USUARIO AC  -- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE  
		ON CE.AccountableCompliance = AC.Usuario  
	LEFT JOIN  
		AP_USUARIO ACC  -- OBTENER EL NOMBRE DEL ACCOUNTABLE  
		ON CE.Accountable = ACC.Usuario  
	LEFT JOIN   
		EN_ENTREGABLE_CONFIGADICIONAL ECA  
		ON CE.IdEntregable = ECA.IdEntregable

	LEFT	JOIN
			EN_InstanciasEntregables_InstanciaActividad IEIA
			ON I.idInstanciaEntregable	=	IEIA.idInstanciaEntregable
	LEFT	JOIN
		EN_InstanciasActividades	IA
		ON	IEIA.idInstanciaActividad	=	IA.idInstanciaActividad
	LEFT JOIN 
		EN_InstanciasProcesosFecha	IPF
		ON	IA.IdInstanciasProcesos	=	IPF.IdInstanciasProcesos
	LEFT JOIN 
			EN_Procesos	P
			ON	IPF.IdProceso	=	P.IdProceso
	WHERE 
		CE.IdContrato = @idContrato  AND E.IsActivo = 1  
	ORDER BY 
		FechasLimiteAprobacion ASC;  
END;  
END;  
