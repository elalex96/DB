CREATE PROCEDURE [dbo].[EN_SHELL_ObtenerDocumentosEntregablesDescarga] --EN_SHELL_ObtenerDocumentosEntregablesDescarga 10103,10150
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

		CREATE TABLE #DocumentosVersion
		(
			EntregableInstanciaId	INT,
			NoVersion	INT
		)
		
        CREATE TABLE #Lista (
            ID INT IDENTITY(1,1),           
            IDPadre INT,
            Titulo VARCHAR(MAX),
            EtapaId INT,          
            ReceptorEntregableId INT,
            PozoInstalacionId INT,
            MarcoLegalId INT,   
			EtapaPozoId INT,
            EntregableId INT, 
			FrecuenciaId VARCHAR(200),
            Frecuencia VARCHAR(MAX),
			FechaEntregaAnioMes VARCHAR(200),
            FechaProgramadaEntrega DATETIME,    
            DocumentoEntregableId INT,
            CantidadArchivos INT,
            Detalle VARCHAR(MAX),
            Icono VARCHAR(MAX),
            Acciones VARCHAR(MAX),
            Mime  VARCHAR(MAX),
            Nivel INT,
            TipoArchivo VARCHAR(MAX),
            FechaCarga DATETIME,    
            CargadoPor VARCHAR(MAX),
            Origen VARCHAR(200),
			FechaInicioEtapa DATETIME,    
			FechaFinEtapa DATETIME)

		CREATE TABLE #Documentos (
            DocumentoEntregableId INT,
            NombreArchivo VARCHAR(MAX), 
            idTipoArchivo INT,
            TipoArchivo VARCHAR(200),
            IdEntregable INT, 
            IdReceptorEntregable INT, 
            IdEtapa INT, 
            IdMarcoLegal INT,   
            FechaCarga DATETIME,
            NoVersion INT, 
            Mime VARCHAR(MAX), 
            EntregableInstanciaId INT,          
            FrecuenciaEntregable VARCHAR(MAX),
            FechaProgramadaEntrega DATETIME,
			FechaProgramadaEntregaAnioMes VARCHAR(200),
            CargadoPor VARCHAR(MAX),
            Origen VARCHAR(200),   
            EsDeProceso BIT,
            InstalacionId INT,      
            Pozo VARCHAR(MAX),
			NivelPadre INT,
			EtapaPozoId INT)

		CREATE TABLE #CARPETAS_PER (
			ID INT IDENTITY(1,1), 
			IDCARPETA INT,
			IDVISTA INT
		);

		CREATE TABLE #CantidadArchivosGeneral
		(
			 IdPadre INT,
			 CantidadArchivos INT,
			 NivelPadre INT
		)

		DECLARE @EtapaId INT =  0
		DECLARE @ContadorNiveles INT = 1
		DECLARE @TotalEtapas INT 
		DECLARE @Contador INT
		DECLARE @FechaEtapaInicio DATETIME 
		DECLARE @FechaEtapaFin DATETIME 
		
    
    /*OBTENER DOCUMENTOS DE LOS ENTREGABLES CON ESTATUS APROBADO INTERNAMENTE*/
    BEGIN
     /*OBTENER TODOS LOS DOCUMENTOS DEL CONTRATO - CON ESTATUS APROBADO INTERNAMENTE*/
     INSERT INTO #Documentos(
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
	 FechaProgramadaEntregaAnioMes	=	CAST(YEAR(EI.FechaCalculadaEntregaReg) AS VARCHAR(MAX))+'-'+CAST(FORMAT(EI.FechaCalculadaEntregaReg,'MM') AS VARCHAR(MAX)), --> FORMATO ESPERADO YYYY-MM --> 2020-01 --> SI SE MODIFICA PODRIA AFECTAR A LOS DOCUMENTOS GENERALES 
     CargadoPor						=	U.Nombre,
     Origen							=	'ENTREGABLES',   --> SIRVE PARA IDENTIFICAR QUE LOS ARCHIVOS PROVIENEN DE UN ENTREGABLE ESPECIFICO    
     EsDeProceso					=	CASE WHEN  ISNULL(IPF.IdInstanciasProcesos,0) > 0 THEN 1 ELSE 0 END,
     Pozo							=   REPLACE(COI.NombreInstalacion,'/','-'),
     IdInstalacion					=	P.IdInstalacion,
	 EtapaPozoId					=	P.EtapaPozoId
    FROM EN_ContratoEntregable CE   (NOLOCK)
    JOIN EN_InstanciasEntregable EI	(NOLOCK)
            ON CE.IdContratoEntregable          =   EI.IdContratoEntregable 
            AND CE.IdContrato                   =   @ContratoId
            AND EI.Activo                       =   1   --> EN_InstanciasEntregable ACTIVA
			AND CE.Activo						= 1
    JOIN EN_Entregable E	(NOLOCK)
            ON CE.IdEntregable					   =   E.IdEntregable      
            AND ISNULL(E.IsActivo,0)            =   1   --> EN_Entregable ACTIVA  
            AND E.BitJOA                        =   0	--> JOA --> Activa
    JOIN    EN_Actividad AE	(NOLOCK)
            ON EI.ActividadID=AE.ActividadID
            AND EI.IdContratoEntregable         =   AE.IdContratoEntregable
            AND AE.EstadoID                     =   10003 --> ESTADO APROBADO INTERNAMENTE --> EN_Estado
    JOIN EN_HistorialAprobacionesLineaTiempo ELT	(NOLOCK)
            ON EI.idInstanciaEntregable         =   ELT.idInstanciaEntregable
            AND ELT.idTipoOperacion             =   4 -->ARCHIVOS DE APROBACIÓN -->EN_TipoOperacion
    JOIN EN_DocumentoVersion DV             (NOLOCK)
            ON EI.idInstanciaEntregable         =   DV.idInstanciaEntregable    
            AND ELT.IdLineaTiempo=DV.N_version
            AND DV.Activo                       =   1 --> EN_DocumentoVersion ACTIVO
    JOIN EN_EntregableDocumento ED	(NOLOCK)
            ON DV.idInstanciaEntregable         =   ED.idInstanciaEntregable
            AND DV.DocumentoEntregableId        =   ED.DocumentoEntregableId
            AND ED.idContratoEntregable         =   CE.IdContratoEntregable         
			AND	ED.Activo = 1   --> EN_EntregableDocumento ACTIVO
    JOIN EN_TipoArchivo T		(NOLOCK)
            ON  ED.idTipoArchivo                =   T.idTipoArchivo     
    LEFT JOIN EN_FrecuenciaEntregable   FE	(NOLOCK)
            ON E.IdFrecuenciaEntregable         =   FE.IdFrecuenciaEntregable   
    LEFT JOIN AP_Usuario U                    (NOLOCK)  
            ON  ED.CreadoPor                    =   U.UsuarioID 
    LEFT    JOIN
            EN_InstanciasEntregables_InstanciaActividad IEIA	(NOLOCK)
            ON EI.idInstanciaEntregable =   IEIA.idInstanciaEntregable
    LEFT    JOIN
        EN_InstanciasActividades    IA	(NOLOCK)
        ON  IEIA.idInstanciaActividad   =   IA.idInstanciaActividad
    LEFT JOIN 
        EN_InstanciasProcesosFecha  IPF	(NOLOCK)
        ON  IA.IdInstanciasProcesos =   IPF.IdInstanciasProcesos
    LEFT JOIN 
            EN_Procesos P	(NOLOCK)
            ON  IPF.IdProceso   =   P.IdProceso
    LEFT JOIN 
            CO_Instalacion COI	(NOLOCK)
            ON P.IdInstalacion = COI.IdInstalacion
    WHERE 
    ED.Activo = 1   --> EN_EntregableDocumento ACTIVO
	
    /*OBTENER LA ULTIMA VERSION DE LAS INSTANCIAS*/
    INSERT INTO #DocumentosVersion
	(
		EntregableInstanciaId,
		NoVersion
	)
	SELECT 
		EntregableInstanciaId	=	EntregableInstanciaId,  
		NoVersion				=	MAX(NoVersion)
    FROM #Documentos
    GROUP BY
	    EntregableInstanciaId
                    
    /*ELIMINAR LOS DOCUMENTOS DE LA TABLA TEMPORAL QUE NO SON PARTE DE LA ULTIMA VERSIÓN DE LOS DOCUMENTOS*/
    DELETE D
    FROM #Documentos D
    LEFT JOIN #DocumentosVersion DV
        ON	D.EntregableInstanciaId =   DV.EntregableInstanciaId
        AND D.NoVersion				=   DV.NoVersion
    WHERE DV.NoVersion IS NULL
    END 


    /*CREACIÓN DE LOS NIVELES DE LOS DOCUMENTOS DE ORIGEN DE ENTREGABLES*/

    BEGIN   
     -- NIVEL 1 -- OBTENER LAS ETAPAS DEL CONTRATO ACTUAL

     INSERT INTO #Lista(IDPadre,EtapaId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo,FechaInicioEtapa,FechaFinEtapa)
     SELECT 
		 IDPadre				=	NULL,--> EL NIVEL 1 NUNCA TIENE IDPadre     
		 EtapaId				=	CE.EtapaId,
		 Titulo					=	REPLACE(E.Etapa,'/','-'),
		 Nivel					=	1,
		 Detalle				=	'Etapa',
		 CantidadArchivos		=	COUNT(D.DocumentoEntregableId),
		 TipoArchivo			=	'Carpeta',
		 FechaInicioEtapa		=	CE.FechaInicio,
		 FechaFinEtapa			=	CE.FechaFin
     FROM CO_ContratoEtapas CE	(NOLOCK)
     JOIN EN_Etapa E	(NOLOCK)
        ON      CE.EtapaId      =   E.IdEtapa
		AND		CE.ContratoId        =   @ContratoId
     JOIN #Documentos D        
        ON  D.FechaProgramadaEntrega    BETWEEN CE.FechaInicio AND CE.FechaFin
     WHERE CE.ContratoId        =   @ContratoId
     AND CE.Activo              =   1       
     GROUP BY   
     E.Etapa,
     CE.EtapaId,
	 CE.FechaInicio,
	 CE.FechaFin
     ORDER BY E.Etapa ASC

	 INSERT INTO #Lista(IDPadre,EtapaId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo,FechaInicioEtapa,FechaFinEtapa)
     SELECT 
     IDPadre				=	NULL,--> EL NIVEL 1 NUNCA TIENE IDPadre     
     EtapaId				=	CE.EtapaId,
	 Titulo					=	REPLACE(E.Etapa,'/','-'),
     Nivel					=	1,
     Detalle				=	'Etapa',
     CantidadArchivos		=	0,
     TipoArchivo			=	'Carpeta',
	 FechaInicioEtapa		=	CE.FechaInicio,
	 FechaFinEtapa			=	CE.FechaFin
     FROM CO_ContratoEtapas CE
     JOIN EN_Etapa E
        ON      CE.EtapaId      =   E.IdEtapa
     WHERE CE.ContratoId        =   @ContratoId
     AND CE.Activo              =   1       
	 AND FechaInicio IS NULL
	 AND FechaFin IS NULL
	 AND Carpeta = 1
     GROUP BY   
     E.Etapa,
     CE.EtapaId,
	 CE.FechaInicio,
	 CE.FechaFin
     ORDER BY E.Etapa ASC	

	 END 


	 SELECT @TotalEtapas = COUNT(1) FROM #Lista --> EN NIVEL UNO ESTAN LAS ETAPAS
	 SET @Contador=1

	 /*RECORRER LAS ETAPAS PARA ARMAR LAS SUBCARPETAS DE LOS NIVELES 2 AL 6*/
	 WHILE @TotalEtapas >= @Contador
	 BEGIN 
	        SELECT @EtapaId = EtapaId, 
			@FechaEtapaInicio=FechaInicioEtapa,
			@FechaEtapaFin=FechaFinEtapa 
			FROM #Lista WHERE ID=@Contador

		    -- NIVEL 2-A CARPETAS PARA LOS REGULADORES 
		    INSERT INTO #Lista(IDPadre,EtapaId,ReceptorEntregableId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo)
		    SELECT 
		    IDPadre					=	LD.ID,  
		    EtapaId					=	LD.EtapaId,		    
		    ReceptorEntregableId	=	RE.IdReceptorEntregable,
			Titulo					=	REPLACE(RE.ReceptorEntregable,'/','-'),
		    Nivel					=	2,
		    Detalle					=	'Regulador',
		    CantidadArchivos		=	COUNT(D.DocumentoEntregableId),
		    TipoArchivo				=	'Carpeta'
		    FROM #Lista LD
		    JOIN #Documentos D    
				ON  D.FechaProgramadaEntrega  BETWEEN LD.FechaInicioEtapa AND LD.FechaFinEtapa    
				AND LD.EtapaId=@EtapaId
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
			INSERT INTO #Lista(IDPadre,EtapaId,PozoInstalacionId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo)
			SELECT 
			IDPadre				=	LD.ID,  
			EtapaId				=	LD.EtapaId, 			
			PozoInstalacionId	=	D.InstalacionId,
			Titulo				=	REPLACE(D.Pozo,'/','-'),
			Nivel				=	2,
			Detalle				=	'Pozo',
			CantidadArchivos	=	COUNT(D.DocumentoEntregableId),
			TipoArchivo			=	'Carpeta'
			FROM #Lista LD
			JOIN #Documentos D
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
		    INSERT INTO #Lista(IDPadre,EtapaId,ReceptorEntregableId,MarcoLegalId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo)
		    SELECT 
		    IDPadre					=	LD.ID,  
		    EtapaId					=	LD.EtapaId, 
		    ReceptorEntregableId	=	LD.ReceptorEntregableId,
			MarcoLegalId			=	ML.IdMarcoLegal,
		    Titulo					=	REPLACE(ISNULL(ML.Alias,ML.MarcoLegaL),'/','-'),		    
		    Nivel					=	3,
		    Detalle					=	'Marco Legal',
		    CantidadArchivos		=	COUNT(D.DocumentoEntregableId),
		    TipoArchivo				=	'Carpeta'
		    FROM #Lista LD
		    JOIN #Documentos D    
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
		    ML.Alias,
			ML.MarcoLegaL,
		    ML.IdMarcoLegal
		    ORDER BY ML.MarcoLegal ASC


		    --NIVEL 3-B CARPETA DE ETAPAS DE UN POZO SUBCARPETA DE LOS POZOS
		    INSERT INTO #Lista(IDPadre,EtapaId,PozoInstalacionId,EtapaPozoId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo)
		    SELECT 
		    IDPadre				=	LD.ID,  
		    EtapaId				=	LD.EtapaId, 
		    PozoInstalacionId	=	LD.PozoInstalacionId,		    
		    EtapaPozoId			=	D.EtapaPozoId,
			Titulo				=	REPLACE(EP.Etapa,'/','-'),
		    Nivel				=	3,
		    Detalle				=	'Etapa del pozo',
		    CantidadArchivos	=	COUNT(D.DocumentoEntregableId),
		    TipoArchivo			=	'Carpeta'
		    FROM #Lista LD
		    JOIN #Documentos D
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
			INSERT INTO #Lista(IDPadre,EtapaId,ReceptorEntregableId,MarcoLegalId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo)
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
			FROM #Lista LD  
			WHERE LD.Nivel=2    --> PARA INDICAR QUE LA CARPETA PADRE ES DEL NIVEL 2
			AND LD.EtapaId=@EtapaId
			AND LD.PozoInstalacionId IS NULL
			GROUP BY 
			LD.ID,  
			LD.EtapaId, 
			LD.ReceptorEntregableId
						
			--NIVEL 3-B AGREGAR CARPETA GENERAL POR CADA POZO DE CADA ETAPA ESTO PARA LOS ARCHIVOS GENERALES --PARA LOS POZOS
			INSERT INTO #Lista(IDPadre,EtapaId,PozoInstalacionId,EtapaPozoId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo)
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
			FROM #Lista LD  
			WHERE LD.Nivel =  2   --> DONDE EL PADRE ES UN POZO EN EL NIVEL 2 
			AND LD.EtapaId=@EtapaId
			AND LD.PozoInstalacionId IS NOT NULL			
			GROUP BY 
			LD.ID,  
			LD.EtapaId, 
			LD.PozoInstalacionId
			

			--NIVEL 4-A CARPETAS DE FRECUENCIA DE LOS ENTREGABLES
		    INSERT INTO #Lista(IDPadre,EtapaId,ReceptorEntregableId,MarcoLegalId,FrecuenciaId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo)
		    SELECT 
		    IDPadre						=	LD.ID,  
		    EtapaId						=	LD.EtapaId, 
		    ReceptorEntregableId		=	LD.ReceptorEntregableId,
		    MarcoLegalId				=	LD.MarcoLegalId,	
			FrecuenciaId				=	D.FrecuenciaEntregable,	   
		    Titulo						=	REPLACE(D.FrecuenciaEntregable,'/','-'),			
		    Nivel						=	4,
		    Detalle						=	'Frecuencia',
		    CantidadArchivos			=	COUNT(D.DocumentoEntregableId),
		    TipoArchivo					=	'Carpeta'
		    FROM #Lista LD
		    JOIN #Documentos D
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
			INSERT INTO #Lista(IDPadre,EtapaId,PozoInstalacionId,EtapaPozoId,MarcoLegalId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo)
		    SELECT 
		    IDPadre					=	LD.ID,  
		    EtapaId					=	LD.EtapaId, 
		    PozoInstalacionId		=	LD.PozoInstalacionId,
			EtapaPozoId				=	LD.EtapaPozoId,	
			MarcoLegalId			=	D.IdMarcoLegal,	    	
			Titulo					=	REPLACE(ISNULL(ML.Alias,ML.MarcoLegal),'/','-'),
		    Nivel					=	4,
		    Detalle					=	'Marco Legal',
		    CantidadArchivos		=	COUNT(D.DocumentoEntregableId),
		    TipoArchivo				=	'Carpeta'
		    FROM #Lista LD
		    JOIN #Documentos D
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
		    ML.Alias,
			ML.MarcoLegal
		    ORDER BY ML.MarcoLegal ASC

			--NIVEL 5-A CARPETA DE LA FECHA DE ENTREGA DEL ENTREGABLE AÑO-MES  
		    INSERT INTO #Lista(IDPadre,EtapaId,ReceptorEntregableId,MarcoLegalId,FrecuenciaId,FechaEntregaAnioMes,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo)
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
		    FROM #Lista LD
		    JOIN #Documentos D
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
		    INSERT INTO #Lista(IDPadre,EtapaId,PozoInstalacionId,EtapaPozoId,MarcoLegalId,EntregableId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo)
		    SELECT 
		    IDPadre					=	LD.ID,  
		    EtapaId					=	LD.EtapaId, 
		    PozoInstalacionId		=	LD.PozoInstalacionId,
			EtapaPozoId				=	LD.EtapaPozoId,
		    MarcoLegalId			=	LD.MarcoLegalId,	
			EntregableId			=	D.IdEntregable,	 
			Titulo					=	REPLACE(E.DocumentoEntregable,'/','-'),			
		    Nivel					=	5,
		    Detalle					=	'Entregable',
		    CantidadArchivos		=	COUNT(D.DocumentoEntregableId),
		    TipoArchivo				=	'Carpeta'
		    FROM #Lista LD
		    JOIN #Documentos D
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
		    INSERT INTO #Lista(IDPadre,EtapaId,ReceptorEntregableId,MarcoLegalId,FrecuenciaId,FechaEntregaAnioMes,EntregableId,Titulo,Nivel,Detalle,CantidadArchivos,TipoArchivo)
		    SELECT 
		    IDPadre					=	LD.ID,  
		    EtapaId					=	LD.EtapaId, 
		    ReceptorEntregableId	=	LD.ReceptorEntregableId,
		    MarcoLegalId			=	LD.MarcoLegalId,
			FrecuenciaId			=	LD.FrecuenciaId,
			FechaEntregaAnioMes		=	LD.FechaEntregaAnioMes,
			EntregableId			=	E.IdEntregable,	
			Titulo					=	REPLACE(E.DocumentoEntregable,'/','-'),			
		    Nivel					=	6,
		    Detalle					=	'Entregable',
		    CantidadArchivos		=	COUNT(D.DocumentoEntregableId),
		    TipoArchivo				=	'Carpeta'
		    FROM #Lista LD
		    JOIN #Documentos D
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
			INSERT INTO #Lista(IDPadre,EtapaId,PozoInstalacionId,EtapaPozoId,MarcoLegalId,EntregableId,DocumentoEntregableId,Titulo,Nivel,Detalle,CantidadArchivos,Mime,TipoArchivo,FechaCarga,CargadoPor,Origen,Frecuencia,FechaProgramadaEntrega)
		    SELECT 
		    IDPadre					=	LD.ID,  
		    EtapaId					=	LD.EtapaId, 
		    PozoInstalacionId		=	LD.PozoInstalacionId,
			EtapaPozoId				=	LD.EtapaPozoId,
		    MarcoLegalId			=	LD.MarcoLegalId,	
			EntregableId			=	LD.EntregableId,	 
			DocumentoEntregableId	=	D.DocumentoEntregableId,
			Titulo					=	REPLACE(D.NombreArchivo,'/','-'),			
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
		    FROM #Lista LD
		    JOIN #Documentos D
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
		    INSERT INTO #Lista(IDPadre,EtapaId,ReceptorEntregableId,MarcoLegalId,FrecuenciaId,FechaEntregaAnioMes,EntregableId,DocumentoEntregableId,Titulo,Nivel,Detalle,CantidadArchivos,Mime,TipoArchivo,FechaCarga,CargadoPor,Origen,Frecuencia,FechaProgramadaEntrega)
		    SELECT 
		    IDPadre					=	LD.ID,  
		    EtapaId					=	LD.EtapaId, 
		    ReceptorEntregableId	=	LD.ReceptorEntregableId,
		    MarcoLegalId			=	LD.MarcoLegalId,
			FrecuenciaId			=	LD.FrecuenciaId,
			FechaEntregaAnioMes		=	LD.FechaEntregaAnioMes,
			EntregableId			=	LD.EntregableId,	
			DocumentoEntregableId	=	D.DocumentoEntregableId,
			Titulo					=	REPLACE(D.NombreArchivo,'/','-'),			
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
		    FROM #Lista LD
		    JOIN #Documentos D
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
										
		SET @Contador = @Contador + 1;

	 END 
         
    BEGIN
	   
    UPDATE #Lista
    SET Mime = (CASE WHEN Mime IN('application/pdf') THEN 'PDF' 
                     WHEN Mime IN ('application/vnd.ms-excel','application/vnd.openxmlformats-officedocument.spre',
                     'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') THEN 'EXCEL'
                     WHEN Mime IN ('application/msword',
                                    'application/vnd.openxmlformats-officedocument.word', 'application/vnd.openxmlformats-officedocument.spre',
                                    'text/plain','text/html') THEN 'WORD'
                    WHEN Mime IN ('image/jpeg','image/png','image/gif','image/bmp') THEN 'IMAGEN'
                    ELSE 'ARCHIVO' END)
    WHERE TipoArchivo<>'Carpeta'
    UPDATE #Lista
    SET Mime = 'CORREO'
    WHERE Mime='ARCHIVO'
    AND SUBSTRING(Titulo, LEN(Titulo)-3, LEN(Titulo))=UPPER('.MSG')   

END 


SELECT * FROM #Lista ORDER BY ID ASC;

END
