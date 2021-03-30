USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'EN_SHELL_ObtenerDocumentosEntregables'
)
    DROP PROCEDURE EN_SHELL_ObtenerDocumentosEntregables;
GO 
/****** Object:  StoredProcedure [dbo].[EN_SHELL_ObtenerDocumentosEntregables]    Script Date: 25/03/2021 04:58:48 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [dbo].[EN_SHELL_ObtenerDocumentosEntregables] 3,10061
CREATE PROCEDURE [dbo].[EN_SHELL_ObtenerDocumentosEntregables] --3,10061
    @ContratoId INT,
    @UsuarioId INT   
AS
BEGIN

		DECLARE @Lista AS TABLE(
			ID INT IDENTITY(1,1),			
			IDPadre INT,
			Titulo NVARCHAR(MAX),
			EtapaId NVARCHAR(MAX),			
			ReceptorEntregableId INT,
			PozoInstalacionId INT,
			MarcoLegalId INT,	
			EntregableId INT,	
			Frecuencia NVARCHAR(MAX),
			FechaProgramadaEntrega DATETIME,	
			DocumentoEntregableId INT,
			CantidadArchivos INT,
			Detalle NVARCHAR(MAX),
			Icono NVARCHAR(MAX),
			Acciones NVARCHAR(MAX),
			Mime  NVARCHAR(MAX),
			Nivel INT,
			TipoArchivo NVARCHAR(MAX),
			FechaCarga DATETIME,	
			CargadoPor NVARCHAR(MAX),
			Origen NVARCHAR(MAX))


			DECLARE @Documentos AS TABLE(
			DocumentoEntregableId INT,
			NombreArchivo NVARCHAR(MAX), 
			idTipoArchivo INT,
			TipoArchivo NVARCHAR(MAX),
			IdEntregable INT, 
			IdReceptorEntregable INT, 
			IdEtapa INT, --> SE COLOCA POR DEFAULT LA ETAPA EN -1 CUANDO ES NULL PARA MANDAR A CARPETA GENERAL
			IdMarcoLegal INT, 	
			FechaCarga DATETIME,
			NoVersion INT, 
			Mime NVARCHAR(MAX), 
			EntregableInstanciaId INT,			
			FrecuenciaEntregable NVARCHAR(MAX),
			FechaProgramadaEntrega DATETIME,
			CargadoPor NVARCHAR(MAX),
			Origen NVARCHAR(MAX),	
			EsDeProceso BIT,
			InstalacionId INT,		
			Pozo NVARCHAR(MAX))

 --   IF OBJECT_ID('tempdb.dbo.#Documentos', 'U') IS NOT NULL
	--DROP TABLE #Documentos
	--IF OBJECT_ID('tempdb.dbo.#DocumentosVersion', 'U') IS NOT NULL
	--DROP TABLE #DocumentosVersion
	
	/*OBTENER DOCUMENTOS DE ENTREGABLES*/
	BEGIN
	 /*OBTENER TODOS LOS DOCUMENTOS DEL CONTRATO - CON ESTATUS APROBADO INTERNAMENTE*/
	 INSERT INTO @Documentos(
	 DocumentoEntregableId,
	 NombreArchivo, 
	 idTipoArchivo,
	 TipoArchivo,
	 IdEntregable, 
	 IdReceptorEntregable, 
	 IdEtapa, --> SE COLOCA POR DEFAULT LA ETAPA EN -1 CUANDO ES NULL PARA MANDAR A CARPETA GENERAL
	 IdMarcoLegal, 	
	 FechaCarga,
	 NoVersion, 
	 Mime, 
	 EntregableInstanciaId,	
	 FrecuenciaEntregable,
	 FechaProgramadaEntrega,
	 CargadoPor,
	 Origen,
	 EsDeProceso,	 
	 Pozo,
	 InstalacionId)

     SELECT DISTINCT 
	 ED.DocumentoEntregableId,
	 ED.NombreArchivo, 
	 ED.idTipoArchivo,
	 T.Nombrearchivo AS TipoArchivo,
	 E.IdEntregable, 
	 E.IdReceptorEntregable, 
	 ISNULL(E.IdEtapa,-1) AS IdEtapa, --> SE COLOCA POR DEFAULT LA ETAPA EN -1 CUANDO ES NULL PARA MANDAR A CARPETA GENERAL
	 E.IdMarcoLegal, 	
	 ED.CreadoEl AS FechaCarga,
	 DV.N_version AS NoVersion, 
	 ED.Meta AS Mime, 
	 EI.idInstanciaEntregable AS EntregableInstanciaId,	 
	 FE.FrecuenciaEntregable,
	 EI.FechaCalculadaEntregaReg AS FechaProgramadaEntrega,
	 U.Nombre AS CargadoPor,
	 'ENTREGABLES' AS Origen,		
	 CASE WHEN  ISNULL(IPF.IdInstanciasProcesos,0) > 0 THEN 1 ELSE 0 END  EsDeProceso,
	 COI.NombreInstalacion AS Pozo,
	 P.IdInstalacion AS IdInstalacion
	FROM EN_ContratoEntregable CE	
	JOIN EN_InstanciasEntregable EI
			ON CE.IdContratoEntregable			=	EI.IdContratoEntregable	
			AND	CE.IdContrato					=	@ContratoId
			AND EI.Activo						=	1	
	JOIN EN_Entregable E
			ON CE.IdEntregable					=	E.IdEntregable		
			AND ISNULL(E.IsActivo,0)			=	1	  
			AND E.BitJOA						=	0 
	JOIN    EN_Actividad AE
			ON EI.ActividadID=AE.ActividadID
			AND EI.IdContratoEntregable			=	AE.IdContratoEntregable
			AND AE.EstadoID						=	10003 --> APROBADOR INTERNAMENTE -->EN_Estado
	JOIN EN_HistorialAprobacionesLineaTiempo ELT
			ON EI.idInstanciaEntregable			=	ELT.idInstanciaEntregable
			AND ELT.idTipoOperacion				=	4 -->ARCHIVOS DE APROBACIÓN -->EN_TipoOperacion
	JOIN EN_DocumentoVersion DV 			
			ON EI.idInstanciaEntregable			=	DV.idInstanciaEntregable	
			AND ELT.IdLineaTiempo=DV.N_version
			AND DV.Activo						=	1
	JOIN EN_EntregableDocumento ED
			ON DV.idInstanciaEntregable			=	ED.idInstanciaEntregable
			AND DV.DocumentoEntregableId		=	ED.DocumentoEntregableId
			AND ED.idContratoEntregable			=	CE.IdContratoEntregable			
	JOIN EN_TipoArchivo T   
			ON	ED.idTipoArchivo				=	T.idTipoArchivo		
	LEFT JOIN EN_FrecuenciaEntregable	FE
			ON E.IdFrecuenciaEntregable			=	FE.IdFrecuenciaEntregable	
	LEFT JOIN AP_Usuario U						
			ON 	ED.CreadoPor					=	U.UsuarioID	
	LEFT	JOIN
			EN_InstanciasEntregables_InstanciaActividad IEIA
			ON EI.idInstanciaEntregable	=	IEIA.idInstanciaEntregable
	LEFT	JOIN
		EN_InstanciasActividades	IA
		ON	IEIA.idInstanciaActividad	=	IA.idInstanciaActividad
	LEFT JOIN 
		EN_InstanciasProcesosFecha	IPF
		ON	IA.IdInstanciasProcesos	=	IPF.IdInstanciasProcesos
	LEFT JOIN 
			EN_Procesos	P
			ON	IPF.IdProceso	=	P.IdProceso
	LEFT JOIN 
			CO_Instalacion COI
			ON P.IdInstalacion = COI.IdInstalacion
	WHERE 
	ED.Activo =	1	

	/*OBTENER LA ULTIMA VERSION DE LAS INSTANCIAS*/
	SELECT 
	EntregableInstanciaId,	
	MAX(NoVersion) AS NoVersion
	INTO #DocumentosVersion
	FROM @Documentos
	GROUP BY
	EntregableInstanciaId
					
	/*ELIMINAR LOS DOCUMENTOS DE LA TABLA TEMPORAL QUE NO SON PARTE DE LA ULTIMA VERSIÓN DE LOS DOCUMENTOS*/
	DELETE D
	FROM @Documentos D
	LEFT JOIN #DocumentosVersion DV
		ON D.EntregableInstanciaId	=	DV.EntregableInstanciaId
		AND	D.NoVersion				=	DV.NoVersion
	WHERE DV.NoVersion IS NULL

	END 

	/*OBTENER LOS DOCUMENTOS DE LAS CARPETAS GENERALES*/
	BEGIN
		
		INSERT INTO @Documentos(
		 DocumentoEntregableId,
		 NombreArchivo, 
		 idTipoArchivo,
		 TipoArchivo,
		 IdEntregable, 
		 IdReceptorEntregable, 
		 IdEtapa, --> SE COLOCA POR DEFAULT LA ETAPA EN -1 CUANDO ES NULL PARA MANDAR A CARPETA GENERAL
		 IdMarcoLegal, 	
		 FechaCarga,
		 NoVersion, 
		 Mime, 
		 EntregableInstanciaId,		 
		 FrecuenciaEntregable,
		 FechaProgramadaEntrega,
		 CargadoPor,
		 Origen,
		 InstalacionId,
		 EsDeProceso)
		SELECT 
		 D.DocumentoId AS DocumentoEntregableId,
		 D.NombreArchivo, 
		 NULL AS idTipoArchivo,
		 TipoArchivo AS TipoArchivo,
		 D.EntregableId AS IdEntregable, 
		 D.ReceptorId AS IdReceptorEntregable, 
		 ISNULL(D.EtapaId,-1) AS IdEtapa, --> SE COLOCA POR DEFAULT LA ETAPA EN -1 CUANDO ES NULL PARA MANDAR A CARPETA GENERAL
		 D.MarcoLegalId AS IdMarcoLegal, 	
		 D.CreadoEl AS FechaCarga,
		 1 AS NoVersion, 
		 D.Meta AS Mime, 
		 NULL AS EntregableInstanciaId,		
		 NULL AS FrecuenciaEntregable,
		 NULL AS FechaProgramadaEntrega,
		 U.Nombre AS CargadoPor,
		 'GENERAL' AS Origen,
		 D.InstalacionId,
		  CASE WHEN  ISNULL(D.InstalacionId,0) > 0 THEN 1 ELSE 0 END  EsDeProceso
		FROM EN_DocumentoGeneral D
		LEFT JOIN AP_Usuario U						
				ON 	D.CreadoPor	=	U.UsuarioID	
		WHERE D.ContratoId=@ContratoId

	END 

	/*CREACIÓN DE LOS NIVELES DE LOS DOCUMENTOS DE ORIGEN DE ENTREGABLES*/
	BEGIN
	
	 --NIVEL 1 --ETAPAS
	 INSERT INTO @Lista(IDPadre,Titulo,EtapaId,Nivel,Detalle,CantidadArchivos,TipoArchivo)

	 SELECT 
	 NULL,
	 E.Etapa,
	 CE.EtapaId,
	 1,
	 'Etapa',
	 COUNT(D.DocumentoEntregableId),
	 'Carpeta'
	 FROM CO_ContratoEtapas CE
	 JOIN EN_Etapa E
		ON		CE.EtapaId		=	E.IdEtapa
	 JOIN @Documentos D
		ON		CE.EtapaId		=	D.IdEtapa
	 WHERE CE.ContratoId		=	@ContratoId
	 AND CE.Activo				=	1		
	 GROUP BY 	
	 E.Etapa,
	 CE.EtapaId	
	 ORDER BY E.Etapa ASC
	 	 
	--NIVEL 2 REGULADORES 
	INSERT INTO @Lista(IDPadre,EtapaId,Titulo,ReceptorEntregableId,Nivel,Detalle,CantidadArchivos,TipoArchivo)
	SELECT 
	LD.ID,	
	LD.EtapaId,
	RE.ReceptorEntregable,
	RE.IdReceptorEntregable,
	2,
	'Receptor',
	COUNT(D.DocumentoEntregableId),
	'Carpeta'
	FROM @Lista LD
	JOIN @Documentos D
		ON			LD.EtapaId				=	D.IdEtapa				
	JOIN EN_ReceptorEntregable RE 
		ON			D.IdReceptorEntregable	=	RE.IdReceptorEntregable
	WHERE D.EsDeProceso = 0
	GROUP BY 	
	LD.ID,	
	LD.EtapaId,
	RE.ReceptorEntregable,
	RE.IdReceptorEntregable
	ORDER BY RE.ReceptorEntregable ASC

	--NIVEL 2 POZOS
	INSERT INTO @Lista(IDPadre,EtapaId,Titulo,PozoInstalacionId,Nivel,Detalle,CantidadArchivos,TipoArchivo)
	SELECT 
	LD.ID,	
	LD.EtapaId,	
	D.Pozo,
	D.InstalacionId,
	2,
	'Pozo',
	COUNT(D.DocumentoEntregableId),
	'Carpeta'
	FROM @Lista LD
	JOIN @Documentos D
		ON			LD.EtapaId				=	D.IdEtapa	
	WHERE D.EsDeProceso = 1
	GROUP BY 	
	LD.ID,	
	LD.EtapaId,
	D.InstalacionId,
	D.Pozo
	ORDER BY D.Pozo ASC

	
	--NIVEL 3 MARCOS LEGALES
	INSERT INTO @Lista(IDPadre,EtapaId,ReceptorEntregableId,Titulo,MarcoLegalId,Nivel,Detalle,CantidadArchivos,TipoArchivo)
	SELECT 
	LD.ID,	
	LD.EtapaId,	
	LD.ReceptorEntregableId,
	ML.MarcoLegal,
	ML.IdMarcoLegal,
	3,
	'Marco Legal',
	COUNT(D.DocumentoEntregableId),
	'Carpeta'
	FROM @Lista LD
	JOIN @Documentos D
		ON			LD.EtapaId						=	D.IdEtapa
		AND			LD.ReceptorEntregableId			=	D.IdReceptorEntregable
	JOIN EN_MarcoLegal ML
		ON			D.IdMarcoLegal			=	ML.IdMarcoLegal
	WHERE D.EsDeProceso = 0
	GROUP BY 
	LD.ID,	
	LD.EtapaId,	
	LD.ReceptorEntregableId,
	ML.MarcoLegal,
	ML.IdMarcoLegal
	ORDER BY ML.MarcoLegal ASC

	--NIVEL 3 MARCOS LEGALES DE LOS POZOS
	INSERT INTO @Lista(IDPadre,EtapaId,PozoInstalacionId,Titulo,MarcoLegalId,Nivel,Detalle,CantidadArchivos,TipoArchivo)
	SELECT 
	LD.ID,	
	LD.EtapaId,	
	LD.PozoInstalacionId,
	ML.MarcoLegal,
	ML.IdMarcoLegal,
	3,
	'Marco Legal',
	COUNT(D.DocumentoEntregableId),
	'Carpeta'
	FROM @Lista LD
	JOIN @Documentos D
		ON			LD.EtapaId						=	D.IdEtapa
		AND			LD.PozoInstalacionId			=	D.InstalacionId
	JOIN EN_MarcoLegal ML
		ON			D.IdMarcoLegal			=	ML.IdMarcoLegal
	WHERE D.EsDeProceso = 1
	GROUP BY 
	LD.ID,	
	LD.EtapaId,	
	LD.PozoInstalacionId,
	ML.MarcoLegal,
	ML.IdMarcoLegal
	ORDER BY ML.MarcoLegal ASC


	--NIVEL 3 AGREGAR UN MARCO LEGAL COMO GENERAL POR CADA REGULADOR DE CADA ETAPA ESTO PARA LOS ARCHIVOS GENERALES
	INSERT INTO @Lista(IDPadre,EtapaId,ReceptorEntregableId,Titulo,MarcoLegalId,Nivel,Detalle,CantidadArchivos,TipoArchivo)
	SELECT 
	LD.ID,	
	LD.EtapaId,	
	LD.ReceptorEntregableId,
	'General',
	-1,
	 3, 
	'Marco Legal',
	0,
	'Carpeta'
	FROM @Lista LD	
	WHERE LD.Nivel=2	
	AND LD.PozoInstalacionId IS NULL
	GROUP BY 
	LD.ID,	
	LD.EtapaId,	
	LD.ReceptorEntregableId

	--NIVEL 3 AGREGAR UN MARCO LEGAL COMO GENERAL POR CADA REGULADOR DE CADA ETAPA ESTO PARA LOS ARCHIVOS GENERALES --PARA LOS POZOS
	INSERT INTO @Lista(IDPadre,EtapaId,PozoInstalacionId,Titulo,MarcoLegalId,Nivel,Detalle,CantidadArchivos,TipoArchivo)
	SELECT 
	LD.ID,	
	LD.EtapaId,	
	LD.PozoInstalacionId,
	'General',
	-1,
	 3, 
	'Marco Legal',
	0,
	'Carpeta'
	FROM @Lista LD	
	WHERE LD.Nivel=2	
	AND LD.PozoInstalacionId IS NOT NULL
	GROUP BY 
	LD.ID,	
	LD.EtapaId,	
	LD.PozoInstalacionId
		
	--NIVEL 4  ENTREGABLES
	INSERT INTO @Lista(IDPadre,EtapaId,ReceptorEntregableId,MarcoLegalId,Titulo,EntregableId,Frecuencia,Nivel,Detalle,CantidadArchivos,TipoArchivo)
	SELECT 
	LD.ID,	
	LD.EtapaId,	
	LD.ReceptorEntregableId,
	LD.MarcoLegalId,
	E.DocumentoEntregable,
	E.IdEntregable,
	D.FrecuenciaEntregable,
	4,
	'Entregable',
	COUNT(D.DocumentoEntregableId),
	'Carpeta'
	FROM @Lista LD
	JOIN @Documentos D
		ON			LD.EtapaId					=	D.IdEtapa
		AND			LD.ReceptorEntregableId		=	D.IdReceptorEntregable
		AND			LD.MarcoLegalId				=	D.IdMarcoLegal
	JOIN EN_Entregable E
		ON			D.IdEntregable			=	E.IdEntregable
	WHERE D.EsDeProceso = 0
	GROUP BY 
	LD.ID,	
	LD.EtapaId,	
	LD.ReceptorEntregableId,
	LD.MarcoLegalId,
	E.DocumentoEntregable,
	E.IdEntregable,
	D.FrecuenciaEntregable
	ORDER BY MIN(D.FechaCarga) ASC

	--NIVEL 4  ENTREGABLES PARA LOS POZOS
	INSERT INTO @Lista(IDPadre,EtapaId,PozoInstalacionId,MarcoLegalId,Titulo,EntregableId,Frecuencia,Nivel,Detalle,CantidadArchivos,TipoArchivo)
	SELECT 
	LD.ID,	
	LD.EtapaId,	
	LD.PozoInstalacionId,
	LD.MarcoLegalId,
	E.DocumentoEntregable,
	E.IdEntregable,
	D.FrecuenciaEntregable,
	4,
	'Entregable',
	COUNT(D.DocumentoEntregableId),
	'Carpeta'
	FROM @Lista LD
	JOIN @Documentos D
		ON			LD.EtapaId					=	D.IdEtapa
		AND			LD.PozoInstalacionId		=	D.InstalacionId
		AND			LD.MarcoLegalId				=	D.IdMarcoLegal
	JOIN EN_Entregable E
		ON			D.IdEntregable			=	E.IdEntregable
	WHERE D.EsDeProceso = 1
	GROUP BY 
	LD.ID,	
	LD.EtapaId,	
	LD.PozoInstalacionId,
	LD.MarcoLegalId,
	E.DocumentoEntregable,
	E.IdEntregable,
	D.FrecuenciaEntregable
	ORDER BY MIN(D.FechaCarga) ASC
	
	--NIVEL 5 DOCUMENTOS 
	INSERT INTO @Lista(IDPadre,EtapaId,ReceptorEntregableId,MarcoLegalId,EntregableId,Frecuencia,FechaProgramadaEntrega,Titulo,DocumentoEntregableId,Nivel,Detalle,CantidadArchivos,Mime,TipoArchivo,FechaCarga,CargadoPor,Origen)
	SELECT 
	LD.ID,	
	LD.EtapaId,	
	LD.ReceptorEntregableId,
	LD.MarcoLegalId,	
	LD.EntregableId,
	LD.Frecuencia,
	D.FechaProgramadaEntrega,
	D.NombreArchivo,
	D.DocumentoEntregableId,
	5,
	D.TipoArchivo,
	COUNT(D.DocumentoEntregableId),
	D.Mime,
	D.TipoArchivo,
	D.FechaCarga,
	D.CargadoPor,
	D.Origen	
	FROM @Lista LD
	JOIN @Documentos D
		ON			LD.EtapaId					=	D.IdEtapa
		AND			LD.ReceptorEntregableId		=	D.IdReceptorEntregable
		AND			LD.MarcoLegalId				=	D.IdMarcoLegal
		AND			LD.EntregableId				=	D.IdEntregable
	WHERE D.EsDeProceso = 0
	GROUP BY 
	LD.ID,	
	LD.EtapaId,	
	LD.ReceptorEntregableId,
	LD.MarcoLegalId,	
	LD.EntregableId,
	LD.Frecuencia,
	D.NombreArchivo,
	D.DocumentoEntregableId,
	D.TipoArchivo,
	D.NoVersion,
	D.Mime,
	D.FechaProgramadaEntrega,
	D.TipoArchivo,
	D.FechaCarga,
	D.CargadoPor,
	D.Origen
	ORDER BY MIN(D.FechaCarga) ASC
	
	--NIVEL 5 DOCUMENTOS PARA POZOS
	INSERT INTO @Lista(IDPadre,EtapaId,PozoInstalacionId,MarcoLegalId,EntregableId,Frecuencia,FechaProgramadaEntrega,Titulo,DocumentoEntregableId,Nivel,Detalle,CantidadArchivos,Mime,TipoArchivo,FechaCarga,CargadoPor,Origen)
	SELECT 
	LD.ID,	
	LD.EtapaId,	
	LD.PozoInstalacionId,
	LD.MarcoLegalId,	
	LD.EntregableId,
	LD.Frecuencia,
	D.FechaProgramadaEntrega,
	D.NombreArchivo,
	D.DocumentoEntregableId,
	5,
	D.TipoArchivo,
	COUNT(D.DocumentoEntregableId),
	D.Mime,
	D.TipoArchivo,
	D.FechaCarga,
	D.CargadoPor,
	D.Origen	
	FROM @Lista LD
	JOIN @Documentos D
		ON			LD.EtapaId					=	D.IdEtapa
		AND			LD.PozoInstalacionId		=	D.InstalacionId
		AND			LD.MarcoLegalId				=	D.IdMarcoLegal
		AND			LD.EntregableId				=	D.IdEntregable
	WHERE D.EsDeProceso = 1
	GROUP BY 
	LD.ID,	
	LD.EtapaId,	
	LD.PozoInstalacionId,
	LD.MarcoLegalId,	
	LD.EntregableId,
	LD.Frecuencia,
	D.NombreArchivo,
	D.DocumentoEntregableId,
	D.TipoArchivo,
	D.NoVersion,
	D.Mime,
	D.FechaProgramadaEntrega,
	D.TipoArchivo,
	D.FechaCarga,
	D.CargadoPor,
	D.Origen
	ORDER BY MIN(D.FechaCarga) ASC

	END

	--/*CREACIÓN DE LOS NIVELES DE LOS DOCUMENTOS DE ORIGEN DE GENERAL*/
	BEGIN
		
		--NIVEL 4  DOCUMENTOS GENERALES DE LOS MARCOS LEGALES
		INSERT INTO @Lista(IDPadre,EtapaId,ReceptorEntregableId,PozoInstalacionId,MarcoLegalId,EntregableId,Frecuencia,FechaProgramadaEntrega,Titulo,DocumentoEntregableId,Nivel,Detalle,CantidadArchivos,Mime,TipoArchivo,FechaCarga,CargadoPor,Origen)
		SELECT 
		LD.ID,	
		D.IdEtapa,	
		D.IdReceptorEntregable,
		D.InstalacionId,
		D.IdMarcoLegal,	
		D.IdEntregable,
		D.FrecuenciaEntregable,
		D.FechaProgramadaEntrega,
		D.NombreArchivo,
		D.DocumentoEntregableId,
		4,
		D.TipoArchivo,
		COUNT(D.DocumentoEntregableId),
		D.Mime,
		D.TipoArchivo,
		D.FechaCarga,
		D.CargadoPor,
		D.Origen	
		FROM @Lista LD
		JOIN @Documentos D
			ON			LD.EtapaId								=	D.IdEtapa
			AND			ISNULL(LD.ReceptorEntregableId,0)		=	ISNULL(D.IdReceptorEntregable,0)	
			AND			ISNULL(LD.PozoInstalacionId,0)			=	ISNULL(D.InstalacionId,0)	
			AND			LD.MarcoLegalId							=	-1 --> ES CARPETA GENERAL
			AND			LD.Nivel								=	3	--> NIVEL DE MARCOS LEGALES
			AND			D.Origen								=	'GENERAL'	
			AND			LD.EntregableId				IS	NULL
		GROUP BY
		LD.ID,	
		D.IdEtapa,	
		D.IdReceptorEntregable,
		D.IdMarcoLegal,	
		D.IdEntregable,
		D.FrecuenciaEntregable,
		D.FechaProgramadaEntrega,
		D.NombreArchivo,
		D.DocumentoEntregableId,		
		D.TipoArchivo,
		D.DocumentoEntregableId,
		D.Mime,
		D.TipoArchivo,
		D.FechaCarga,
		D.InstalacionId,
		D.CargadoPor,
		D.Origen
		ORDER BY D.FechaCarga ASC	
			

		/*OBTENER CANTIDAD DE ARCHIVOS DE LAS CARPETAS GENERALES DE NIVEL 3 --> REGULADORES*/
		SELECT 
		LD.IDPadre  AS IdPadre,
		COUNT(LD.IDPadre) AS CantidadArchivos
		INTO #CantidadArchivosGeneralN3
		FROM @Lista	LD
		WHERE LD.Nivel = 4 --> NIVEL EN QUE SE ENCUENTRAN LOS DOCUMENTOS
		AND LD.Origen =	'GENERAL'	
		AND LD.TipoArchivo <>'Carpeta' --> PARA QUE NO SUMARICE LOS REGISTROS DE TIPO CARPETA
		GROUP BY LD.IDPadre
			
					
		/*ACTUALIZAR LISTA PRINCIPAL DE NIVEL 3*/
		UPDATE  LD
		SET LD.CantidadArchivos=CA.CantidadArchivos 
		FROM @Lista LD
		JOIN #CantidadArchivosGeneralN3 CA
		ON LD.ID=CA.IdPadre


	END 

	/*PERSONALIZACIÓN DE LOS EVENTOS DE LAS OPCIONES DE JAVASCRIPT*/
	BEGIN

	UPDATE @Lista
	SET Icono= N'<i class="glyph-icon icon-folder" style="color: orange;" title="'+Detalle+'"></i>',
	Acciones =Titulo
	WHERE
	TipoArchivo='Carpeta'

	UPDATE @Lista
	SET Mime = (CASE WHEN Mime IN('application/pdf') THEN 'PDF' 
					 WHEN Mime IN ('application/vnd.ms-excel','application/vnd.openxmlformats-officedocument.spre',
					 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') THEN 'EXCEL'
					 WHEN Mime IN ('application/msword',
									'application/vnd.openxmlformats-officedocument.word', 'application/vnd.openxmlformats-officedocument.spre',
									'text/plain','text/html') THEN 'WORD'
					WHEN Mime IN ('image/jpeg','image/png','image/gif','image/bmp') THEN 'IMAGEN'
					ELSE 'ARCHIVO' END)
	WHERE TipoArchivo<>'Carpeta'

	UPDATE @Lista
	SET Mime = 'CORREO'
	WHERE Mime='ARCHIVO'
	AND SUBSTRING(Titulo, LEN(Titulo)-3, LEN(Titulo))=UPPER('.MSG')
	
	/*PERSONALIZAR EVENTOS*/
	UPDATE @Lista
	SET Icono=  N'<a href="javascript:;" title="'+Detalle+'"><i class="glyph-icon icon-file"></i></a>',
	Acciones = CONCAT('<a href="javascript:;" 
					title="'+REPLACE(Titulo,'"','&#34;')+'" 
					data-html="true" 
					data-toggle="popover" 
					data-placement="top" 
					data-content="<ul class=&#34;dropdown-menu display-block&#34;>',
					CASE WHEN Mime <> 'ARCHIVO' THEN
									'<li>
										<a href=&#34;javascript:;&#34; onclick=&#34;loadDocumentoAdjunto('+CAST(ISNULL(DocumentoEntregableId,0) AS nvarchar(MAX))+','''+Mime+''',this,'''+Origen+''')&#34;>
										  <i class=&#34;glyph-icon icon-sign-in&#34; aria-hidden=&#34;true&#34;></i>&nbsp;Abrir
										</a>
									</li>
									<li disabled>
										<a href=&#34;javascript:;&#34; onclick=&#34;loadNuevaPaginaAdjunto('+CAST(ISNULL(DocumentoEntregableId,0) AS nvarchar(MAX))+','''+Mime+''',this,'''+Origen+''')&#34;>
										 <i class=&#34;glyph-icon icon-external-link&#34; aria-hidden=&#34;true&#34;></i>&nbsp;Abrir en nueva pestaña
										</a>
									</li>'									  
					END,
									'<li>
										<a href=&#34;javascript:;&#34; onclick=&#34;descargarArchivoEntregable('+CAST(ISNULL(DocumentoEntregableId,0) AS nvarchar(MAX))+','''+Origen+''')&#34;>
										  <i class=&#34;glyph-icon icon-download&#34; aria-hidden=&#34;true&#34;></i>&nbsp;Descargar
										</a>
									</li>
								</ul>">',REPLACE(Titulo,'"','&#34;'),
				 '</a>')
	WHERE TipoArchivo<>'Carpeta'

	/*PERSONALIZAR CARPETA GENERAL DE NIVEL 3 DE LAS CARPETAS GENERALES*/

	UPDATE @Lista
	SET 
	Icono= N'<i class="glyph-icon icon-folder" style="color: green;" title="Carpeta General"></i>',
	Acciones = CONCAT('<a href="javascript:;" 
					title="'+REPLACE(Titulo,'"','&#34;')+'" 
					data-html="true" 
					data-toggle="popover" 
					data-placement="top" 
					data-content="<ul class=&#34;dropdown-menu display-block&#34;>',	
									'<li>
										<a href=&#34;javascript:;&#34; onclick=&#34;cargarArchivoGeneral(''GENERAL'','+CAST(Nivel  AS nvarchar(MAX))+','+CAST(EtapaId  AS nvarchar(MAX))+','+CAST(ISNULL(ReceptorEntregableId,0)  AS nvarchar(MAX))+','+CAST(ISNULL(PozoInstalacionId,0)  AS nvarchar(MAX))+',-1,0)&#34;>
										   Cargar archivo
										</a>
									</li>
								</ul>">',REPLACE(Titulo,'"','&#34;'),
				 '</a>')
	WHERE Nivel=3
	AND MarcoLegalId=-1	--> ES CARPETA GENERAL

	END 

	SELECT * FROM @Lista 

 END

