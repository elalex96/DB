CREATE PROCEDURE [dbo].[EN_EntregablesHistorialMasTresAnios]
    @idUsuario INT,
    @idContrato INT,
    @BitPantallaArea INT
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 09/04/2018
-- Description:	Para que el administrador de contratos
-- =============================================
-- 20200117	BAAC	Se modifica para agregar las columnas que pidio Shell
-- =============================================
-- 11/11/2021 MC Ocultar entregables marcados como NA issue 468 entregables  
-- =============================================
-- =============================================
-- 02/12/21 LDDLCB Se agregan las columnas solicitadas en el issue 493
-- =============================================  
    SET NOCOUNT ON;
    SET LANGUAGE spanish;

    DECLARE @HoyMasTresAnios DATE;
    SET @HoyMasTresAnios = DATEADD(YEAR, 2, GETDATE());

    CREATE TABLE #InstanciasEntregable
    (
        ID INT IDENTITY(1, 1),
        idInstanciaEntregable INT,
        IdContratoEntregable INT
    );
	CREATE NONCLUSTERED INDEX ix_tempInstanciasEntregableidInstanciaEntregable ON #InstanciasEntregable (idInstanciaEntregable);
	CREATE NONCLUSTERED INDEX ix_tempInstanciasEntregableIdContratoEntregable ON #InstanciasEntregable (IdContratoEntregable);

    CREATE TABLE #ResponsablesInstancias
    (
        ID INT IDENTITY(1, 1),
        idInstanciaEntregable INT,
        IdContratoEntregable INT,
        Elaborador NVARCHAR(250),
        Revisores NVARCHAR(250),
        Aprobadores NVARCHAR(250)
    );
	CREATE NONCLUSTERED INDEX ix_tempResponsablesInstanciasidInstanciaEntregable ON #ResponsablesInstancias (idInstanciaEntregable);
	CREATE NONCLUSTERED INDEX ix_tempResponsablesInstanciasidInstanciaIdContratoEntregable ON #ResponsablesInstancias (IdContratoEntregable);

    CREATE TABLE #Areas
    (
        ID INT IDENTITY(1, 1),
        Area NVARCHAR(150)
    );

	CREATE TABLE #Contrato(	
		IdContrato INT
	);	
	CREATE NONCLUSTERED INDEX ix_tempContratoIdContrato ON #Contrato (IdContrato);

	CREATE TABLE #Usuarios 
    (  
        ID INT IDENTITY(1, 1),  
        idInstanciaEntregable INT, 
        Usuario NVARCHAR(250)       
    );  
	CREATE NONCLUSTERED INDEX ix_tempResponsablesInstanciasidInstanciaEntregable ON #Usuarios (idInstanciaEntregable);

	INSERT INTO #Contrato(IdContrato)
	VALUES(@idContrato)

    INSERT INTO #InstanciasEntregable (idInstanciaEntregable, IdContratoEntregable)
    SELECT I.idInstanciaEntregable,
           I.IdContratoEntregable
    FROM #Contrato CO
	JOIN 
		EN_ContratoEntregable	CE	 (NOLOCK)
		ON CO.IdContrato = CE.IdContrato 
        AND	CE.Activo = 1
		AND ISNULL(CE.BitNA,0) <> 1
    JOIN 
		EN_InstanciasEntregable I  (NOLOCK)
		ON	CE.IdContratoEntregable = I.IdContratoEntregable
		AND  I.FechasLimiteElaboracion	>	@HoyMasTresAnios
	JOIN
		EN_Actividad	A  (NOLOCK)
		ON	I.ActividadID	=	A.ActividadID
		AND	A.EstadoID	<>	10003	--Aprobado Internamente   
    JOIN 
		dbo.EN_Entregable E  (NOLOCK)
		ON CE.IdEntregable= E.IdEntregable
		AND E.BitJOA	=	0
	LEFT	JOIN 
		dbo.EN_MarcoLegal	ML  (NOLOCK)
		ON	E.IdMarcoLegal	=	ML.IdMarcoLegal
	LEFT	JOIN
		EN_CatalogoProcesosEntregables	CPE (NOLOCK)
		ON	E.IdEntregable	=	CPE.IdEntregable
    WHERE
          (ML.Activo = 1	OR	E.BitInterno=1)         
		  AND	CPE.IdCatProceso	IS	NULL
		 
 


    INSERT INTO #ResponsablesInstancias (idInstanciaEntregable,
                                         IdContratoEntregable,
                                         Elaborador,
                                         Revisores,
                                         Aprobadores)
    SELECT TI.idInstanciaEntregable,
           TI.IdContratoEntregable,
           CASE ISNULL(EXAE.idUsuario, '')
               WHEN '' THEN
                   UE.Nombre
               ELSE
                   UXE.Nombre
           END AS Elaborador,
          '' Nombres,
           CASE ISNULL(EXAP.idUsuario, '')
               WHEN '' THEN
                   UP.Nombre
               ELSE
                   UXP.Nombre
           END AS aprobadores
    FROM #InstanciasEntregable TI (NOLOCK)
    JOIN 
		dbo.EN_Actividad	AE (NOLOCK)
		ON	TI.IdContratoEntregable	=	AE.IdContratoEntregable
		AND	AE.EstadoID = 10000
    JOIN 
		dbo.AP_Usuario		UE (NOLOCK)
		ON	AE.idUsuario	=	UE.UsuarioID
    JOIN 
		dbo.EN_Actividad	AP (NOLOCK)
		ON	TI.IdContratoEntregable	=	AP.IdContratoEntregable
		AND	AP.EstadoID	=	10002
    JOIN
		dbo.AP_Usuario		UP (NOLOCK)
		ON	AP.idUsuario	=	UP.UsuarioID
    LEFT	JOIN 
		dbo.EN_ExcepcionesActividad	EXAE (NOLOCK)
		ON	AE.ActividadID	=	EXAE.ActividadIDExcepcion
		AND	TI.idInstanciaEntregable	=	EXAE.IdInstanciasEntregables
    LEFT	JOIN 
		dbo.AP_Usuario		UXE (NOLOCK)
		ON	EXAE.idUsuario	=	UXE.UsuarioID
    LEFT	JOIN 
		dbo.EN_ExcepcionesActividad	EXAP (NOLOCK)
		ON	AP.ActividadID	=	EXAP.ActividadIDExcepcion
		AND	TI.idInstanciaEntregable	=	EXAP.IdInstanciasEntregables
    LEFT	JOIN 
		dbo.AP_Usuario			UXP (NOLOCK)
		ON	EXAP.idUsuario	=	UXP.UsuarioID
    GROUP BY TI.idInstanciaEntregable,
             TI.IdContratoEntregable,
            EXAE.idUsuario,
             UE.Nombre,                 
             UXE.Nombre,
             EXAP.idUsuario, 
             UP.Nombre,
             UXP.Nombre             
   

   -- OBTENER REVISORES
   INSERT INTO #Usuarios(idInstanciaEntregable,Usuario)
   SELECT 
   RI.idInstanciaEntregable,
    CASE ISNULL(EXAR.idUsuario, '')  
	WHEN '' THEN  
		UR.Nombre  
	ELSE  
		UXR.Nombre
	END
  FROM #ResponsablesInstancias RI
  JOIN dbo.EN_Actividad AR  (NOLOCK)
	ON RI.IdContratoEntregable = AR.IdContratoEntregable
	AND AR.EstadoID = 10001 
  JOIN 	dbo.AP_Usuario	UR  (NOLOCK)
		ON AR.idUsuario	=	UR.UsuarioID				
  LEFT  JOIN 
		dbo.EN_ExcepcionesActividad	EXAR  (NOLOCK)
		ON AR.ActividadID	=	EXAR.ActividadIDExcepcion  
		AND	RI.idInstanciaEntregable = EXAR.IdInstanciasEntregables 
  LEFT	JOIN 
		dbo.AP_Usuario	UXR  (NOLOCK)
		ON	EXAR.idUsuario	=	UXR.UsuarioID  



  --> GUARDAR REVISORES
  UPDATE RI
  SET RI.Revisores= STUFF(  
	(  
	SELECT REPLACE(REPLACE(REPLACE(', ' + U.Usuario,  
                                    '</revisores>',  
                                    ''  
                                ),  
                        'revisores>',  
                        ''  
                        ),  
                '<revisores>',  
                ''  
                ) AS revisores  
			FROM #Usuarios U 
			WHERE	U.idInstanciaEntregable=RI.idInstanciaEntregable			 
            FOR XML PATH('')  
        ),  
        1,  
        1,  
        '') 
  FROM #ResponsablesInstancias RI



    IF (@BitPantallaArea = 0)
    BEGIN

        SELECT E.IdEntregable,
               A.EstadoID,
               CE.IdContratoEntregable,
               I.idInstanciaEntregable AS idinstanciaEntregable,
               E.DocumentoEntregable AS DocumentoEntregable,
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
               --ISNULL(CO_Regulador.Regulador, '') AS Regulador,
			   ISNULL(RE.ReceptorEntregable,'') As Regulador,
               Es.NombreEstado AS Estatus,
               REPLICATE('0',2-LEN(MONTH(I.FechaInicioElaboracion))) + LTRIM(MONTH(I.FechaInicioElaboracion)) + '-' + DATENAME(MONTH, I.FechaInicioElaboracion) AS mes,
               YEAR(FechasLimiteAprobacion) AS anio,
               ISNULL(ET.Etapa, 'No Especificada') AS Etapa,
               ISNULL(I.FechaCalculadaEntregaReg, I.FechasLimiteAprobacion) AS FechaCalculadaEntregaReg,
               REPLICATE('0',2-LEN(MONTH(I.FechaCalculadaEntregaReg))) + LTRIM(MONTH(I.FechaCalculadaEntregaReg)) + '-' + DATENAME(MONTH, FechaCalculadaEntregaReg) AS mesEntrega,
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
			   I.Activo as ActivoInstancias,
			   ISNULL(CE.Subfuncion,'') AS Subfuncion,
				CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')
					ELSE ISNULL(FP.Nombre,'') 
				END		AS FocalPoint,
				CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
					ELSE ISNULL(AC.Nombre,'') 
				END		AS AccountableCompliance,
				CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
					ELSE ISNULL(ACC.Nombre,'') 
				END		AS Accountable,
				ISNULL(ECA.Desarrollo,0)  AS Desarrollo,
				ISNULL(ECA.Exploracion,0) AS Exploracion,
				ISNULL(ECA.Evaluacion,0)  AS Evaluacion,
				ISNULL(ECA.Transicion,0)  AS Transicion,
				ISNULL(ECA.AbandonoArea,0) AS AbandonoArea,
				ISNULL(ECA.AbandonoPozo,0) AS AbandonoPozo,
				ISNULL(P.NombreProceso+' - '+IPF .Descripcion,'')	AS  NombreProgramacionProcesos,
				CASE 
				WHEN E.BitAwareness = 1 THEN 'SI'
				ELSE 'NO'
			END AS TipoJOA ,
			RG.ResponsableGenerador,
			REE.ReceptorEntregable,
			E.APPozoAlivio as 'ExploracionEvaluacionAbandono',
			E.APCierreDesmantelamientoAbandono AS 'ExploracionEvaluacionDesarrolloAbandono',
			E.APPerforacion as 'EvaluacionDesarrolloAbandono',
			E.APPruebaProduccion as 'InicioProduccion',
			E.APConstruccionCamino as 'Abandono',
			E.APConstruccionLocalizacion as 'TodaVidaContrato',
			E.APRehabilitacionCamino as 'InicioActividadesExploracion',
			E.APRehabilitacionLocalizacion as 'InicioActividadesDesarrollo',
			E.APTomaInformacionSismica as 'InicioActividadesDesarrolloPerfo',
			E.APCorteNucleos as 'InicioActividadesDesarrolloOperacion',
			ISNULL(CE.Radar,0) AS Radar
        FROM #ResponsablesInstancias TI (NOLOCK)
        JOIN 
			EN_InstanciasEntregable	I (NOLOCK)
			ON	TI.idInstanciaEntregable	=	I.idInstanciaEntregable
        JOIN 
			EN_Actividad		A (NOLOCK)
			ON	I.ActividadID = A.ActividadID
        JOIN 
			EN_ContratoEntregable		CE (NOLOCK)
			ON	TI.IdContratoEntregable = CE.IdContratoEntregable
        JOIN 
			EN_Entregable	E (NOLOCK)
			ON	CE.IdEntregable	=	E.IdEntregable
			AND E.BITJOA	=	0
        JOIN 
			dbo.EN_Estado		Es (NOLOCK)
			ON	A.EstadoID	=	Es.EstadoID
        LEFT	JOIN 
			EN_FrecuenciaEntregable (NOLOCK)
			ON	E.IdFrecuenciaEntregable	=	EN_FrecuenciaEntregable.IdFrecuenciaEntregable
        LEFT	JOIN 
			EN_MarcoLegal	AS	ML (NOLOCK)
			ON	E.IdMarcoLegal	=	ML.IdMarcoLegal 
		LEFT JOIN
			EN_ReceptorEntregable	RE (NOLOCK)
			ON	E.IdReceptorEntregable = RE.IdReceptorEntregable
        LEFT	JOIN 
			dbo.EN_Etapa	ET (NOLOCK)
			ON	E.IdEtapa	=	ET.IdEtapa
        LEFT	JOIN 
			dbo.EN_Area	are (NOLOCK)
			ON	CE.IdArea	=	are.idArea
		LEFT	JOIN
			AP_USUARIO FP	(NOLOCK)	-- OBTENER NOMBRE DEL FOCAL POINT
			ON	CE.FocalPoint	=	FP.Usuario
		LEFT	JOIN
			AP_USUARIO AC	(NOLOCK)	-- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
			ON	CE.AccountableCompliance	=	AC.Usuario
		LEFT	JOIN
			AP_USUARIO ACC	(NOLOCK)	-- OBTENER EL NOMBRE DEL ACCOUNTABLE
			ON	CE.Accountable	=	ACC.Usuario
		LEFT	JOIN 
			EN_ENTREGABLE_CONFIGADICIONAL ECA (NOLOCK)
			ON CE.IdEntregable	=	ECA.IdEntregable
		LEFT	JOIN
			EN_InstanciasEntregables_InstanciaActividad IEIA (NOLOCK)
			ON I.idInstanciaEntregable	=	IEIA.idInstanciaEntregable
		LEFT	JOIN
				EN_InstanciasActividades	IA (NOLOCK)
				ON	IEIA.idInstanciaActividad	=	IA.idInstanciaActividad
		LEFT JOIN 
				EN_InstanciasProcesosFecha	IPF (NOLOCK)
				ON	IA.IdInstanciasProcesos	=	IPF.IdInstanciasProcesos
		LEFT JOIN 
				EN_Procesos	P (NOLOCK)
				ON	IPF.IdProceso	=	P.IdProceso
		LEFT JOIN dbo.EN_ResponsableGenerador AS RG (NOLOCK)
					ON E.IdResponsableGenerador = RG.IdResponsableGenerador
		LEFT JOIN dbo.EN_ReceptorEntregable AS REE	(NOLOCK) 
			ON E.IdReceptorEntregable = REE.IdReceptorEntregable
        WHERE CE.IdContrato	=	@idContrato
              AND CE.Activo	=	1
			  AND ISNULL(CE.BitNA,0) <> 1
		ORDER BY FechasLimiteAprobacion ASC;

    END;
    ELSE
    BEGIN

        INSERT INTO #Areas (Area)
        SELECT REPLACE(P.NombrePermiso, 'Acceso a Entregables de ', '')
		FROM dbo.AP_PermisosUsuarios PU (NOLOCK)
        JOIN dbo.AP_Permiso P (NOLOCK)
			ON PU.IdPermiso = P.IdPermiso
        WHERE UsuarioID = @idUsuario
              AND idContrato = @idContrato
              AND P.BitActivo = 1
              AND PU.BitActivo = 1;

        SELECT E.IdEntregable,
               A.EstadoID,
               CE.IdContratoEntregable,
               I.idInstanciaEntregable AS idinstanciaEntregable,
               E.DocumentoEntregable AS DocumentoEntregable,
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
			   ISNULL(RE.ReceptorEntregable,'') As Regulador,
               Es.NombreEstado AS Estatus,
               REPLICATE('0',2-LEN(MONTH(I.FechaInicioElaboracion))) + LTRIM(MONTH(I.FechaInicioElaboracion)) + '-' + DATENAME(MONTH, FechaInicioElaboracion) AS mes,
               YEAR(FechasLimiteAprobacion) AS anio,
               ISNULL(ET.Etapa, 'No Especificada') AS Etapa,
               ISNULL(I.FechaCalculadaEntregaReg, I.FechasLimiteAprobacion) AS FechaCalculadaEntregaReg,
               REPLICATE('0',2-LEN(MONTH(I.FechaCalculadaEntregaReg))) + LTRIM(MONTH(I.FechaCalculadaEntregaReg)) + '-' + DATENAME(MONTH, FechaCalculadaEntregaReg) AS mesEntrega,
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
			    I.Activo as ActivoInstancias,
				ISNULL(CE.Subfuncion,'') AS Subfuncion,
				CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')
					ELSE ISNULL(FP.Nombre,'') 
				END		AS FocalPoint,
				CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
					ELSE ISNULL(AC.Nombre,'') 
				END		AS AccountableCompliance,
				CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
					ELSE ISNULL(ACC.Nombre,'')
				END		AS Accountable,
				ISNULL(ECA.Desarrollo,0)  AS Desarrollo,
				ISNULL(ECA.Exploracion,0) AS Exploracion,
				ISNULL(ECA.Evaluacion,0)  AS Evaluacion,
				ISNULL(ECA.Transicion,0)  AS Transicion,
				ISNULL(ECA.AbandonoArea,0) AS AbandonoArea,
				ISNULL(ECA.AbandonoPozo,0) AS AbandonoPozo,
				ISNULL(P.NombreProceso+' - '+IPF .Descripcion,'')	AS  NombreProgramacionProcesos,
				CASE 
				WHEN E.BitAwareness = 1 THEN 'SI'
				ELSE 'NO'
			END AS TipoJOA ,
			REE.ReceptorEntregable,
			RG.ResponsableGenerador,
			ISNULL(CE.Radar,0) AS Radar
        FROM #ResponsablesInstancias TI (NOLOCK)
        JOIN
			EN_InstanciasEntregable	I (NOLOCK)
			ON TI.idInstanciaEntregable	=	I.idInstanciaEntregable
        JOIN 
			EN_ContratoEntregable	CE (NOLOCK) 
			ON	TI.IdContratoEntregable	=	CE.IdContratoEntregable
			AND	CE.IdContrato	=	@idContrato
        JOIN 
			EN_Entregable	E (NOLOCK) 
			ON	CE.IdEntregable	=	E.IdEntregable
			AND E.BITJOA = 0
        JOIN 
			EN_Actividad	A (NOLOCK) 
			ON	I.ActividadID	=	A.ActividadID
        JOIN 
			dbo.EN_Area	are (NOLOCK) 
			ON	CE.IdArea	=	are.idArea
			AND	are.idContrato	=	@idContrato
        JOIN 
			#Areas	TAR  (NOLOCK)
			ON	are.NombreArea	=	TAR.Area
        JOIN 
			dbo.EN_Estado	Es (NOLOCK)
			ON	A.EstadoID	=	Es.EstadoID
        LEFT	JOIN 
			EN_FrecuenciaEntregable (NOLOCK) 
			ON	E.IdFrecuenciaEntregable	=	EN_FrecuenciaEntregable.IdFrecuenciaEntregable
        LEFT	JOIN 
			EN_MarcoLegal	ML (NOLOCK)
			ON	E.IdMarcoLegal	=	ML.IdMarcoLegal   
		LEFT JOIN
				EN_ReceptorEntregable	RE (NOLOCK)
				ON E.IdReceptorEntregable = RE.IdReceptorEntregable
        LEFT	JOIN 
			dbo.EN_Etapa	ET (NOLOCK) 
			ON	E.IdEtapa	=	ET.IdEtapa
		LEFT	JOIN
			AP_USUARIO	FP (NOLOCK)		-- OBTENER NOMBRE DEL FOCAL POINT
			ON	CE.FocalPoint	=	FP.Usuario
		LEFT	JOIN
			AP_USUARIO	AC (NOLOCK)		-- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
			ON	CE.AccountableCompliance	=	AC.Usuario
		LEFT	JOIN
			AP_USUARIO	ACC (NOLOCK)	-- OBTENER EL NOMBRE DEL ACCOUNTABLE
			ON	CE.Accountable	=	ACC.Usuario
		LEFT	JOIN 
			EN_ENTREGABLE_CONFIGADICIONAL	ECA (NOLOCK)
			ON	CE.IdEntregable	=	ECA.IdEntregable
		LEFT	JOIN
			EN_InstanciasEntregables_InstanciaActividad IEIA (NOLOCK)
			ON I.idInstanciaEntregable	=	IEIA.idInstanciaEntregable
		LEFT	JOIN
				EN_InstanciasActividades	IA (NOLOCK)
				ON	IEIA.idInstanciaActividad	=	IA.idInstanciaActividad
		LEFT JOIN 
				EN_InstanciasProcesosFecha	IPF (NOLOCK)
				ON	IA.IdInstanciasProcesos	=	IPF.IdInstanciasProcesos
		LEFT JOIN 
				EN_Procesos	P (NOLOCK)
				ON	IPF.IdProceso	=	P.IdProceso
		LEFT JOIN dbo.EN_ResponsableGenerador AS RG (NOLOCK)
					ON E.IdResponsableGenerador = RG.IdResponsableGenerador
		LEFT JOIN dbo.EN_ReceptorEntregable AS REE (NOLOCK)
			ON E.IdReceptorEntregable = REE.IdReceptorEntregable
        WHERE	CE.IdContrato	=	@idContrato
				AND	CE.Activo	=	1
				AND ISNULL(CE.BitNA,0) <> 1
        ORDER	BY	FechasLimiteAprobacion	ASC;
    END;

END;