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
/****** Object:  StoredProcedure [dbo].[EN_SHELL_ObtenerDocumentosEntregables]    Script Date: 18/05/2021 09:45:49 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EN_SHELL_ObtenerDocumentosEntregables] --EN_SHELL_ObtenerDocumentosEntregables 10113,10061
    @ContratoId INT,
    @UsuarioId INT   
AS
BEGIN
SET NOCOUNT ON

		/*NOTAS
		Niveles
		1.- Etapas 
		2.- Regulador-Pozo(Aplica para los entregables que son de procesos)
		3.- Marcos legales --> En este nivel tambien se agregan carpetas fantasmas llamadas General (siempre llevan el MarcoLegalId =-1)
		4.- Frecuencia 
		5.-	Fecha de entrega Año-Mes
		6.- Entregable	

		Niveles para pozos
		1. Etapa
		2. Pozo
		3. Etapa
		3. Lineamiento
		4. Entregable
		5. Archivo

		- Los archivos de tipo Archivo General son los unicos que llevan el enlace de Eliminar
		- El icono de las carpetas Generales son de color verde, asi tambien los archivos generales
		*/
		
		DECLARE @EtapaId INT =  0
		DECLARE @ContadorNiveles INT = 1
		DECLARE @TotalEtapas INT 
		DECLARE @Contador INT
		DECLARE @FechaEtapaInicio DATETIME 
		DECLARE @FechaEtapaFin DATETIME 

        DECLARE @Lista AS TABLE(
            ID INT IDENTITY(1,1),           
            IDPadre INT,
            Titulo NVARCHAR(MAX),
            EtapaId NVARCHAR(MAX),          
            ReceptorEntregableId INT,
            PozoInstalacionId INT,
            MarcoLegalId INT,   
			EtapaPozoId INT,
            EntregableId INT, 
			FrecuenciaId NVARCHAR(MAX),
            Frecuencia NVARCHAR(MAX),
			FechaEntregaAnioMes NVARCHAR(MAX),
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
            Origen NVARCHAR(MAX),
			FechaInicioEtapa DATETIME,    
			FechaFinEtapa DATETIME)

            DECLARE @Documentos AS TABLE(
            DocumentoEntregableId INT,
            NombreArchivo NVARCHAR(MAX), 
            idTipoArchivo INT,
            TipoArchivo NVARCHAR(MAX),
            IdEntregable INT, 
            IdReceptorEntregable INT, 
            IdEtapa INT, 
            IdMarcoLegal INT,   
            FechaCarga DATETIME,
            NoVersion INT, 
            Mime NVARCHAR(MAX), 
            EntregableInstanciaId INT,          
            FrecuenciaEntregable NVARCHAR(MAX),
            FechaProgramadaEntrega DATETIME,
			FechaProgramadaEntregaAnioMes NVARCHAR(MAX),
            CargadoPor NVARCHAR(MAX),
            Origen NVARCHAR(MAX),   
            EsDeProceso BIT,
            InstalacionId INT,      
            Pozo NVARCHAR(MAX),
			NivelPadre INT,
			EtapaPozoId INT)

		DECLARE @CantidadArchivosGeneral AS TABLE 
		(
			 IdPadre INT,
			 CantidadArchivos INT,
			 NivelPadre INT
		)

    --IF OBJECT_ID('tempdb.dbo.#CantidadArchivosGeneralN3', 'U') IS NOT NULL
    --DROP TABLE #CantidadArchivosGeneralN3
    --IF OBJECT_ID('tempdb.dbo.#DocumentosVersion', 'U') IS NOT NULL
    --DROP TABLE #DocumentosVersion
    
    /*OBTENER DOCUMENTOS DE LOS ENTREGABLES CON ESTATUS APROBADO INTERNAMENTE*/
    BEGIN
     /*OBTENER TODOS LOS DOCUMENTOS DEL CONTRATO - CON ESTATUS APROBADO INTERNAMENTE*/
     INSERT INTO @Documentos(
     DocumentoEntregableId,
     NombreArchivo, 
     idTipoArchivo,
     TipoArchivo,
     IdEntregable, 
     IdReceptorEntregable, 
     IdEtapa, 
     IdMarcoLegal,  
     FechaCarga,
     NoVersion, 
     Mime, 
     EntregableInstanciaId, 
     FrecuenciaEntregable,
     FechaProgramadaEntrega,
	 FechaProgramadaEntregaAnioMes,
     CargadoPor,
     Origen,
     EsDeProceso,    
     Pozo,
     InstalacionId,
	 EtapaPozoId)

     SELECT DISTINCT 
     DocumentoEntregableId			=	ED.DocumentoEntregableId,
     NombreArchivo					=	ED.NombreArchivo, 
     idTipoArchivo					=	ED.idTipoArchivo,
     TipoArchivo					=	T.Nombrearchivo,
     IdEntregable					=	E.IdEntregable, 
     IdReceptorEntregable			=	E.IdReceptorEntregable, 
     IdEtapa						=	NULL,  --> ESTA ETAPA SE OBTIENE DE CO_ContratoEtapas 
     IdMarcoLegal					=	E.IdMarcoLegal, 
     FechaCarga						=	ED.CreadoEl,
     NoVersion						=	DV.N_version, 
     Mime							=	ED.Meta, 
     EntregableInstanciaId			=	EI.idInstanciaEntregable,  
     FrecuenciaEntregable			=	FE.FrecuenciaEntregable,
     FechaProgramadaEntrega			=	EI.FechaCalculadaEntregaReg,
	 FechaProgramadaEntregaAnioMes	=	CAST(YEAR(EI.FechaCalculadaEntregaReg) AS nvarchar(MAX))+'-'+CAST(FORMAT(EI.FechaCalculadaEntregaReg,'MM') AS nvarchar(MAX)), --> FORMATO ESPERADO YYYY-MM --> 2020-01 --> SI SE MODIFICA PODRIA AFECTAR A LOS DOCUMENTOS GENERALES 
     CargadoPor						=	U.Nombre,
     Origen							=	'ENTREGABLES',   --> SIRVE PARA IDENTIFICAR QUE LOS ARCHIVOS PROVIENEN DE UN ENTREGABLE ESPECIFICO    
     EsDeProceso					=	CASE WHEN  ISNULL(IPF.IdInstanciasProcesos,0) > 0 THEN 1 ELSE 0 END,
     Pozo							=	COI.NombreInstalacion,
     IdInstalacion					=	P.IdInstalacion,
	 EtapaPozoId					=	P.EtapaPozoId
    FROM EN_ContratoEntregable CE   
    JOIN EN_InstanciasEntregable EI
            ON CE.IdContratoEntregable          =   EI.IdContratoEntregable 
            AND CE.IdContrato                   =   @ContratoId
            AND EI.Activo                       =   1   --> EN_InstanciasEntregable ACTIVA
    JOIN EN_Entregable E
            ON CE.IdEntregable                  =   E.IdEntregable      
            AND ISNULL(E.IsActivo,0)            =   1   --> EN_Entregable ACTIVA  
            AND E.BitJOA                        =   0	--> JOA --> Activa
    JOIN    EN_Actividad AE
            ON EI.ActividadID=AE.ActividadID
            AND EI.IdContratoEntregable         =   AE.IdContratoEntregable
            AND AE.EstadoID                     =   10003 --> ESTADO APROBADO INTERNAMENTE --> EN_Estado
    JOIN EN_HistorialAprobacionesLineaTiempo ELT
            ON EI.idInstanciaEntregable         =   ELT.idInstanciaEntregable
            AND ELT.idTipoOperacion             =   4 -->ARCHIVOS DE APROBACIÓN -->EN_TipoOperacion
    JOIN EN_DocumentoVersion DV             
            ON EI.idInstanciaEntregable         =   DV.idInstanciaEntregable    
            AND ELT.IdLineaTiempo=DV.N_version
            AND DV.Activo                       =   1 --> EN_DocumentoVersion ACTIVO
    JOIN EN_EntregableDocumento ED
            ON DV.idInstanciaEntregable         =   ED.idInstanciaEntregable
            AND DV.DocumentoEntregableId        =   ED.DocumentoEntregableId
            AND ED.idContratoEntregable         =   CE.IdContratoEntregable         
    JOIN EN_TipoArchivo T   
            ON  ED.idTipoArchivo                =   T.idTipoArchivo     
    LEFT JOIN EN_FrecuenciaEntregable   FE
            ON E.IdFrecuenciaEntregable         =   FE.IdFrecuenciaEntregable   
    LEFT JOIN AP_Usuario U                      
            ON  ED.CreadoPor                    =   U.UsuarioID 
    LEFT    JOIN
            EN_InstanciasEntregables_InstanciaActividad IEIA
            ON EI.idInstanciaEntregable =   IEIA.idInstanciaEntregable
    LEFT    JOIN
        EN_InstanciasActividades    IA
        ON  IEIA.idInstanciaActividad   =   IA.idInstanciaActividad
    LEFT JOIN 
        EN_InstanciasProcesosFecha  IPF
        ON  IA.IdInstanciasProcesos =   IPF.IdInstanciasProcesos
    LEFT JOIN 
            EN_Procesos P
            ON  IPF.IdProceso   =   P.IdProceso
    LEFT JOIN 
            CO_Instalacion COI
            ON P.IdInstalacion = COI.IdInstalacion
    WHERE 
    ED.Activo = 1   --> EN_EntregableDocumento ACTIVO
	
    /*OBTENER LA ULTIMA VERSION DE LAS INSTANCIAS*/
    SELECT 
    EntregableInstanciaId	=	EntregableInstanciaId,  
    NoVersion				=	MAX(NoVersion)
    INTO #DocumentosVersion
    FROM @Documentos
    GROUP BY
    EntregableInstanciaId
                    
    /*ELIMINAR LOS DOCUMENTOS DE LA TABLA TEMPORAL QUE NO SON PARTE DE LA ULTIMA VERSIÓN DE LOS DOCUMENTOS*/
    DELETE D
    FROM @Documentos D
    LEFT JOIN #DocumentosVersion DV
        ON	D.EntregableInstanciaId =   DV.EntregableInstanciaId
        AND D.NoVersion				=   DV.NoVersion
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
         IdEtapa, 
         IdMarcoLegal,  
         FechaCarga,
         NoVersion, 
         Mime, 
         EntregableInstanciaId,      
         FrecuenciaEntregable,
         FechaProgramadaEntrega,
		 FechaProgramadaEntregaAnioMes,
         CargadoPor,
         Origen,
         InstalacionId,
         EsDeProceso,
		 NivelPadre,
		 EtapaPozoId)
        SELECT 
         DocumentoEntregableId		=	D.DocumentoId,
         NombreArchivo				=	D.NombreArchivo, 
         idTipoArchivo				=	NULL,
         TipoArchivo				=	'Archivo general', --> SIRVE PARA IDENTIFICAR QUE ESTOS ARCHIVOS SON CARGADOS DESDE LA PAGINA DE ArchivosEntregables.aspx
         IdEntregable				=	D.EntregableId, 
         IdReceptorEntregable		=	D.ReceptorId, 
         IdEtapa					=	D.EtapaId, --> SE COLOCA POR DEFAULT LA ETAPA EN -1 CUANDO ES NULL PARA MANDAR A CARPETA GENERAL
         IdMarcoLegal				=	D.MarcoLegalId,    
         FechaCarga					=	D.CreadoEl,
         NoVersion					=	1, 
         Mime						=	D.Meta, 
         EntregableInstanciaId		=	NULL,     
         FrecuenciaEntregable		=	D.Frecuencia,
         FechaProgramadaEntrega		=	NULL,
		 FechaProgramadaEntregaAnioMes	=	D.FechaEntregaAnioMes,
         CargadoPor					=	U.Nombre,
         Origen						=	'GENERAL',
         InstalacionId				=	D.InstalacionId,
         EsDeProceso				=	CASE WHEN  ISNULL(D.InstalacionId,0) > 0 THEN 1 ELSE 0 END,
		 NivelPadre					=	D.NivelPadre,
		 EtapaPozoId				=	D.EtapaPozoId	
        FROM EN_DocumentoGeneral D
        LEFT JOIN AP_Usuario U                      
                ON  D.CreadoPor =   U.UsuarioID 		
        WHERE D.ContratoId=@ContratoId
		AND D.Activo=1--> EL DOCUMENTO TIENE QUE ESTAR ACTIVO PARA TOMARLO EN CUENTA
    END 


    /*CREACIÓN DE LOS NIVELES DE LOS DOCUMENTOS DE ORIGEN DE ENTREGABLES*/

    BEGIN   
     -- NIVEL 1 -- OBTENER LAS ETAPAS DEL CONTRATO ACTUAL

     INSERT INTO @Lista(IDPadre,EtapaId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo,FechaInicioEtapa,FechaFinEtapa)
     SELECT 
     IDPadre				=	NULL,--> EL NIVEL 1 NUNCA TIENE IDPadre     
     EtapaId				=	CE.EtapaId,
	 Titulo					=	E.Etapa,
     Nivel					=	1,
     Detalle				=	'Etapa',
     CantidadArchivos		=	COUNT(D.DocumentoEntregableId),
     TipoArchivo			=	'Carpeta',
	 FechaInicioEtapa		=	CE.FechaInicio,
	 FechaFinEtapa			=	CE.FechaFin
     FROM CO_ContratoEtapas CE
     JOIN EN_Etapa E
        ON      CE.EtapaId      =   E.IdEtapa
     JOIN @Documentos D        
        ON  D.FechaProgramadaEntrega    BETWEEN CE.FechaInicio AND CE.FechaFin
     WHERE CE.ContratoId        =   @ContratoId
     AND CE.Activo              =   1       
     GROUP BY   
     E.Etapa,
     CE.EtapaId,
	 CE.FechaInicio,
	 CE.FechaFin
     ORDER BY E.Etapa ASC
	 
	 END 


	 SELECT @TotalEtapas = COUNT(1) FROM @Lista --> EN NIVEL UNO ESTAN LAS ETAPAS
	 SET @Contador=1

	 /*RECORRER LAS ETAPAS PARA ARMAR LAS SUBCARPETAS DE LOS NIVELES 2 AL 6*/
	 WHILE @TotalEtapas >= @Contador
	 BEGIN 
	        SELECT @EtapaId = EtapaId, 
			@FechaEtapaInicio=FechaInicioEtapa,
			@FechaEtapaFin=FechaFinEtapa 
			FROM @Lista WHERE ID=@Contador

		    -- NIVEL 2-A CARPETAS PARA LOS REGULADORES 
		    INSERT INTO @Lista(IDPadre,EtapaId,ReceptorEntregableId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo)
		    SELECT 
		    IDPadre					=	LD.ID,  
		    EtapaId					=	LD.EtapaId,		    
		    ReceptorEntregableId	=	RE.IdReceptorEntregable,
			Titulo					=	RE.ReceptorEntregable,
		    Nivel					=	2,
		    Detalle					=	'Regulador',
		    CantidadArchivos		=	COUNT(D.DocumentoEntregableId),
		    TipoArchivo				=	'Carpeta'
		    FROM @Lista LD
		    JOIN @Documentos D    
				ON  D.FechaProgramadaEntrega  
				BETWEEN LD.FechaInicioEtapa 
				AND LD.FechaFinEtapa    
		    JOIN EN_ReceptorEntregable RE 
		        ON          D.IdReceptorEntregable  =   RE.IdReceptorEntregable
		    WHERE D.EsDeProceso = 0  -->QUE NO SEA DOCUMENTO DE UN PROCESO
			AND LD.EtapaId=@EtapaId
		    GROUP BY    
		    LD.ID,  
		    LD.EtapaId,
		    RE.ReceptorEntregable,
		    RE.IdReceptorEntregable
		    ORDER BY RE.ReceptorEntregable ASC

			--NIVEL 2-B CARPETAS PARA LOS POZOS
			INSERT INTO @Lista(IDPadre,EtapaId,PozoInstalacionId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo)
			SELECT 
			IDPadre				=	LD.ID,  
			EtapaId				=	LD.EtapaId, 			
			PozoInstalacionId	=	D.InstalacionId,
			Titulo				=	D.Pozo,
			Nivel				=	2,
			Detalle				=	'Pozo',
			CantidadArchivos	=	COUNT(D.DocumentoEntregableId),
			TipoArchivo			=	'Carpeta'
			FROM @Lista LD
			JOIN @Documentos D
			    ON  D.FechaProgramadaEntrega 
				BETWEEN LD.FechaInicioEtapa AND LD.FechaFinEtapa
			WHERE D.EsDeProceso = 1 -->QUE SEA DOCUMENTO DE UN PROCESO
			AND LD.EtapaId=@EtapaId
			GROUP BY    
			LD.ID,  
			LD.EtapaId,
			D.InstalacionId,
			D.Pozo
			ORDER BY D.Pozo ASC
			
						
		    --NIVEL 3-A CARPETAS PARA LOS MARCOS LEGALES--> SUBCARPETA DE LOS REGULADORES
		    INSERT INTO @Lista(IDPadre,EtapaId,ReceptorEntregableId,MarcoLegalId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo)
		    SELECT 
		    IDPadre					=	LD.ID,  
		    EtapaId					=	LD.EtapaId, 
		    ReceptorEntregableId	=	LD.ReceptorEntregableId,
			MarcoLegalId			=	ML.IdMarcoLegal,
		    Titulo					=	ML.MarcoLegal,		    
		    Nivel					=	3,
		    Detalle					=	'Marco Legal',
		    CantidadArchivos		=	COUNT(D.DocumentoEntregableId),
		    TipoArchivo				=	'Carpeta'
		    FROM @Lista LD
		    JOIN @Documentos D    
		        ON  D.FechaProgramadaEntrega    
					BETWEEN @FechaEtapaInicio 
					AND @FechaEtapaFin
					AND LD.EtapaId						=   @EtapaId	
				AND LD.ReceptorEntregableId				=   D.IdReceptorEntregable								
		    JOIN EN_MarcoLegal ML
		        ON  D.IdMarcoLegal						=   ML.IdMarcoLegal
		    WHERE D.EsDeProceso = 0		-->QUE NO SEA DOCUMENTO DE UN PROCESO
		    GROUP BY 
		    LD.ID,  
		    LD.EtapaId, 
		    LD.ReceptorEntregableId,
		    ML.MarcoLegal,
		    ML.IdMarcoLegal
		    ORDER BY ML.MarcoLegal ASC


		    --NIVEL 3-B CARPETA DE ETAPAS DE UN POZO SUBCARPETA DE LOS POZOS
		    INSERT INTO @Lista(IDPadre,EtapaId,PozoInstalacionId,EtapaPozoId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo)
		    SELECT 
		    IDPadre				=	LD.ID,  
		    EtapaId				=	LD.EtapaId, 
		    PozoInstalacionId	=	LD.PozoInstalacionId,		    
		    EtapaPozoId			=	D.EtapaPozoId,
			Titulo				=	EP.Etapa,
		    Nivel				=	3,
		    Detalle				=	'Etapa del pozo',
		    CantidadArchivos	=	COUNT(D.DocumentoEntregableId),
		    TipoArchivo			=	'Carpeta'
		    FROM @Lista LD
		    JOIN @Documentos D
		        ON          LD.EtapaId                      =   @EtapaId
		        AND         LD.PozoInstalacionId            =   D.InstalacionId				
		    JOIN EN_Etapa EP
		        ON          D.EtapaPozoId          =   EP.IdEtapa
		    WHERE D.EsDeProceso = 1		--> QUE SEA DOCUMENTO DE UN PROCESO				
		    GROUP BY 
		    LD.ID,  
		    LD.EtapaId, 
		    LD.PozoInstalacionId,
			D.EtapaPozoId,
		    EP.Etapa		    
		    ORDER BY EP.Etapa ASC			
			
			--NIVEL 3-A AGREGAR CARPETA GENERAL POR CADA REGULADOR DE CADA ETAPA ESTO PARA LOS ARCHIVOS GENERALES-- AL NIVEL DE LOS MARCOS LEGALES
			INSERT INTO @Lista(IDPadre,EtapaId,ReceptorEntregableId,MarcoLegalId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo)
			SELECT 
			IDPadre						=	LD.ID,  
			EtapaId						=	LD.EtapaId, 
			ReceptorEntregableId		=	LD.ReceptorEntregableId,
			MarcoLegalId				=	-1,	--> INDICA QUE ES UNA CARPETA GENERAL AL NIVEL DE LOS MARCOS LEGALES
			Titulo						=	'General',			
			Nivel						=	3, --> EN EL NIVEL 3
			Detalle						=	'Carpeta general',
			CantidadArchivos			=	0,
			TipoArchivo					=	'Carpeta'
			FROM @Lista LD  
			WHERE LD.Nivel=2    --> PARA INDICAR QUE LA CARPETA PADRE ES DEL NIVEL 2
			AND LD.EtapaId=@EtapaId
			AND LD.PozoInstalacionId IS NULL
			GROUP BY 
			LD.ID,  
			LD.EtapaId, 
			LD.ReceptorEntregableId
						
			--NIVEL 3-B AGREGAR CARPETA GENERAL POR CADA POZO DE CADA ETAPA ESTO PARA LOS ARCHIVOS GENERALES --PARA LOS POZOS
			INSERT INTO @Lista(IDPadre,EtapaId,PozoInstalacionId,EtapaPozoId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo)
			SELECT 
			IDPadre					=	LD.ID,  
			EtapaId					=	LD.EtapaId, 
			PozoInstalacionId		=	LD.PozoInstalacionId,
			EtapaPozoId				=	-1,--> INDICA QUE ES UNA CARPETA GENERAL AL NIVEL DE LAS ETAPAS DE LOS POZOS
			Titulo					=	'General',
			Nivel					=	3, --> EN EL NIVEL 3
			Detalle					=	'Carpeta general',
			CantidadArchivos		=	0,
			TipoArchivo				=	'Carpeta'
			FROM @Lista LD  
			WHERE LD.Nivel =  2   --> DONDE EL PADRE ES UN POZO EN EL NIVEL 2 
			AND LD.EtapaId=@EtapaId
			AND LD.PozoInstalacionId IS NOT NULL			
			GROUP BY 
			LD.ID,  
			LD.EtapaId, 
			LD.PozoInstalacionId
			

			--NIVEL 4-A CARPETAS DE FRECUENCIA DE LOS ENTREGABLES
		    INSERT INTO @Lista(IDPadre,EtapaId,ReceptorEntregableId,MarcoLegalId,FrecuenciaId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo)
		    SELECT 
		    IDPadre						=	LD.ID,  
		    EtapaId						=	LD.EtapaId, 
		    ReceptorEntregableId		=	LD.ReceptorEntregableId,
		    MarcoLegalId				=	LD.MarcoLegalId,	
			FrecuenciaId				=	D.FrecuenciaEntregable,	   
		    Titulo						=	D.FrecuenciaEntregable,			
		    Nivel						=	4,
		    Detalle						=	'Frecuencia',
		    CantidadArchivos			=	COUNT(D.DocumentoEntregableId),
		    TipoArchivo					=	'Carpeta'
		    FROM @Lista LD
		    JOIN @Documentos D
		        ON          D.FechaProgramadaEntrega    
				BETWEEN		@FechaEtapaInicio 
				AND			@FechaEtapaFin
				AND		    LD.EtapaId                  =   @EtapaId	 
		        AND         LD.ReceptorEntregableId     =   D.IdReceptorEntregable
		        AND         LD.MarcoLegalId             =   D.IdMarcoLegal		   
		    WHERE D.EsDeProceso = 0  -->QUE NO SEA DOCUMENTO DE UN PROCESO
			AND LD.Detalle<>'Carpeta general'
		    GROUP BY 
		    LD.ID,  
		    LD.EtapaId, 
		    LD.ReceptorEntregableId,
		    LD.MarcoLegalId,		   
		    D.FrecuenciaEntregable
		    ORDER BY MIN(D.FechaCarga) ASC						

		    --NIVEL 4-B CARPETAS DE LINEAMIENTOS(MARCOS LEGALES) --> PARA LOS POZOS 
			INSERT INTO @Lista(IDPadre,EtapaId,PozoInstalacionId,EtapaPozoId,MarcoLegalId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo)
		    SELECT 
		    IDPadre					=	LD.ID,  
		    EtapaId					=	LD.EtapaId, 
		    PozoInstalacionId		=	LD.PozoInstalacionId,
			EtapaPozoId				=	LD.EtapaPozoId,	
			MarcoLegalId			=	D.IdMarcoLegal,	    	
			Titulo					=	ML.MarcoLegal,
		    Nivel					=	4,
		    Detalle					=	'Marco Legal',
		    CantidadArchivos		=	COUNT(D.DocumentoEntregableId),
		    TipoArchivo				=	'Carpeta'
		    FROM @Lista LD
		    JOIN @Documentos D
		        ON   	LD.EtapaId                  =   @EtapaId	     
				AND     LD.PozoInstalacionId        =   D.InstalacionId
		        AND     LD.EtapaPozoId              =   D.EtapaPozoId									
			JOIN EN_MarcoLegal ML
		        ON			D.IdMarcoLegal			=   ML.IdMarcoLegal 
		    WHERE D.EsDeProceso = 1  	--> QUE SEA DOCUMENTO DE UN PROCESO	
			AND LD.EtapaId=@EtapaId
			AND LD.Detalle<>'Carpeta general'
		    GROUP BY 
		    LD.ID,  
		    LD.EtapaId, 
		    LD.PozoInstalacionId,
			LD.EtapaPozoId,		    
			D.IdMarcoLegal,	
		    ML.MarcoLegal  
		    ORDER BY ML.MarcoLegal ASC

			--NIVEL 5-A CARPETA DE LA FECHA DE ENTREGA DEL ENTREGABLE AÑO-MES  
		    INSERT INTO @Lista(IDPadre,EtapaId,ReceptorEntregableId,MarcoLegalId,FrecuenciaId,FechaEntregaAnioMes,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo)
		    SELECT 
		    IDPadre					=	LD.ID,  
		    EtapaId					=	LD.EtapaId, 
		    ReceptorEntregableId	=	LD.ReceptorEntregableId,
		    MarcoLegalId			=	LD.MarcoLegalId,
			FrecuenciaId			=	LD.FrecuenciaId,
			FechaEntregaAnioMes		=	D.FechaProgramadaEntregaAnioMes,
			Titulo					=	D.FechaProgramadaEntregaAnioMes,	
		    Nivel					=	5,
		    Detalle					=	'Año-Mes de entrega',
		    CantidadArchivos		=	COUNT(D.DocumentoEntregableId),
		    TipoArchivo				=	'Carpeta'
		    FROM @Lista LD
		    JOIN @Documentos D
		        ON          D.FechaProgramadaEntrega    
				BETWEEN		@FechaEtapaInicio 
				AND			@FechaEtapaFin
				AND			LD.EtapaId                  =   @EtapaId
		        AND         LD.ReceptorEntregableId     =   D.IdReceptorEntregable
		        AND         LD.MarcoLegalId             =   D.IdMarcoLegal		
				AND			LD.FrecuenciaId				=   D.FrecuenciaEntregable   
		    WHERE D.EsDeProceso = 0 -->QUE NO SEA DOCUMENTO DE UN PROCESO
		    GROUP BY 
		    LD.ID,  
		    LD.EtapaId, 
		    LD.ReceptorEntregableId,
		    LD.MarcoLegalId,	
			LD.FrecuenciaId,  
			D.FechaProgramadaEntregaAnioMes
		    ORDER BY MIN(D.FechaProgramadaEntrega) ASC

			--NIVEL 5-B CARPETA DE LOS NOMBRES DE LOS ENTREGABLES PARA LOS POZOS
		    INSERT INTO @Lista(IDPadre,EtapaId,PozoInstalacionId,EtapaPozoId,MarcoLegalId,EntregableId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo)
		    SELECT 
		    IDPadre					=	LD.ID,  
		    EtapaId					=	LD.EtapaId, 
		    PozoInstalacionId		=	LD.PozoInstalacionId,
			EtapaPozoId				=	LD.EtapaPozoId,
		    MarcoLegalId			=	LD.MarcoLegalId,	
			EntregableId			=	D.IdEntregable,	 
			Titulo					=	E.DocumentoEntregable,			
		    Nivel					=	5,
		    Detalle					=	'Entregable',
		    CantidadArchivos		=	COUNT(D.DocumentoEntregableId),
		    TipoArchivo				=	'Carpeta'
		    FROM @Lista LD
		    JOIN @Documentos D
		        ON          LD.EtapaId                  =   @EtapaId
		        AND         LD.PozoInstalacionId        =   D.InstalacionId
				AND			LD.EtapaPozoId				=   D.EtapaPozoId
		        AND         LD.MarcoLegalId             =   D.IdMarcoLegal	
				AND			D.Origen					=	'ENTREGABLES'	 --> SOLO AGREGAR LOS ARCHIVOS CARGADOS DESDE UN ENTREGABLE 			
			JOIN EN_Entregable E
				on D.IdEntregable						=	E.IdEntregable    
		    WHERE D.EsDeProceso = 1  --> QUE SEA DOCUMENTO DE UN PROCESO
			AND LD.EtapaId=@EtapaId
		    GROUP BY 
		    LD.ID,  
		    LD.EtapaId, 
		    LD.PozoInstalacionId,
			LD.EtapaPozoId,
		    LD.MarcoLegalId,		   
		    D.IdEntregable,	 
			E.DocumentoEntregable
		    ORDER BY E.DocumentoEntregable ASC

			--NIVEL 6-A  CARPETA DE LOS NOMBRES DE LOS ENTREGABLES
		    INSERT INTO @Lista(IDPadre,EtapaId,ReceptorEntregableId,MarcoLegalId,FrecuenciaId,FechaEntregaAnioMes,EntregableId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo)
		    SELECT 
		    IDPadre					=	LD.ID,  
		    EtapaId					=	LD.EtapaId, 
		    ReceptorEntregableId	=	LD.ReceptorEntregableId,
		    MarcoLegalId			=	LD.MarcoLegalId,
			FrecuenciaId			=	LD.FrecuenciaId,
			FechaEntregaAnioMes		=	LD.FechaEntregaAnioMes,
			EntregableId			=	E.IdEntregable,	
			Titulo					=	E.DocumentoEntregable,			
		    Nivel					=	6,
		    Detalle					=	'Entregable',
		    CantidadArchivos		=	COUNT(D.DocumentoEntregableId),
		    TipoArchivo				=	'Carpeta'
		    FROM @Lista LD
		    JOIN @Documentos D
		        ON          D.FechaProgramadaEntrega    
				BETWEEN		@FechaEtapaInicio 
				AND			@FechaEtapaFin
				AND			LD.EtapaId                  =   @EtapaId
		        AND         LD.ReceptorEntregableId     =   D.IdReceptorEntregable
		        AND         LD.MarcoLegalId             =   D.IdMarcoLegal		
				AND			LD.FrecuenciaId				=   D.FrecuenciaEntregable   
				AND			LD.FechaEntregaAnioMes		=	D.FechaProgramadaEntregaAnioMes				
			JOIN EN_Entregable	E
				ON	D.IdEntregable						=	E.IdEntregable
		    WHERE D.EsDeProceso = 0  --> PARA DOCUMENTOS QUE NO SON DE PROCESO 
		    GROUP BY 
		    LD.ID,  
		    LD.EtapaId, 
		    LD.ReceptorEntregableId,
		    LD.MarcoLegalId,	
			LD.FrecuenciaId, 
			LD.FechaEntregaAnioMes,
			E.DocumentoEntregable,
			E.IdEntregable
		    ORDER BY E.DocumentoEntregable ASC
			
			--------NIVEL 6-B  LISTA DOCUMENTOS DE POZO
			INSERT INTO @Lista(IDPadre,EtapaId,PozoInstalacionId,EtapaPozoId,MarcoLegalId,EntregableId,DocumentoEntregableId,Titulo,Nivel,Detalle,CantidadArchivos,Mime,TipoArchivo,FechaCarga,CargadoPor,Origen,Frecuencia,FechaProgramadaEntrega)
		    SELECT 
		    IDPadre					=	LD.ID,  
		    EtapaId					=	LD.EtapaId, 
		    PozoInstalacionId		=	LD.PozoInstalacionId,
			EtapaPozoId				=	LD.EtapaPozoId,
		    MarcoLegalId			=	LD.MarcoLegalId,	
			EntregableId			=	LD.EntregableId,	 
			DocumentoEntregableId	=	D.DocumentoEntregableId,
			Titulo					=	D.NombreArchivo,			
		    Nivel					=	6,
		    Detalle					=	D.TipoArchivo,
		    CantidadArchivos		=	COUNT(D.DocumentoEntregableId),
		    Mime					=	D.Mime,
			TipoArchivo				=	D.TipoArchivo,
			FechaCarga				=	D.FechaCarga,
			CargadoPor				=	D.CargadoPor,
			Origen					=	D.Origen,
			Frecuencia				=	D.FrecuenciaEntregable,
			FechaProgramadaEntrega	=	D.FechaProgramadaEntrega	
		    FROM @Lista LD
		    JOIN @Documentos D
		        ON          LD.EtapaId                  =   @EtapaId
		        AND         LD.PozoInstalacionId        =   D.InstalacionId
				AND			LD.EtapaPozoId				=   D.EtapaPozoId
		        AND         LD.MarcoLegalId             =   D.IdMarcoLegal
				AND			LD.EntregableId				=	D.IdEntregable	
				AND			D.Origen					=	'ENTREGABLES'	 --> SOLO AGREGAR LOS ARCHIVOS CARGADOS DESDE UN ENTREGABLE 					
		    WHERE D.EsDeProceso = 1  --> QUE SEA DOCUMENTO DE UN PROCESO
			AND LD.EtapaId=@EtapaId			 
		    GROUP BY 
		    LD.ID,  
		    LD.EtapaId, 
		    LD.PozoInstalacionId,
			LD.EtapaPozoId,
		    LD.MarcoLegalId,		   
		    D.IdEntregable,	 
			LD.ID,  
		    LD.EtapaId, 
		    LD.PozoInstalacionId,
		    LD.MarcoLegalId,	
			LD.FrecuenciaId, 
			LD.FechaEntregaAnioMes,
			LD.EntregableId,
			D.DocumentoEntregableId,
			D.NombreArchivo,
			D.Mime,
			D.TipoArchivo,
			D.FechaCarga,
			D.CargadoPor,
			D.Origen,
			D.FrecuenciaEntregable,
			D.FechaProgramadaEntrega	   	
		    ORDER BY MIN(D.FechaCarga)  ASC
						

			--NIVEL 7-A  LISTA DE DOCUMENTOS 
		    INSERT INTO @Lista(IDPadre,EtapaId,ReceptorEntregableId,MarcoLegalId,FrecuenciaId,FechaEntregaAnioMes,EntregableId,DocumentoEntregableId,Titulo,Nivel,Detalle,CantidadArchivos,Mime,TipoArchivo,FechaCarga,CargadoPor,Origen,Frecuencia,FechaProgramadaEntrega)
		    SELECT 
		    IDPadre					=	LD.ID,  
		    EtapaId					=	LD.EtapaId, 
		    ReceptorEntregableId	=	LD.ReceptorEntregableId,
		    MarcoLegalId			=	LD.MarcoLegalId,
			FrecuenciaId			=	LD.FrecuenciaId,
			FechaEntregaAnioMes		=	LD.FechaEntregaAnioMes,
			EntregableId			=	LD.EntregableId,	
			DocumentoEntregableId	=	D.DocumentoEntregableId,
			Titulo					=	D.NombreArchivo,			
		    Nivel					=	7,
		    Detalle					=	D.TipoArchivo,
		    CantidadArchivos		=	COUNT(D.DocumentoEntregableId),
			Mime					=	D.Mime,
			TipoArchivo				=	D.TipoArchivo,
			FechaCarga				=	D.FechaCarga,
			CargadoPor				=	D.CargadoPor,
			Origen					=	D.Origen,
			Frecuencia				=	D.FrecuenciaEntregable,
			FechaProgramadaEntrega	=	D.FechaProgramadaEntrega	   
		    FROM @Lista LD
		    JOIN @Documentos D
		        ON          D.FechaProgramadaEntrega    
				BETWEEN		@FechaEtapaInicio 
				AND			@FechaEtapaFin
				AND			LD.EtapaId                  =   @EtapaId
		        AND         LD.ReceptorEntregableId     =   D.IdReceptorEntregable
		        AND         LD.MarcoLegalId             =   D.IdMarcoLegal		
				AND			LD.FrecuenciaId				=   D.FrecuenciaEntregable   
				AND			LD.FechaEntregaAnioMes		=	D.FechaProgramadaEntregaAnioMes
				AND			LD.EntregableId				=	D.IdEntregable		
				AND			D.Origen					=	'ENTREGABLES'	 --> SOLO AGREGAR LOS ARCHIVOS CARGADOS DESDE UN ENTREGABLE 	
		    WHERE D.EsDeProceso = 0
		    GROUP BY 
		    LD.ID,  
		    LD.EtapaId, 
		    LD.ReceptorEntregableId,
		    LD.MarcoLegalId,	
			LD.FrecuenciaId, 
			LD.FechaEntregaAnioMes,
			LD.EntregableId,
			D.DocumentoEntregableId,
			D.NombreArchivo,
			D.Mime,
			D.TipoArchivo,
			D.FechaCarga,
			D.CargadoPor,
			D.Origen,
			D.FrecuenciaEntregable,
			D.FechaProgramadaEntrega	   	
		    ORDER BY MIN(D.FechaCarga)  ASC
				


			--/*CREACIÓN DE LOS NIVELES DE LOS DOCUMENTOS DE ORIGEN DE GENERAL*/

			BEGIN
        
				--OBTENER LOS DOCUMENTOS GENERALES 
				INSERT INTO @Lista(IDPadre,EtapaId,ReceptorEntregableId,PozoInstalacionId,EtapaPozoId,MarcoLegalId,EntregableId,Frecuencia,FechaProgramadaEntrega,Titulo,DocumentoEntregableId,Nivel,Detalle,CantidadArchivos,Mime,TipoArchivo,FechaCarga,CargadoPor,Origen)
				SELECT 
				IDPadre					=	LD.ID,  
				EtapaId					=	D.IdEtapa,  
				ReceptorEntregableId	=	D.IdReceptorEntregable,
				PozoInstalacionId		=	D.InstalacionId,
				EtapaPozoId				=	D.EtapaPozoId,
				MarcoLegalId			=	D.IdMarcoLegal, 
				EntregableId			=	D.IdEntregable,
				Frecuencia				=	D.FrecuenciaEntregable,
				FechaProgramadaEntrega	=	D.FechaProgramadaEntrega,
				Titulo					=	D.NombreArchivo,
				DocumentoEntregableId	=	D.DocumentoEntregableId,
				Nivel					=	(D.NivelPadre+1),
				Detalle					=	D.TipoArchivo,
				CantidadArchivos		=	COUNT(D.DocumentoEntregableId),
				Mime					=	D.Mime,
				TipoArchivo				=	D.TipoArchivo,
				FechaCarga				=	D.FechaCarga,
				CargadoPor				=	D.CargadoPor,
				Origen					=	D.Origen    
				FROM @Lista LD
				JOIN @Documentos D
					ON          LD.EtapaId                              =   @EtapaId --> NIVEL 1
					AND			ISNULL(LD.EtapaId,0)					=   ISNULL(D.IdEtapa,0)					--> NIVEL 1
					AND         ISNULL(LD.ReceptorEntregableId,0)       =   ISNULL(D.IdReceptorEntregable,0)    --> NIVEL 2
					AND         ISNULL(LD.PozoInstalacionId,0)          =   ISNULL(D.InstalacionId,0)			--> NIVEL 2
					AND         ISNULL(LD.EtapaPozoId,0)				=   ISNULL(D.EtapaPozoId,0)				--> NIVEL 3
					AND         ISNULL(LD.MarcoLegalId,0)               =   ISNULL(D.IdMarcoLegal,0)			--> NIVEL 3
					AND         ISNULL(LD.FrecuenciaId,'')              =   ISNULL(D.FrecuenciaEntregable,'')   --> NIVEL 4
					AND         ISNULL(LD.FechaEntregaAnioMes,'')       =   ISNULL(D.FechaProgramadaEntregaAnioMes,'')  --> NIVEL 5
					AND         ISNULL(LD.EntregableId,0)				=   ISNULL(D.IdEntregable,0)   --> NIVEL 6
					AND         LD.Nivel                                =   D.NivelPadre   --> DONDE EL NIVEL DEL PADRE SEA EL MISMO 
					AND         D.Origen                                =   'GENERAL'  --> ESTAN EN LA TABLA EN_DocumentoGeneral
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
				D.EtapaPozoId,
				D.CargadoPor,
				D.Origen,
				D.NivelPadre
				ORDER BY D.FechaCarga ASC   
            
				/*OBTENER CANTIDAD DE ARCHIVOS DE LAS CARPETAS GENERALES- RECALCULAR EL TOTAL DE CADA NIVEL :(*/
					
				--SET @ContadorNiveles =1
				--/* 7 POR QUE POR EL MOMENTO SOLO SE TIENE 7 NIVELES DE CARPETAS*/
				--WHILE 7 >=   @ContadorNiveles
				--BEGIN 

				--	DELETE @CantidadArchivosGeneral						
				--	INSERT INTO @CantidadArchivosGeneral(IdPadre,CantidadArchivos)
				--	SELECT 
				--	IdPadre				=	LD.IDPadre,
				--	CantidadArchivos	=	COUNT(LD.ID) 							
				--	FROM @Lista LD
				--	WHERE		
				--	LD.Nivel = @ContadorNiveles --> NIVEL EN QUE SE ENCUENTRAN LOS DOCUMENTOS 
				--	AND LD.Origen ='GENERAL' --> PARA QUE SUMARICE SOLO LOS ARCHIVOS DE TIPO ARCHIVO GENERAL					
				--	AND LD.EtapaId=@EtapaId
				--	GROUP BY LD.IDPadre
										
				--	/*ACTUALIZAR LISTA PRINCIPAL DE NIVEL 3*/
				--	UPDATE  LD
				--	SET LD.CantidadArchivos=(LD.CantidadArchivos+CA.CantidadArchivos)					
				--	FROM @Lista LD
				--	JOIN @CantidadArchivosGeneral CA
				--			ON LD.ID=CA.IdPadre
				--	WHERE LD.EtapaId=@EtapaId	

				--	SET @ContadorNiveles=@ContadorNiveles+1
				--END 
                		
			END 
						
		SET @Contador = @Contador + 1;

	 END 
         
    BEGIN
	   
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
    

    /*PERSONALIZAR EVENTOS PARA LOS ARCHIVOS CARGADOS YA SEAN ENTREGABLES O DOCUMENTOS GENERALES*/
    UPDATE @Lista
    SET Icono= CASE WHEN TipoArchivo='Archivo general' THEN
					 N'<span style="color:green;" title="'+ISNULL(Detalle,'')+'"><i class="glyph-icon icon-file"></i></span>'
			   ELSE
					 N'<span style="color:#5a9ddb;" title="'+ISNULL(Detalle,'')+'"><i class="glyph-icon icon-file"></i></span>'
			   END,
    Acciones = CONCAT('<a href="javascript:;" 
                    title="'+ISNULL(Detalle,'')+': '+REPLACE(ISNULL(Titulo,''),'"','&#34;')+'" 
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
                    END, --> OPCIONES PARA VISUALIZAR ARCHIVOS DE TIPO IMAGEN, DOCUMENTO EXCEL ETC
                                    '<li>
                                        <a href=&#34;javascript:;&#34; onclick=&#34;descargarArchivoEntregable('+CAST(ISNULL(DocumentoEntregableId,0) AS nvarchar(MAX))+','''+Origen+''')&#34;>
                                          <i class=&#34;glyph-icon icon-download&#34; aria-hidden=&#34;true&#34;></i>&nbsp;Descargar
                                        </a>
                                    </li>',--> OPCIÓN PARA DESCARGAR 
					CASE WHEN TipoArchivo='Archivo general' THEN
									 '<li>
                                        <a href=&#34;javascript:;&#34; onclick=&#34;eliminarArchivoGeneral('+CAST(ISNULL(DocumentoEntregableId,0) AS nvarchar(MAX))+','''+Origen+''')&#34;>
                                          <i class=&#34;glyph-icon icon-trash&#34; aria-hidden=&#34;true&#34;></i>&nbsp;Eliminar
                                        </a>
                                    </li>'--> OPCIÓN PARA PODER ELIMINAR ARCHIVOS GENERALES QUE NO TIENE QUE VER CON ENTREGABLES
					END,
                    '</ul>">',
					REPLACE(Titulo,'"','&#34;'),					
                 '</a>')
    WHERE TipoArchivo<>'Carpeta'


    /*PERSONALIZAR CARPETA OPCION DE CARGAR DOCUMENTOS EN LAS CARPETAS*/
    UPDATE @Lista
    SET 
    Icono= N'<i class="glyph-icon icon-folder" style="color: orange;" title="Carpeta General"></i>',
    Acciones = CONCAT('<a href="javascript:;" 
                    title="'+ISNULL(Detalle,'')+': '+REPLACE(ISNULL(Titulo,''),'"','&#34;')+'" 
                    data-html="true" 
                    data-toggle="popover" 
                    data-placement="top" 
                    data-content="<ul class=&#34;dropdown-menu display-block&#34;>',    
                                    '<li>
                                        <a href=&#34;javascript:;&#34; onclick=&#34;cargarArchivoGeneral(''GENERAL'','+CAST(Nivel  AS nvarchar(MAX))+','+CAST(ISNULL(EtapaId,0)  AS nvarchar(MAX))+','+CAST(ISNULL(ReceptorEntregableId,0)  AS nvarchar(MAX))+','+CAST(ISNULL(PozoInstalacionId,0)  AS nvarchar(MAX))+','+CAST(ISNULL(EtapaPozoId,0)  AS nvarchar(MAX))+','+CAST(ISNULL(MarcoLegalId,0)  AS nvarchar(MAX))+','''+CAST(ISNULL(FrecuenciaId,'')  AS nvarchar(MAX))+''','''+CAST(ISNULL(FechaEntregaAnioMes,'')  AS nvarchar(MAX))+''','+CAST(ISNULL(EntregableId,0)  AS nvarchar(MAX))+')&#34;>
                                           Cargar archivo
                                        </a>
                                    </li>
                                </ul>">',REPLACE(ISNULL(Titulo,''),'"','&#34;'),
                 '</a>')
    WHERE TipoArchivo='Carpeta' --> EL ARCHIVO ES UNA CARPETA

	/*PERSONALIZAR CARPETA GENERAL DE NIVEL 3 DE LAS CARPETAS GENERALES COLOR VERDE*/
	UPDATE @Lista
    SET Icono= N'<i class="glyph-icon icon-folder" style="color: green;" title="'+ISNULL(Detalle,'')+'"></i>'   
    WHERE
    Detalle='Carpeta general'

END 


	;WITH ChildrenCTE AS (
	SELECT  RootID = ID, ID
	FROM    @Lista
	UNION ALL
	SELECT  cte.RootID, d.ID
	FROM    ChildrenCTE cte
			INNER JOIN @Lista d ON d.IDPadre = cte.ID			
	)
	INSERT INTO @CantidadArchivosGeneral(IdPadre,CantidadArchivos)
	SELECT  d.ID, cnt.Children
	FROM    @Lista d
			INNER JOIN (
				SELECT  ID = RootID, Children = COUNT(*) - 1
				FROM    ChildrenCTE				
				GROUP BY RootID
			) cnt ON cnt.ID = d.ID
    
	--	/*ACTUALIZAR LISTA PRINCIPAL DE NIVEL 3*/
	UPDATE  LD
	SET LD.CantidadArchivos=CA.CantidadArchivos
	FROM @Lista LD
	JOIN @CantidadArchivosGeneral CA
	ON LD.ID=CA.IdPadre
       
	SELECT * FROM @Lista 

END