USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[EN_SHELL_ObtenerDocumentosEntregables_V2]    Script Date: 27/01/2022 10:48:07 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <04/01/2022>
-- Description:	<Consulta de archivos contract files>
-- =============================================
ALTER PROCEDURE [dbo].[EN_SHELL_ObtenerDocumentosEntregables_V2] --[EN_SHELL_ObtenerDocumentosEntregables_V2]3,0,5,10162,1,0,10013,0
	-- Add the parameters for the stored procedure here
	@ContratoId INT,
	@IdUsuario INT,
	@Nivel INT,
	@IdCarpeta INT,
	@Entrar BIT,
	@Atras BIT,
	@Frecuencia INT,
	@IsCarpetaUsuario BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @CONTARCHIVOS INT;

	DECLARE @CONTRACT_FILES TABLE(
		IdRow INT IDENTITY(1,1),
		Nivel INT,
		Nombre VARCHAR(MAX),
		IdCarpeta INT,
		IdDocumento INT,
		Tipo VARCHAR(100),
		CreadoEl DATETIME,
		CreadoPor VARCHAR(100),
		CantidadArchivos INT,
		IdCarpetaAnterior INT,
		Frecuencia INT,
		Funcion NVARCHAR(MAX),
		FuncionTipo NVARCHAR(MAX),
		IsCarpetaUsuario BIT,
		Bucket VARCHAR(100),
		Folder VARCHAR(1000),
		UUID VARCHAR(2000),
		Meta VARCHAR(1000),
		NivelAnterior INT,
		IsCarpetaUsuarioAnterior BIT,
		Ruta VARCHAR(MAX),
		RutaAnterior VARCHAR(MAX)
	);


	DECLARE @Documentos TABLE(
			DocumentoEntregableId INT,
			NombreArchivo NVARCHAR(MAX),
			NoVersion INT, 
			FechaProgramadaEntrega DATETIME,
			EtapaPozoId INT,
			IdReceptorEntregable INT,
			EsDeProceso BIT,
			Pozo VARCHAR(MAX),
			IdInstalacion INT,
			IdMarcoLegal INT,
			FrecuenciaEntregable VARCHAR(MAX),
			IdFrecuenciaEntregable INT,
			FechaProgramadaEntregaAnioMes VARCHAR(MAX),
			IdEntregable INT,
			Entregable VARCHAR(MAX),
			MIME NVARCHAR(1000)
	);

	INSERT INTO @Documentos
	SELECT DISTINCT 
     DocumentoEntregableId			=	ED.DocumentoEntregableId,
	 NombreArchivo					=	ED.NombreArchivo,
     NoVersion						=	DV.N_version, 
     FechaProgramadaEntrega			=	EI.FechaCalculadaEntregaReg,
	 EtapaPozoId					=	P.EtapaPozoId,
	 IdReceptorEntregable			=	E.IdReceptorEntregable,
	 EsDeProceso					=	CASE WHEN  ISNULL(IPF.IdInstanciasProcesos,0) > 0 THEN 1 ELSE 0 END,
	 Pozo							=	COI.NombreInstalacion,
	 IdInstalacion					=	P.IdInstalacion,
	 IdMarcoLegal					=	E.IdMarcoLegal,
	 FrecuenciaEntregable			=	FE.FrecuenciaEntregable,
	 IdFrecuenciaEntregable			=	FE.IdFrecuenciaEntregable,
	 FechaProgramadaEntregaAnioMes	=	CAST(YEAR(EI.FechaCalculadaEntregaReg) AS VARCHAR(MAX))+'-'+CAST(FORMAT(EI.FechaCalculadaEntregaReg,'MM') AS VARCHAR(MAX)),
	 IdEntregable					=	E.IdEntregable,
	 Entregable						=	E.DocumentoEntregable,
	 MIME							=	ED.Meta
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
			AND	ED.Activo = 1   --> EN_EntregableDocumento   
    LEFT JOIN EN_FrecuenciaEntregable   FE	(NOLOCK)
            ON E.IdFrecuenciaEntregable         =   FE.IdFrecuenciaEntregable
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
    ED.Activo = 1;

	IF @Nivel IN (1) --AND @IsCarpetaUsuario = 0 --ETAPAS
	BEGIN
	
		--CONSULTA DE LAS ETAPAS
		INSERT INTO @CONTRACT_FILES(Nivel,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario)
		SELECT 
				 1,
				 E.Etapa,
				 CE.EtapaId,
				 NULL,
				 'Carpeta',
				 NULL,
				 0,
				 'Carpeta de Etapa',
				 'Etapa',
				 0
		FROM CO_ContratoEtapas CE	(NOLOCK)
		JOIN EN_Etapa E	(NOLOCK)
		ON      CE.EtapaId      =   E.IdEtapa
		AND		CE.ContratoId        =   @ContratoId
		JOIN @Documentos D        
			ON  D.FechaProgramadaEntrega    BETWEEN CE.FechaInicio AND CE.FechaFin
		WHERE CE.ContratoId        =   @ContratoId
		AND CE.Activo              =   1  
		GROUP BY   
		E.Etapa,
		CE.EtapaId,
		CE.FechaInicio,
		CE.FechaFin
		ORDER BY E.Etapa ASC;

	END

	IF @Nivel IN (2) --AND @Entrar = 1 --AND @IsCarpetaUsuario = 0 --REGULADOR Y POSOZ
	BEGIN

		--CONSULTA DE LAS REGULADORES
		INSERT INTO @CONTRACT_FILES(Nivel,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,NivelAnterior,IsCarpetaUsuarioAnterior,Ruta,RutaAnterior)
		SELECT 
			2,
			RE.ReceptorEntregable,
			RE.IdReceptorEntregable,
			NULL,
			'Carpeta',
			NULL,
			0,
			'Carpeta de Regulador',
			'Regulador',
			0,
			SC.IdCarpetaAnterior,
			SC.NiveAnterior,
			SC.IsCarpetaUsuarioAnterior,
			SC.Ruta,
			SC.RutaAnterior
		FROM @Documentos D    
			JOIN EN_ReceptorEntregable RE 
		        ON D.IdReceptorEntregable  =   RE.IdReceptorEntregable AND
					D.EsDeProceso = 0 -->QUE NO SEA DOCUMENTO DE UN PROCESO
			JOIN CO_ContratoEtapas CE	(NOLOCK)
				ON D.FechaProgramadaEntrega BETWEEN CE.FechaInicio AND CE.FechaFin
				AND CE.EtapaId = @IdCarpeta
			LEFT JOIN EN_SecuenciaCarpetas AS SC
				ON SC.IdCarpeta = @IdCarpeta
					AND SC.Nivel = @Nivel
					AND SC.IdContrato = @ContratoId
		GROUP BY    
		    RE.ReceptorEntregable,
		    RE.IdReceptorEntregable,
			RE.CreadoEn,
			CE.EtapaId,
			SC.IdCarpetaAnterior,
			SC.NiveAnterior,
			SC.IsCarpetaUsuarioAnterior,
			SC.Ruta,
			SC.RutaAnterior
		ORDER BY RE.ReceptorEntregable ASC;

		--CONSULTA DE LOS POZOS
		INSERT INTO @CONTRACT_FILES(Nivel,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario, IdCarpetaAnterior, Ruta, RutaAnterior)
		SELECT 
			2,
			D.Pozo,
			D.IdInstalacion,
			NULL,
			'Carpeta',
			NULL,
			0,
			'Carpeta de Pozo',
			'Pozo',
			0,
			SC.IdCarpetaAnterior,
			SC.Ruta,
			SC.RutaAnterior
		FROM @Documentos D    
			JOIN EN_ReceptorEntregable RE 
		        ON D.IdReceptorEntregable  =   RE.IdReceptorEntregable AND
					D.EsDeProceso = 1 -->QUE NO SEA DOCUMENTO DE UN PROCESO
			JOIN CO_ContratoEtapas CE	(NOLOCK)
				ON D.FechaProgramadaEntrega BETWEEN CE.FechaInicio AND CE.FechaFin
				AND CE.EtapaId = @IdCarpeta
			LEFT JOIN EN_SecuenciaCarpetas AS SC
				ON SC.IdCarpeta = @IdCarpeta
					AND SC.Nivel = @Nivel
					AND SC.IdContrato = @ContratoId
		GROUP BY    
		    D.Pozo,
			D.IdInstalacion,
			CE.EtapaId,
			SC.IdCarpetaAnterior,
			SC.Ruta,
			SC.RutaAnterior
		ORDER BY D.Pozo ASC;

		--CONSULTA DE LAS CARPETAS POR USUARIO
		INSERT INTO @CONTRACT_FILES(Nivel,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,Ruta,RutaAnterior,CreadoPor)
		SELECT
			2,
			CA.Nombre,
			CA.IdElemento,
			NULL,
			'Carpeta de Usuario',
			CA.CreadoEl,
			0,
			'Carpeta de Usuario',
			'Carpeta de Usuario',
			1,
			CA.IdPadre,
			SC.Ruta,
			SC.RutaAnterior,
			US.Nombre
		FROM EN_CarpetasArchivosVisor AS CA
		LEFT JOIN EN_SecuenciaCarpetas AS SC
				ON SC.IdCarpeta = @IdCarpeta
					AND SC.Nivel = @Nivel
					AND SC.IdContrato = @ContratoId
		LEFT JOIN AP_Usuario AS US
			ON CA.CreadoPor = US.UsuarioID
		WHERE IsCarpeta = 1
			AND IdPadre = @IdCarpeta
			AND CA.Nivel = @Nivel
			AND Activo = 1;

		--CONSULTA DE LOS ARCHIVOS POR USUARIO
		INSERT INTO @CONTRACT_FILES(Nivel,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,Bucket,Folder,UUID,Meta,Ruta,RutaAnterior,CreadoPor)
		SELECT
			2,
			CA.Nombre,
			NULL,
			CA.IdElemento,
			CASE
				WHEN CA.Meta = 'application/pdf' THEN 'Archivo PDF'
				WHEN CA.Meta = 'image/jpeg' THEN 'Archivo JPG'
				WHEN CA.Meta = 'image/png' THEN 'Archivo PNG'
				WHEN CA.Meta = 'text/xml' THEN 'Archivo XML'
				WHEN CA.Meta = 'text/plain' THEN 'Archivo TXT'
				WHEN CA.Meta = 'text/html' THEN 'Archivo TXT'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.spre' THEN 'Archivo XLSX'
				WHEN CA.Meta = 'application/zip' THEN 'Archivo ZIP'
				WHEN CA.Meta = 'application/x-zip-compressed' THEN 'Archivo ZIP'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.word' THEN 'Archivo DOCX'
				WHEN CA.Meta = 'application/msword' THEN 'Archivo DOCX'
				WHEN CA.Meta = 'application/vnd.ms-excel' THEN 'Archivo XLSX'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' THEN 'Archivo XLSX'
				WHEN CA.Meta = 'application/mspowerpoint' THEN 'Archivo PPT'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.pres' THEN 'Archivo PPT'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' THEN 'Archivo DOCX'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.presentationml.presentation'THEN 'Archivo PPT'
				ELSE 'Archivo'
			END,
			CA.CreadoEl,
			0,
			'Archivo de Usuario',
			'Archivo de Usuario',
			0,
			CA.IdPadre,
			CA.Bucket,
			CA.Folder,
			CA.UUIDAmazon,
			CA.Meta,
			SC.Ruta,
			SC.RutaAnterior,
			US.Nombre
		FROM EN_CarpetasArchivosVisor AS CA
		LEFT JOIN EN_SecuenciaCarpetas AS SC
				ON SC.IdCarpeta = @IdCarpeta
					AND SC.Nivel = @Nivel
					AND SC.IdContrato = @ContratoId
		LEFT JOIN AP_Usuario AS US
			ON CA.CreadoPor = US.UsuarioID
		WHERE IsArchivo = 1
			AND IdPadre = @IdCarpeta
			AND CA.Nivel = @Nivel
			AND Activo = 1;

	END

	IF @Nivel IN (3) --AND @Entrar = 1 AND @IsCarpetaUsuario = 0 --MARCO LEGAL
	BEGIN

		INSERT INTO @CONTRACT_FILES(Nivel,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,NivelAnterior,IsCarpetaUsuarioAnterior,Ruta,RutaAnterior)
		SELECT 
			3,
			ML.MarcoLegal,
			ML.IdMarcoLegal,
			NULL,
			'Carpeta',
			NULL,
			0,
			'carpeta de Marco Legal',
			'Marco Legal',
			0,
			SC.IdCarpetaAnterior,
			SC.NiveAnterior,
			SC.IsCarpetaUsuarioAnterior,
			SC.Ruta,
			SC.RutaAnterior
		FROM @Documentos D    
			JOIN EN_MarcoLegal ML
		        ON  D.IdMarcoLegal =   ML.IdMarcoLegal AND
					D.IdReceptorEntregable = @IdCarpeta
			LEFT JOIN EN_SecuenciaCarpetas AS SC
				ON SC.IdCarpeta = @IdCarpeta 
					AND SC.Nivel = @Nivel
					AND SC.IdContrato = @ContratoId
		GROUP BY    
		    ML.MarcoLegal,
			ML.IdMarcoLegal,
			D.EtapaPozoId,
			SC.IdCarpetaAnterior,
			SC.NiveAnterior,
			SC.IsCarpetaUsuarioAnterior,
			SC.Ruta,
			SC.RutaAnterior
		ORDER BY ML.MarcoLegal ASC;

		--CONSULTA DE LAS CARPETAS POR USUARIO
		INSERT INTO @CONTRACT_FILES(Nivel,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,Ruta,RutaAnterior,CreadoPor)
		SELECT
			2,
			CA.Nombre,
			CA.IdElemento,
			NULL,
			'Carpeta de Usuario',
			CA.CreadoEl,
			0,
			'Carpeta de Usuario',
			'Carpeta de Usuario',
			1,
			CA.IdPadre,
			SC.Ruta,
			SC.RutaAnterior,
			US.Nombre
		FROM EN_CarpetasArchivosVisor AS CA
		LEFT JOIN EN_SecuenciaCarpetas AS SC
				ON SC.IdCarpeta = @IdCarpeta
					AND SC.Nivel = @Nivel
					AND SC.IdContrato = @ContratoId
		LEFT JOIN AP_Usuario AS US
			ON CA.CreadoPor = US.UsuarioID
		WHERE IsCarpeta = 1
			AND IdPadre = @IdCarpeta
			AND CA.Nivel = @Nivel
			AND Activo = 1;

		--CONSULTA DE LOS ARCHIVOS POR USUARIO
		INSERT INTO @CONTRACT_FILES(Nivel,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,Ruta,RutaAnterior,CreadoPor,Folder,UUID,Meta)
		SELECT
			2,
			CA.Nombre,
			NULL,
			CA.IdElemento,
			CASE
				WHEN CA.Meta = 'application/pdf' THEN 'Archivo PDF'
				WHEN CA.Meta = 'image/jpeg' THEN 'Archivo JPG'
				WHEN CA.Meta = 'image/png' THEN 'Archivo PNG'
				WHEN CA.Meta = 'text/xml' THEN 'Archivo XML'
				WHEN CA.Meta = 'text/plain' THEN 'Archivo TXT'
				WHEN CA.Meta = 'text/html' THEN 'Archivo TXT'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.spre' THEN 'Archivo XLSX'
				WHEN CA.Meta = 'application/zip' THEN 'Archivo ZIP'
				WHEN CA.Meta = 'application/x-zip-compressed' THEN 'Archivo ZIP'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.word' THEN 'Archivo DOCX'
				WHEN CA.Meta = 'application/msword' THEN 'Archivo DOCX'
				WHEN CA.Meta = 'application/vnd.ms-excel' THEN 'Archivo XLSX'
				WHEN CA.Meta = 'application/mspowerpoint' THEN 'Archivo PPT'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.pres' THEN 'Archivo PPT'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' THEN 'Archivo DOCX'
				ELSE 'Archivo'
			END,
			CA.CreadoEl,
			0,
			'Archivo de Usuario',
			'Archivo de Usuario',
			0,
			CA.IdPadre,
			SC.Ruta,
			SC.RutaAnterior,
			US.Nombre,
			CA.Folder,
			CA.UUIDAmazon,
			CA.Meta
		FROM EN_CarpetasArchivosVisor AS CA
		LEFT JOIN EN_SecuenciaCarpetas AS SC
				ON SC.IdCarpeta = @IdCarpeta
					AND SC.Nivel = @Nivel
					AND SC.IdContrato = @ContratoId
		LEFT JOIN AP_Usuario AS US
			ON CA.CreadoPor = US.UsuarioID
		WHERE IsArchivo = 1
			AND IdPadre = @IdCarpeta
			AND CA.Nivel = @Nivel
			AND Activo = 1;

	END

	IF @Nivel IN (4) --AND @Entrar = 1 AND @IsCarpetaUsuario = 0 --FRECUENCIAS
	BEGIN

		INSERT INTO @CONTRACT_FILES(Nivel,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos,Frecuencia, Funcion, FuncionTipo,IsCarpetaUsuario, IdCarpetaAnterior, NivelAnterior,IsCarpetaUsuarioAnterior,Ruta,RutaAnterior)
		SELECT 
			4,
			D.FrecuenciaEntregable,
			D.IdMarcoLegal,
			NULL,
			'Carpeta',
			NULL,
			0,
			D.IdFrecuenciaEntregable,
			'Carpeta de Frecuencia',
			'Frecuencia',
			0,
			SC.IdCarpetaAnterior,
			SC.NiveAnterior,
			SC.IsCarpetaUsuarioAnterior,
			SC.Ruta,
			SC.RutaAnterior
		FROM @Documentos D    
		LEFT JOIN EN_SecuenciaCarpetas AS SC
				ON SC.IdCarpeta = @IdCarpeta 
					AND SC.Nivel = @Nivel
					AND SC.IdContrato = @ContratoId
		WHERE D.IdMarcoLegal = @IdCarpeta
		GROUP BY    
		    D.FrecuenciaEntregable,
			D.IdMarcoLegal,
			D.IdFrecuenciaEntregable,
			SC.IdCarpetaAnterior,
			SC.NiveAnterior,
			SC.IsCarpetaUsuarioAnterior,
			SC.Ruta,
			SC.RutaAnterior
		ORDER BY D.FrecuenciaEntregable ASC;

		--CONSULTA DE LAS CARPETAS POR USUARIO
		INSERT INTO @CONTRACT_FILES(Nivel,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,Ruta,RutaAnterior, CreadoPor)
		SELECT
			2,
			CA.Nombre,
			CA.IdElemento,
			NULL,
			'Carpeta de Usuario',
			CA.CreadoEl,
			0,
			'Carpeta de Usuario',
			'Carpeta de Usuario',
			1,
			CA.IdPadre,
			SC.Ruta,
			SC.RutaAnterior,
			US.Nombre
		FROM EN_CarpetasArchivosVisor AS CA
		LEFT JOIN EN_SecuenciaCarpetas AS SC
				ON SC.IdCarpeta = @IdCarpeta
					AND SC.Nivel = @Nivel
					AND SC.IdContrato = @ContratoId
		LEFT JOIN AP_Usuario AS US
			ON CA.CreadoPor = US.UsuarioID
		WHERE IsCarpeta = 1
			AND IdPadre = @IdCarpeta
			AND CA.Nivel = @Nivel
			AND Activo = 1;

		--CONSULTA DE LOS ARCHIVOS POR USUARIO
		INSERT INTO @CONTRACT_FILES(Nivel,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,Ruta,RutaAnterior, CreadoPor,Folder,UUID,Meta)
		SELECT
			2,
			CA.Nombre,
			NULL,
			CA.IdElemento,
			CASE
				WHEN CA.Meta = 'application/pdf' THEN 'Archivo PDF'
				WHEN CA.Meta = 'image/jpeg' THEN 'Archivo JPG'
				WHEN CA.Meta = 'image/png' THEN 'Archivo PNG'
				WHEN CA.Meta = 'text/xml' THEN 'Archivo XML'
				WHEN CA.Meta = 'text/plain' THEN 'Archivo TXT'
				WHEN CA.Meta = 'text/html' THEN 'Archivo TXT'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.spre' THEN 'Archivo XLSX'
				WHEN CA.Meta = 'application/zip' THEN 'Archivo ZIP'
				WHEN CA.Meta = 'application/x-zip-compressed' THEN 'Archivo ZIP'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.word' THEN 'Archivo DOCX'
				WHEN CA.Meta = 'application/msword' THEN 'Archivo DOCX'
				WHEN CA.Meta = 'application/vnd.ms-excel' THEN 'Archivo XLSX'
				WHEN CA.Meta = 'application/mspowerpoint' THEN 'Archivo PPT'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.pres' THEN 'Archivo PPT'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' THEN 'Archivo DOCX'
				ELSE 'Archivo'
			END,
			CA.CreadoEl,
			0,
			'Archivo de Usuario',
			'Archivo de Usuario',
			0,
			CA.IdPadre,
			SC.Ruta,
			SC.RutaAnterior,
			US.CreadoPor,
			CA.Folder,
			CA.UUIDAmazon,
			CA.Meta
		FROM EN_CarpetasArchivosVisor AS CA
		LEFT JOIN EN_SecuenciaCarpetas AS SC
				ON SC.IdCarpeta = @IdCarpeta
					AND SC.Nivel = @Nivel
					AND SC.IdContrato = @ContratoId
		LEFT JOIN AP_Usuario AS US
			ON CA.CreadoPor = US.UsuarioID
		WHERE IsArchivo = 1
			AND IdPadre = @IdCarpeta
			AND CA.Nivel = @Nivel
			AND Activo = 1;

	END

	IF @Nivel IN (5) AND @Entrar = 1 AND @IsCarpetaUsuario = 0--AÑO-MES ENTREGA
	BEGIN

		INSERT INTO @CONTRACT_FILES(Nivel,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,NivelAnterior,IsCarpetaUsuarioAnterior,Ruta,RutaAnterior, Frecuencia)
		SELECT 
			5,
			D.FechaProgramadaEntregaAnioMes,
			D.IdEntregable,
			NULL,
			'Carpeta',
			NULL,
			0,
			'Carpeta de Año-Mes Entrega',
			'Año-Mes Entrega',
			0,
			SC.IdCarpetaAnterior,
			SC.NiveAnterior,
			SC.IsCarpetaUsuarioAnterior,
			SC.Ruta,
			SC.RutaAnterior,
			SC.Frecuencia
		FROM @Documentos D 
		LEFT JOIN EN_SecuenciaCarpetas AS SC
				ON SC.IdCarpeta = @IdCarpeta 
					AND SC.Nivel = @Nivel
					AND SC.IdContrato = @ContratoId
					AND SC.Frecuencia = @Frecuencia
		WHERE D.IdMarcoLegal = @IdCarpeta AND IdFrecuenciaEntregable = @Frecuencia
		GROUP BY    
		    D.FechaProgramadaEntregaAnioMes,
			D.IdEntregable,
			SC.IdCarpetaAnterior,
			SC.NiveAnterior,
			SC.IsCarpetaUsuarioAnterior,
			SC.Ruta,
			SC.RutaAnterior,
			SC.Frecuencia
		ORDER BY D.FechaProgramadaEntregaAnioMes ASC;

		UPDATE @CONTRACT_FILES
		SET IdCarpetaAnterior = @IdCarpeta;

		--CONSULTA DE LAS CARPETAS POR USUARIO
		INSERT INTO @CONTRACT_FILES(Nivel,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,Ruta,RutaAnterior, CreadoPor,Frecuencia)
		SELECT
			CA.Nivel,
			CA.Nombre,
			CA.IdElemento,
			NULL,
			'Carpeta de Usuario',
			CA.CreadoEl,
			0,
			'Carpeta de Usuario',
			'Carpeta de Usuario',
			1,
			CA.IdPadre,
			SC.Ruta,
			SC.RutaAnterior,
			US.Nombre,
			@Frecuencia
		FROM EN_CarpetasArchivosVisor AS CA
		LEFT JOIN EN_SecuenciaCarpetas AS SC
				ON SC.IdCarpeta = @IdCarpeta
					AND SC.Nivel = @Nivel
					AND SC.IdContrato = @ContratoId
		LEFT JOIN AP_Usuario AS US
			ON CA.CreadoPor = US.UsuarioID
		WHERE IsCarpeta = 1
			AND IdPadre = @IdCarpeta
			AND CA.Nivel = @Nivel
			AND Activo = 1;

		--CONSULTA DE LOS ARCHIVOS POR USUARIO
		INSERT INTO @CONTRACT_FILES(Nivel,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,Ruta,RutaAnterior, CreadoPor,Frecuencia,Folder,UUID,Meta)
		SELECT
			2,
			CA.Nombre,
			NULL,
			CA.IdElemento,
			CASE
				WHEN CA.Meta = 'application/pdf' THEN 'Archivo PDF'
				WHEN CA.Meta = 'image/jpeg' THEN 'Archivo JPG'
				WHEN CA.Meta = 'image/png' THEN 'Archivo PNG'
				WHEN CA.Meta = 'text/xml' THEN 'Archivo XML'
				WHEN CA.Meta = 'text/plain' THEN 'Archivo TXT'
				WHEN CA.Meta = 'text/html' THEN 'Archivo TXT'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.spre' THEN 'Archivo XLSX'
				WHEN CA.Meta = 'application/zip' THEN 'Archivo ZIP'
				WHEN CA.Meta = 'application/x-zip-compressed' THEN 'Archivo ZIP'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.word' THEN 'Archivo DOCX'
				WHEN CA.Meta = 'application/msword' THEN 'Archivo DOCX'
				WHEN CA.Meta = 'application/vnd.ms-excel' THEN 'Archivo XLSX'
				WHEN CA.Meta = 'application/mspowerpoint' THEN 'Archivo PPT'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.pres' THEN 'Archivo PPT'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' THEN 'Archivo DOCX'
				ELSE 'Archivo'
			END,
			CA.CreadoEl,
			'Archivo de Usuario',
			'Archivo de Usuario',
			0,
			CA.IdPadre,
			SC.Ruta,
			SC.RutaAnterior,
			US.CreadoPor,
			@Frecuencia,
			CA.Folder,
			CA.UUIDAmazon,
			CA.Meta
		FROM EN_CarpetasArchivosVisor AS CA
		LEFT JOIN EN_SecuenciaCarpetas AS SC
				ON SC.IdCarpeta = @IdCarpeta
					AND SC.Nivel = @Nivel
					AND SC.IdContrato = @ContratoId
		LEFT JOIN AP_Usuario AS US
			ON CA.CreadoPor = US.UsuarioID
		WHERE IsArchivo = 1
			AND IdPadre = @IdCarpeta
			AND CA.Nivel = @Nivel
			AND Activo = 1;

	END

	IF @Nivel IN (6) --AND @Entrar = 1 AND @IsCarpetaUsuario = 0 --FRECUENCIAS
	BEGIN

		INSERT INTO @CONTRACT_FILES(Nivel,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos,Funcion,FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,NivelAnterior,IsCarpetaUsuarioAnterior,Ruta,RutaAnterior,Frecuencia)
		SELECT 
			6,
			D.Entregable,
			D.DocumentoEntregableId,
			NULL,
			'Carpeta',
			NULL,
			0,
			'Carpeta de Entregable',
			'Entregable',
			0,
			SC.IdCarpetaAnterior,
			SC.NiveAnterior,
			SC.IsCarpetaUsuarioAnterior,
			SC.Ruta,
			SC.RutaAnterior,
			@Frecuencia
		FROM @Documentos D 
		LEFT JOIN EN_SecuenciaCarpetas AS SC
				ON SC.IdCarpeta = @IdCarpeta 
					AND SC.Nivel = @Nivel
					AND SC.IdContrato = @ContratoId
		WHERE D.IdEntregable = @IdCarpeta
		GROUP BY    
		    D.Entregable,
			D.DocumentoEntregableId,
			SC.IdCarpetaAnterior,
			SC.NiveAnterior,
			SC.IsCarpetaUsuarioAnterior,
			SC.Ruta,
			SC.RutaAnterior
		ORDER BY D.Entregable ASC;

		--CONSULTA DE LAS CARPETAS POR USUARIO
		INSERT INTO @CONTRACT_FILES(Nivel,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,Ruta,RutaAnterior,CreadoPor,Frecuencia)
		SELECT
			6,
			CA.Nombre,
			CA.IdElemento,
			NULL,
			'Carpeta de Usuario',
			CA.CreadoEl,
			0,
			'Carpeta de Usuario',
			'Carpeta de Usuario',
			1,
			CA.IdPadre,
			SC.Ruta,
			SC.RutaAnterior,
			US.Nombre,
			@Frecuencia
		FROM EN_CarpetasArchivosVisor AS CA
		LEFT JOIN EN_SecuenciaCarpetas AS SC
				ON SC.IdCarpeta = @IdCarpeta
					AND SC.Nivel = @Nivel
					AND SC.IdContrato = @ContratoId
		LEFT JOIN AP_Usuario AS US
			ON CA.CreadoPor = US.UsuarioID
		WHERE IsCarpeta = 1
			AND IdPadre = @IdCarpeta
			AND CA.Nivel = @Nivel
			AND Activo = 1;

		--CONSULTA DE LOS ARCHIVOS POR USUARIO
		INSERT INTO @CONTRACT_FILES(Nivel,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,Ruta,RutaAnterior,CreadoPor,Frecuencia,Folder,UUID,Meta)
		SELECT
			6,
			CA.Nombre,
			NULL,
			CA.IdElemento,
			CASE
				WHEN CA.Meta = 'application/pdf' THEN 'Archivo PDF'
				WHEN CA.Meta = 'image/jpeg' THEN 'Archivo JPG'
				WHEN CA.Meta = 'image/png' THEN 'Archivo PNG'
				WHEN CA.Meta = 'text/xml' THEN 'Archivo XML'
				WHEN CA.Meta = 'text/plain' THEN 'Archivo TXT'
				WHEN CA.Meta = 'text/html' THEN 'Archivo TXT'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.spre' THEN 'Archivo XLSX'
				WHEN CA.Meta = 'application/zip' THEN 'Archivo ZIP'
				WHEN CA.Meta = 'application/x-zip-compressed' THEN 'Archivo ZIP'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.word' THEN 'Archivo DOCX'
				WHEN CA.Meta = 'application/msword' THEN 'Archivo DOCX'
				WHEN CA.Meta = 'application/vnd.ms-excel' THEN 'Archivo XLSX'
				WHEN CA.Meta = 'application/mspowerpoint' THEN 'Archivo PPT'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.pres' THEN 'Archivo PPT'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' THEN 'Archivo DOCX'
				ELSE 'Archivo'
			END,
			CA.CreadoEl,
			0,
			'Archivo de Usuario',
			'Archivo de Usuario',
			0,
			CA.IdPadre,
			SC.Ruta,
			SC.RutaAnterior,
			US.Nombre,
			@Frecuencia,
			CA.Folder,
			CA.UUIDAmazon,
			CA.Meta
		FROM EN_CarpetasArchivosVisor AS CA
		LEFT JOIN EN_SecuenciaCarpetas AS SC
				ON SC.IdCarpeta = @IdCarpeta
					AND SC.Nivel = @Nivel
					AND SC.IdContrato = @ContratoId
		LEFT JOIN AP_Usuario AS US
			ON CA.CreadoPor = US.UsuarioID
		WHERE IsArchivo = 1
			AND IdPadre = @IdCarpeta
			AND CA.Nivel = @Nivel
			AND Activo = 1;

	END

	IF @Nivel IN (7) --AND @Entrar = 1 AND @IsCarpetaUsuario = 0 --ARCHIVO ENTREGABLE
	BEGIN

		INSERT INTO @CONTRACT_FILES(Nivel,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos,Funcion,IsCarpetaUsuario,IdCarpetaAnterior,NivelAnterior,IsCarpetaUsuarioAnterior,Ruta,RutaAnterior,Frecuencia)
		SELECT 
			7,
			D.NombreArchivo,
			NULL,
			D.DocumentoEntregableId,
			CASE
				WHEN D.MIME = 'application/pdf' THEN 'Archivo PDF'
				WHEN D.MIME = 'image/jpeg' THEN 'Archivo JPG'
				WHEN D.MIME = 'image/png' THEN 'Archivo PNG'
				WHEN D.MIME = 'text/xml' THEN 'Archivo XML'
				WHEN D.MIME = 'text/plain' THEN 'Archivo TXT'
				WHEN D.MIME = 'text/html' THEN 'Archivo TXT'
				WHEN D.MIME = 'application/vnd.openxmlformats-officedocument.spre' THEN 'Archivo XLSX'
				WHEN D.MIME = 'application/zip' THEN 'Archivo ZIP'
				WHEN D.MIME = 'application/x-zip-compressed' THEN 'Archivo ZIP'
				WHEN D.MIME = 'application/vnd.openxmlformats-officedocument.word' THEN 'Archivo DOCX'
				WHEN D.MIME = 'application/msword' THEN 'Archivo DOCX'
				WHEN D.MIME = 'application/vnd.ms-excel' THEN 'Archivo XLSX'
				WHEN D.MIME = 'application/mspowerpoint' THEN 'Archivo PPT'
				WHEN D.MIME = 'application/vnd.openxmlformats-officedocument.pres' THEN 'Archivo PPT'
				WHEN D.MIME = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' THEN 'Archivo DOCX'
				ELSE 'Archivo'
			END,
			NULL,
			0,
			'Archivo de Entregable',
			0,
			SC.IdCarpetaAnterior,
			SC.NiveAnterior,
			SC.IsCarpetaUsuarioAnterior,
			SC.Ruta,
			SC.RutaAnterior,
			@Frecuencia
		FROM @Documentos D 
		LEFT JOIN EN_SecuenciaCarpetas AS SC
				ON SC.IdCarpeta = @IdCarpeta 
					AND SC.Nivel = @Nivel
					AND SC.IdContrato = @ContratoId
		WHERE D.DocumentoEntregableId = @IdCarpeta
		GROUP BY    
		    D.NombreArchivo,
			D.DocumentoEntregableId,
			D.MIME,
			SC.IdCarpetaAnterior,
			SC.NiveAnterior,
			SC.IsCarpetaUsuarioAnterior,
			SC.Ruta,
			SC.RutaAnterior
		ORDER BY D.NombreArchivo ASC;


		--CONSULTA DE LAS CARPETAS POR USUARIO
		INSERT INTO @CONTRACT_FILES(Nivel,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,Ruta,RutaAnterior,CreadoPor,Frecuencia)
		SELECT
			7,
			CA.Nombre,
			CA.IdElemento,
			NULL,
			'Carpeta de Usuario',
			CA.CreadoEl,
			0,
			'Carpeta de Usuario',
			'Carpeta de Usuario',
			1,
			CA.IdPadre,
			SC.Ruta,
			SC.RutaAnterior,
			US.Nombre,@Frecuencia
		FROM EN_CarpetasArchivosVisor AS CA
		LEFT JOIN EN_SecuenciaCarpetas AS SC
				ON SC.IdCarpeta = @IdCarpeta
					AND SC.Nivel = @Nivel
					AND SC.IdContrato = @ContratoId
		LEFT JOIN AP_Usuario AS US
			ON CA.CreadoPor = US.UsuarioID
		WHERE IsCarpeta = 1
			AND IdPadre = @IdCarpeta
			AND CA.Nivel = @Nivel
			AND Activo = 1;

		--CONSULTA DE LOS ARCHIVOS POR USUARIO
		INSERT INTO @CONTRACT_FILES(Nivel,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,CreadoPor,Folder,UUID,Meta)
		SELECT
			7,
			CA.Nombre,
			NULL,
			CA.IdElemento,
			CASE
				WHEN CA.Meta = 'application/pdf' THEN 'Archivo PDF'
				WHEN CA.Meta = 'image/jpeg' THEN 'Archivo JPG'
				WHEN CA.Meta = 'image/png' THEN 'Archivo PNG'
				WHEN CA.Meta = 'text/xml' THEN 'Archivo XML'
				WHEN CA.Meta = 'text/plain' THEN 'Archivo TXT'
				WHEN CA.Meta = 'text/html' THEN 'Archivo TXT'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.spre' THEN 'Archivo XLSX'
				WHEN CA.Meta = 'application/zip' THEN 'Archivo ZIP'
				WHEN CA.Meta = 'application/x-zip-compressed' THEN 'Archivo ZIP'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.word' THEN 'Archivo DOCX'
				WHEN CA.Meta = 'application/msword' THEN 'Archivo DOCX'
				WHEN CA.Meta = 'application/vnd.ms-excel' THEN 'Archivo XLSX'
				WHEN CA.Meta = 'application/mspowerpoint' THEN 'Archivo PPT'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.pres' THEN 'Archivo PPT'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' THEN 'Archivo DOCX'
				ELSE 'Archivo'
			END,
			CA.CreadoEl,
			0,
			'Archivo de Usuario',
			'Archivo de Usuario',
			0,
			CA.IdPadre,
			US.Nombre,
			CA.Folder,
			CA.UUIDAmazon,
			CA.Meta
		FROM EN_CarpetasArchivosVisor AS CA
		LEFT JOIN AP_Usuario AS US
			ON CA.CreadoPor = US.UsuarioID
		WHERE IsArchivo = 1
			AND IdPadre = @IdCarpeta
			AND Nivel = @Nivel
			AND Activo = 1;

	END

	IF @IsCarpetaUsuario = 1 
	BEGIN

		--BUSCAR LAS CARPETAS DE USUARIO DENTRO DE LAS CARPETAS DE USUARIO
		INSERT INTO @CONTRACT_FILES(Nivel,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,NivelAnterior,IsCarpetaUsuarioAnterior,Ruta,RutaAnterior, CreadoPor)
		SELECT
			CA.Nivel,
			CA.Nombre,
			CA.IdElemento,
			NULL,
			'Carpeta de Usuario',
			CA.CreadoEl,
			0,
			'Carpeta de Usuario',
			'Carpeta de Usuario',
			1,
			SC.IdCarpetaAnterior,
			SC.NiveAnterior,
			SC.IsCarpetaUsuarioAnterior,
			SC.Ruta,
			SC.RutaAnterior,
			US.Nombre
		FROM EN_CarpetasArchivosVisor AS CA
		LEFT JOIN EN_SecuenciaCarpetas AS SC
				ON SC.IdCarpeta = @IdCarpeta 
					--AND SC.Nivel = @Nivel
					AND SC.IdContrato = @ContratoId
					AND IsCarpetaUsuario = 1
		LEFT JOIN AP_Usuario AS US
			ON CA.CreadoPor = US.UsuarioID
		WHERE IsCarpeta = 1
			AND IdPadre = @IdCarpeta
			AND Activo = 1
		GROUP BY CA.Nombre,
			CA.IdElemento,
			CA.IdPadre,
			CA.Nivel,
			SC.IdCarpetaAnterior,
			SC.NiveAnterior,
			SC.IsCarpetaUsuarioAnterior,
			SC.Ruta,
			SC.RutaAnterior,
			US.Nombre,
			CA.CreadoEl;

		--CONSULTA DE LOS ARCHIVOS POR USUARIO
		INSERT INTO @CONTRACT_FILES(Nivel,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,Ruta,RutaAnterior,IsCarpetaUsuarioAnterior,NivelAnterior, CreadoPor,Folder,UUID,Meta)
		SELECT
			CA.Nivel,
			CA.Nombre,
			NULL,
			CA.IdElemento,
			CASE
				WHEN CA.Meta = 'application/pdf' THEN 'Archivo PDF'
				WHEN CA.Meta = 'image/jpeg' THEN 'Archivo JPG'
				WHEN CA.Meta = 'image/png' THEN 'Archivo PNG'
				WHEN CA.Meta = 'text/xml' THEN 'Archivo XML'
				WHEN CA.Meta = 'text/plain' THEN 'Archivo TXT'
				WHEN CA.Meta = 'text/html' THEN 'Archivo TXT'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.spre' THEN 'Archivo XLSX'
				WHEN CA.Meta = 'application/zip' THEN 'Archivo ZIP'
				WHEN CA.Meta = 'application/x-zip-compressed' THEN 'Archivo ZIP'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.word' THEN 'Archivo DOCX'
				WHEN CA.Meta = 'application/msword' THEN 'Archivo DOCX'
				WHEN CA.Meta = 'application/vnd.ms-excel' THEN 'Archivo XLSX'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' THEN 'Archivo XLSX'
				WHEN CA.Meta = 'application/mspowerpoint' THEN 'Archivo PPT'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.pres' THEN 'Archivo PPT'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' THEN 'Archivo DOCX'
				WHEN CA.Meta = 'application/vnd.openxmlformats-officedocument.presentationml.presentation'THEN 'Archivo PPT'
				ELSE 'Archivo'
			END,
			CA.CreadoEl,
			0,
			'Archivo de Usuario',
			'Archivo de Usuario',
			1,
			SC.IdCarpetaAnterior,
			SC.Ruta,
			SC.RutaAnterior,
			SC.IsCarpetaUsuarioAnterior,
			SC.NiveAnterior,
			US.Nombre,
			CA.Folder,
			CA.UUIDAmazon,
			CA.Meta
		FROM EN_CarpetasArchivosVisor AS CA
		LEFT JOIN EN_SecuenciaCarpetas AS SC
				ON SC.IdCarpeta = @IdCarpeta 
					--AND SC.Nivel = @Nivel
					AND SC.IdContrato = @ContratoId
		LEFT JOIN AP_Usuario AS US
			ON CA.CreadoPor = US.UsuarioID
		WHERE IsArchivo = 1
			AND IdPadre = @IdCarpeta
			AND Activo = 1;

	END

	SET @CONTARCHIVOS = (SELECT COUNT(1) FROM @CONTRACT_FILES);

	SELECT
		IdRow,
		Nivel,
		CASE 
			WHEN LEN(Nombre) > 20 THEN '<marquee behavior="scroll" direction="left" style="width: 70%;">' + Nombre + '</marquee>'
			ELSE Nombre
		END AS NombreLabel,
		Nombre,
		IdCarpeta,
		IdDocumento,
		Tipo,
		CASE
			WHEN CreadoEl IS NOT NULL THEN 'Creado el ' + CONVERT(varchar,CreadoEl,103)
			ELSE ''
		END AS CreadoEl,
		CantidadArchivos,
		IdCarpetaAnterior,
		ISNULL(Frecuencia,0) AS Frecuencia,
		LEFT(Funcion,50) AS Funcion,
		FuncionTipo,
		IsCarpetaUsuario,
		Bucket,
		Folder,
		UUID,
		Meta,
		Nombre AS NombreArchivo,
		ISNULL(NivelAnterior,(Nivel - 1)) AS NivelAnterior,
		ISNULL(IsCarpetaUsuarioAnterior,0) AS IsCarpetaUsuarioAnterior,
		RutaAnterior,
		Ruta,
		CASE
			WHEN CreadoPor IS NOT NULL THEN ('Por ' + CreadoPor)
			ELSE ''
		END AS CreadoPor,
		@CONTARCHIVOS AS CONTARCHIVOS
	FROM @CONTRACT_FILES
	WHERE Nombre IS NOT NULL
	ORDER BY IdRow ASC;

END
