USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'EN_SHELL_ObtenerDocumentosEntregables_V2'
)
    DROP PROCEDURE EN_SHELL_ObtenerDocumentosEntregables_V2;
GO 
/****** Object:  StoredProcedure [dbo].[EN_SHELL_ObtenerDocumentosEntregables_V2]    Script Date: 27/03/2023 04:19:07 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <04/01/2022>
-- Description:	<Consulta de archivos contract files>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: <01/12/2022>
-- Description:	Se agrega filtro para etapa por contrato de las carpetas por niveles, se agrega contratoId faltante  27/03/2023
-- =============================================
CREATE PROCEDURE [dbo].[EN_SHELL_ObtenerDocumentosEntregables_V2] 
    -- Add the parameters for the stored procedure here
    @ContratoId INT,
    @IdUsuario INT,
    @Nivel INT,
    @IdCarpeta INT,
    @Entrar BIT,
    @Atras BIT,
    @Frecuencia INT,
    @IsCarpetaUsuario BIT,
    @IdReceptorEntregable INT,
    @AnioMes NVARCHAR(10),
    @IsPozo BIT,
    @Etapa INT,
    @IdEntregable INT = null,
	@IdEtapaContrato INT 
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    -- Insert statements for procedure here
    DECLARE @CONTARCHIVOS INT,
            @ANIOMES_INT VARCHAR(10),
            @LIMITADOR INT = (SELECT TOP 1
                                    Limitador
                                FROM EN_CarpetasArchivosVisor 
                                WHERE IdElemento = @IdCarpeta
                                AND IsCarpeta = 1
                                AND IdContrato = @ContratoId);

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
        RutaAnterior VARCHAR(MAX),
        CredoPorUsuario BIT,
        IdReceptorEntregable INT,
        IsPozo BIT,
        Etapa INT,
        AnioMes VARCHAR(10),
        Limitador INT,
        IdEntregable INT,
        Alias NVARCHAR(100),
		IdEtapaContrato INT
    );
    CREATE TABLE #Documentos(
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
            IdInstalacion INT,
            Pozo VARCHAR(MAX),
            NivelPadre INT,
            EtapaPozoId INT,
            FrecuenciaEntregableID int,
            Entregable VARCHAR(MAX),
			IdEtapaContrato INT
    );
    CREATE TABLE #DocumentosVersion
    (
        EntregableInstanciaId   INT,
        NoVersion   INT
    );
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
     IdInstalacion,
     EtapaPozoId,
     FrecuenciaEntregableID,
     Entregable)
    SELECT DISTINCT
     DocumentoEntregableId          =   ED.DocumentoEntregableId,
     NombreArchivo                  =   ED.NombreArchivo,
     idTipoArchivo                  =   ED.idTipoArchivo,
     TipoArchivo                    =   T.Nombrearchivo,
     IdEntregable                   =   E.IdEntregable,
     IdReceptorEntregable           =   E.IdReceptorEntregable,
     IdEtapa                        =   NULL,  --> ESTA ETAPA SE OBTIENE DE CO_ContratoEtapas 
     IdMarcoLegal                   =   E.IdMarcoLegal,
     FechaCarga                     =   ED.CreadoEl,
     NoVersion                      =   DV.N_version,
     Mime                           =   ED.Meta,
     EntregableInstanciaId          =   EI.idInstanciaEntregable,
     FrecuenciaEntregable           =   FE.FrecuenciaEntregable,
     FechaProgramadaEntrega         =   EI.FechaCalculadaEntregaReg,
     FechaProgramadaEntregaAnioMes  =   CAST(YEAR(EI.FechaCalculadaEntregaReg) AS VARCHAR(MAX))+'-'+CAST(FORMAT(EI.FechaCalculadaEntregaReg,'MM') AS VARCHAR(MAX)), --> FORMATO ESPERADO YYYY-MM --> 2020-01 --> SI SE MODIFICA PODRIA AFECTAR A LOS DOCUMENTOS GENERALES 
     CargadoPor                     =   U.Nombre,
     Origen                         =   'ENTREGABLES',   --> SIRVE PARA IDENTIFICAR QUE LOS ARCHIVOS PROVIENEN DE UN ENTREGABLE ESPECIFICO    
     EsDeProceso                    =   CASE WHEN  ISNULL(IPF.IdInstanciasProcesos,0) > 0 THEN 1 ELSE 0 END,
     Pozo                           =   COI.NombreInstalacion,
     IdInstalacion                  =   P.IdInstalacion,
     EtapaPozoId                    =   P.EtapaPozoId,
     FrecuenciaEntregableID         =   FE.IdFrecuenciaEntregable,
     Entregable                     =   E.DocumentoEntregable
    FROM EN_ContratoEntregable CE   (NOLOCK)
    JOIN EN_InstanciasEntregable EI (NOLOCK)
            ON CE.IdContratoEntregable          =   EI.IdContratoEntregable 
            AND CE.IdContrato                   =   @ContratoId
            AND EI.Activo                       =   1   --> EN_InstanciasEntregable ACTIVA
            AND CE.Activo                       = 1
    JOIN EN_Entregable E    (NOLOCK)
            ON CE.IdEntregable                     =   E.IdEntregable      
            AND ISNULL(E.IsActivo,0)            =   1   --> EN_Entregable ACTIVA  
            AND E.BitJOA                        =   0   --> JOA --> Activa
    JOIN    EN_Actividad AE (NOLOCK)
            ON EI.ActividadID=AE.ActividadID
            AND EI.IdContratoEntregable         =   AE.IdContratoEntregable
            AND AE.EstadoID                     =   10003 --> ESTADO APROBADO INTERNAMENTE --> EN_Estado
    JOIN EN_HistorialAprobacionesLineaTiempo ELT    (NOLOCK)
            ON EI.idInstanciaEntregable         =   ELT.idInstanciaEntregable
            AND ELT.idTipoOperacion             =   4 -->ARCHIVOS DE APROBACIÓN -->EN_TipoOperacion
    JOIN EN_DocumentoVersion DV             (NOLOCK)
            ON EI.idInstanciaEntregable         =   DV.idInstanciaEntregable    
            AND ELT.IdLineaTiempo=DV.N_version
            AND DV.Activo                       =   1 --> EN_DocumentoVersion ACTIVO
    JOIN EN_EntregableDocumento ED  (NOLOCK)
            ON DV.idInstanciaEntregable         =   ED.idInstanciaEntregable
            AND DV.DocumentoEntregableId        =   ED.DocumentoEntregableId
            AND CE.IdContratoEntregable			= ED.idContratoEntregable                   
            AND ED.Activo = 1   --> EN_EntregableDocumento ACTIVO
    JOIN EN_TipoArchivo T       (NOLOCK)
            ON  ED.idTipoArchivo                =   T.idTipoArchivo     
    LEFT JOIN EN_FrecuenciaEntregable   FE  (NOLOCK)
            ON E.IdFrecuenciaEntregable         =   FE.IdFrecuenciaEntregable   
    LEFT JOIN AP_Usuario U                    (NOLOCK)
            ON  ED.CreadoPor                    =   U.UsuarioID 
    LEFT    JOIN
            EN_InstanciasEntregables_InstanciaActividad IEIA    (NOLOCK)
            ON EI.idInstanciaEntregable =   IEIA.idInstanciaEntregable
    LEFT    JOIN
        EN_InstanciasActividades    IA  (NOLOCK)
        ON  IEIA.idInstanciaActividad   =   IA.idInstanciaActividad
    LEFT JOIN
        EN_InstanciasProcesosFecha  IPF (NOLOCK)
        ON  IA.IdInstanciasProcesos =   IPF.IdInstanciasProcesos
    LEFT JOIN
            EN_Procesos P   (NOLOCK)
            ON  IPF.IdProceso   =   P.IdProceso
    LEFT JOIN
            CO_Instalacion COI  (NOLOCK)
            ON P.IdInstalacion = COI.IdInstalacion
    WHERE
        ED.Activo = 1;
    INSERT INTO #DocumentosVersion
    (
        EntregableInstanciaId,
        NoVersion
    )
    SELECT
        EntregableInstanciaId   =   EntregableInstanciaId,
        NoVersion               =   MAX(NoVersion)
    FROM #Documentos
    GROUP BY
        EntregableInstanciaId;
    /*ELIMINAR LOS DOCUMENTOS DE LA TABLA TEMPORAL QUE NO SON PARTE DE LA ULTIMA VERSIÓN DE LOS DOCUMENTOS*/
    DELETE D
    FROM #Documentos D
    LEFT JOIN #DocumentosVersion DV
        ON  D.EntregableInstanciaId =   DV.EntregableInstanciaId
        AND D.NoVersion             =   DV.NoVersion
    WHERE DV.NoVersion IS NULL;

	-->  ASIGNAR UNA ETAPA DEL CONTRATO A LOS ENTREGABLES 
	UPDATE D
	SET D.IdEtapaContrato=CE.EtapaId
	FROM CO_ContratoEtapas CE	(NOLOCK)
	JOIN EN_Etapa E	(NOLOCK)
	ON      CE.EtapaId      =   E.IdEtapa
	AND		CE.ContratoId        =   @ContratoId
	JOIN #Documentos D        
		ON  D.FechaProgramadaEntrega    BETWEEN CE.FechaInicio AND CE.FechaFin
	WHERE CE.ContratoId        =   @ContratoId
	AND E.IdEtapa=@IdEtapaContrato
	AND CE.Activo              =   1  
	

    IF @Nivel IN (1) AND @IsCarpetaUsuario = 0 --ETAPAS
    BEGIN
        --CONSULTA DE LAS ETAPAS
        INSERT INTO @CONTRACT_FILES(Nivel,IdEtapaContrato,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario)
        SELECT
                 1,
				 CE.EtapaId,
                 E.Etapa,
                 CE.EtapaId,
                 NULL,
                 'Carpeta',
                 NULL,
                 0,
                 'Carpeta de Etapa',
                 'Etapa',
                 0
        FROM CO_ContratoEtapas CE   (NOLOCK)
        JOIN EN_Etapa E (NOLOCK)
        ON      CE.EtapaId      =   E.IdEtapa
        AND     CE.ContratoId        =   @ContratoId
        JOIN #Documentos D        
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

    IF @Nivel IN (2) AND @IsCarpetaUsuario = 0 --REGULADOR Y POZOS
    BEGIN

        --CONSULTA DE LOS REGULADORES  --> #ESTRUCTURA ENTREGABLES
        INSERT INTO @CONTRACT_FILES(
            Nivel,
			IdEtapaContrato,
            Nombre,
            IdCarpeta,
            IdDocumento,
            Tipo,
            CreadoEl,
            CantidadArchivos,
            Funcion,
            FuncionTipo,
            IsCarpetaUsuario,
            Ruta,
            RutaAnterior
        )
        SELECT DISTINCT
            2,
			D.IdEtapaContrato,
            RE.ReceptorEntregable,
            RE.IdReceptorEntregable,
            NULL,
            'Carpeta',
            NULL,
            0,
            'Carpeta de Regulador',
            'Regulador',
            0,
            SC.Ruta,
            SC.RutaAnterior
        FROM #Documentos D    
            JOIN EN_ReceptorEntregable RE  (NOLOCK)
                ON D.IdReceptorEntregable  =   RE.IdReceptorEntregable AND
                    D.EsDeProceso = 0 -->QUE NO SEA DOCUMENTO DE UN PROCESO
            JOIN CO_ContratoEtapas CE   (NOLOCK)
                ON D.FechaProgramadaEntrega BETWEEN CE.FechaInicio AND CE.FechaFin
                AND CE.EtapaId = @IdCarpeta
				AND  CE.EtapaId = @IdEtapaContrato
            LEFT JOIN EN_SecuenciaCarpetas AS SC  (NOLOCK)
                ON SC.IdCarpeta = @IdCarpeta
                    AND SC.Nivel = @Nivel
                    AND SC.IdContrato = @ContratoId
					AND SC.IdEtapaContrato = @IdEtapaContrato
		WHERE D.IdEtapaContrato = @IdEtapaContrato
        GROUP BY
			D.IdEtapaContrato,
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
        INSERT INTO @CONTRACT_FILES(Nivel,IdEtapaContrato,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario, IdCarpetaAnterior, Ruta, RutaAnterior,IsPozo)
        SELECT
            2,
			D.IdEtapaContrato,
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
            SC.RutaAnterior,
            1
        FROM #Documentos D    
            --LEFT JOIN EN_ReceptorEntregable RE 
            --    ON D.IdReceptorEntregable  =   RE.IdReceptorEntregable AND
            --        D.EsDeProceso = 1 -->QUE NO SEA DOCUMENTO DE UN PROCESO
            JOIN CO_ContratoEtapas CE   (NOLOCK)
                ON D.FechaProgramadaEntrega BETWEEN CE.FechaInicio AND CE.FechaFin
                AND CE.EtapaId = @IdCarpeta
				AND CE.EtapaId= @IdEtapaContrato
            LEFT JOIN EN_SecuenciaCarpetas AS SC  (NOLOCK)
                ON SC.IdCarpeta = @IdCarpeta
                    AND SC.Nivel = @Nivel
                    AND SC.IdContrato = @ContratoId
					AND SC.IdEtapaContrato= @IdEtapaContrato
		WHERE D.IdEtapaContrato = @IdEtapaContrato 
        GROUP BY
			D.IdEtapaContrato,
            D.Pozo,
            D.IdInstalacion,
            CE.EtapaId,
            SC.IdCarpetaAnterior,
            SC.Ruta,
            SC.RutaAnterior
        ORDER BY D.Pozo ASC;
        
		--CONSULTA DE LAS CARPETAS POR USUARIO
        INSERT INTO @CONTRACT_FILES(Nivel,IdEtapaContrato,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,Ruta,RutaAnterior,CreadoPor,Limitador)
        SELECT
            2,
			SC.IdEtapaContrato,
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
            ISNULL(CA.Limitador,0)
        FROM EN_CarpetasArchivosVisor AS CA  (NOLOCK)
        LEFT JOIN EN_SecuenciaCarpetas AS SC  (NOLOCK)
                ON CA.IdPadre =SC.IdCarpeta 
                    AND CA.Nivel = SC.Nivel 
                    AND CA.IdContrato = SC.IdContrato 
					AND SC.IdEtapaContrato = @IdEtapaContrato
        LEFT JOIN AP_Usuario AS US (NOLOCK)
            ON CA.CreadoPor = US.UsuarioID
        WHERE CA.IsCarpeta = 1
			AND (CA.IdEtapaContrato = @IdEtapaContrato OR CA.IdEtapaContrato =0)
            AND CA.IdPadre = @IdCarpeta
            AND CA.Nivel = @Nivel
            AND CA.Activo = 1
            AND CA.IdContrato = @ContratoId;


        --CONSULTA DE LOS ARCHIVOS POR USUARIO
        INSERT INTO @CONTRACT_FILES(Nivel,IdEtapaContrato,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,Bucket,Folder,UUID,Meta,Ruta,RutaAnterior,CreadoPor,CredoPorUsuario)
        SELECT
            2,
			CA.IdEtapaContrato,
            CA.Nombre,
            NULL,
            CA.IdElemento,
            CASE
                WHEN CA.Meta = 'application/pdf' THEN 'Archivo PDF'
                WHEN CA.Meta = 'image/jpeg' THEN 'Archivo JPG'
                WHEN CA.Meta = 'image/png' THEN 'Archivo PNG'
                WHEN CA.Meta = 'text/xml' THEN 'Archivo XML'
                WHEN CA.Meta = 'text/plain' THEN 'Archivo TXT'
                WHEN CA.Meta = 'text/html' THEN 'Archivo HTML'
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
            US.Nombre,
            1
        FROM EN_CarpetasArchivosVisor AS CA  (NOLOCK)
        LEFT JOIN EN_SecuenciaCarpetas AS SC (NOLOCK)
                ON CA.IdPadre = SC.IdCarpeta 
                    AND  CA.Nivel = SC.Nivel
                    AND CA.IdContrato = SC.IdContrato 
					AND SC.IdEtapaContrato = @IdEtapaContrato
        LEFT JOIN AP_Usuario AS US (NOLOCK)
            ON CA.CreadoPor = US.UsuarioID
        WHERE IsArchivo = 1
			AND (CA.IdEtapaContrato = @IdEtapaContrato OR CA.IdEtapaContrato =0)
            AND IdPadre = @IdCarpeta
            AND CA.Nivel = @Nivel
            AND CA.Activo = 1
            AND CA.IdContrato = @ContratoId;
    END
    IF @Nivel IN (3) AND @IsCarpetaUsuario = 0 --MARCO LEGAL
    BEGIN
        IF @IsPozo = 1
        BEGIN
            INSERT INTO @CONTRACT_FILES(Nivel,IdEtapaContrato,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,NivelAnterior,IsCarpetaUsuarioAnterior,Ruta,RutaAnterior,IdReceptorEntregable,IsPozo,Etapa)
            SELECT
                3,
				D.IdEtapaContrato,
                EP.Etapa,
                EP.IdEtapa,
                NULL,
                'Carpeta',
                NULL,
                0,
                'Carpeta de Etapa',
                'Etapa',
                0,
                SC.IdCarpetaAnterior,
                SC.NiveAnterior,
                SC.IsCarpetaUsuarioAnterior,
                SC.Ruta,
                SC.RutaAnterior,
                D.IdInstalacion,
                1,
                EP.IdEtapa
            FROM #Documentos D    
                JOIN EN_Etapa EP (NOLOCK)
                    ON D.EtapaPozoId = EP.IdEtapa
                LEFT JOIN EN_SecuenciaCarpetas AS SC (NOLOCK)
                ON SC.IdCarpeta = @IdCarpeta
                    AND SC.Nivel = @Nivel
                    AND SC.IdContrato = @ContratoId
					AND SC.IdEtapaContrato = @IdEtapaContrato
            WHERE D.IdInstalacion = @IdCarpeta
				AND D.IdEtapaContrato= @IdEtapaContrato
                AND D.EsDeProceso = 1
            GROUP BY
                EP.IdEtapa,
                EP.Etapa,
				D.IdEtapaContrato,
                D.EtapaPozoId,
                SC.IdCarpetaAnterior,
                SC.NiveAnterior,
                SC.IsCarpetaUsuarioAnterior,
                SC.Ruta,
                SC.RutaAnterior,
                D.IdInstalacion
            ORDER BY EP.IdEtapa ASC;
        END
        ELSE
        BEGIN
			 -->CONSULTA DE MARCO LEGALES #ESTRUCTURA ENTREGABLES
            INSERT INTO @CONTRACT_FILES(Nivel,IdEtapaContrato,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,NivelAnterior,IsCarpetaUsuarioAnterior,Ruta,RutaAnterior,IdReceptorEntregable,Alias)
            SELECT
                3,
				D.IdEtapaContrato,
                ISNULL(ML.Alias,ML.MarcoLegal),               
                ML.IdMarcoLegal,
                NULL,
                'Carpeta',
                NULL,
                0,
                'Carpeta de Marco Legal',
                'Marco Legal',
                0,
                SC.IdCarpetaAnterior,
                SC.NiveAnterior,
                SC.IsCarpetaUsuarioAnterior,
                SC.Ruta,
                SC.RutaAnterior,
                D.IdReceptorEntregable,
                ML.Alias
            FROM #Documentos D    
                JOIN EN_MarcoLegal ML (NOLOCK)
                    ON  D.IdMarcoLegal =   ML.IdMarcoLegal AND
                        D.IdReceptorEntregable = @IdCarpeta AND
                        D.EsDeProceso = 0 -->QUE NO SEA DOCUMENTO DE UN PROCESO
                LEFT JOIN EN_SecuenciaCarpetas AS SC (NOLOCK)
                    ON SC.IdCarpeta = @IdCarpeta
                        AND SC.Nivel = @Nivel
                        AND SC.IdContrato = @ContratoId
						AND (SC.IdEtapaContrato = @IdEtapaContrato)
			WHERE D.IdEtapaContrato = @IdEtapaContrato
            GROUP BY
				D.IdEtapaContrato,
                ML.MarcoLegal,
                ML.IdMarcoLegal,
                D.EtapaPozoId,
                SC.IdCarpetaAnterior,
                SC.NiveAnterior,
                SC.IsCarpetaUsuarioAnterior,
                SC.Ruta,
                SC.RutaAnterior,
                D.IdReceptorEntregable,
                ML.Alias
            ORDER BY ML.MarcoLegal ASC;
        END

        --CONSULTA DE LAS CARPETAS POR USUARIO
        INSERT INTO @CONTRACT_FILES(Nivel,IdEtapaContrato,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,Ruta,RutaAnterior,CreadoPor,Limitador,IsPozo)
        SELECT
            3,
			CA.IdEtapaContrato,
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
            ISNULL(CA.Limitador,0),
            CA.IsPozo
        FROM EN_CarpetasArchivosVisor AS CA (NOLOCK)
        LEFT JOIN EN_SecuenciaCarpetas AS SC (NOLOCK)
                ON SC.IdCarpeta = @IdCarpeta
                    AND SC.Nivel = @Nivel
                    AND SC.IdContrato = @ContratoId
					AND SC.IdEtapaContrato = @IdEtapaContrato
        LEFT JOIN AP_Usuario AS US (NOLOCK)
            ON CA.CreadoPor = US.UsuarioID
        WHERE CA.IsCarpeta = 1			
            AND CA.IdPadre = @IdCarpeta
            AND CA.Nivel = @Nivel
            AND CA.Activo = 1
            AND CA.IdContrato = @ContratoId
			AND (CA.IdEtapaContrato = @IdEtapaContrato OR CA.IdEtapaContrato =0);

        --CONSULTA DE LOS ARCHIVOS POR USUARIO
        INSERT INTO @CONTRACT_FILES(Nivel,IdEtapaContrato,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,Ruta,RutaAnterior,CreadoPor,Folder,UUID,Meta,CredoPorUsuario,IsPozo)
        SELECT
            3,
			CA.IdEtapaContrato,
            CA.Nombre,
            NULL,
            CA.IdElemento,
            CASE
                WHEN CA.Meta = 'application/pdf' THEN 'Archivo PDF'
                WHEN CA.Meta = 'image/jpeg' THEN 'Archivo JPG'
                WHEN CA.Meta = 'image/png' THEN 'Archivo PNG'
                WHEN CA.Meta = 'text/xml' THEN 'Archivo XML'
                WHEN CA.Meta = 'text/plain' THEN 'Archivo TXT'
                WHEN CA.Meta = 'text/html' THEN 'Archivo HTML'
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
            CA.Meta,
            1,
            CA.IsPozo
        FROM EN_CarpetasArchivosVisor AS CA (NOLOCK)
        LEFT JOIN EN_SecuenciaCarpetas AS SC (NOLOCK)
                ON SC.IdCarpeta = @IdCarpeta
                    AND SC.Nivel = @Nivel
                    AND SC.IdContrato = @ContratoId
					AND SC.IdEtapaContrato = @IdEtapaContrato
        LEFT JOIN AP_Usuario AS US (NOLOCK)
            ON CA.CreadoPor = US.UsuarioID
        WHERE IsArchivo = 1
            AND IdPadre = @IdCarpeta
            AND CA.Nivel = @Nivel
            AND CA.Activo = 1
            AND CA.IdContrato = @ContratoId
			AND (CA.IdEtapaContrato = @IdEtapaContrato OR CA.IdEtapaContrato =0)

        SET @LIMITADOR = @Nivel;
    END

    IF @Nivel IN (4) AND @IsCarpetaUsuario = 0 --FRECUENCIAS
    BEGIN
        IF @IsPozo = 1
        BEGIN
            INSERT INTO @CONTRACT_FILES(Nivel,IdEtapaContrato,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos,Frecuencia, Funcion, FuncionTipo,IsCarpetaUsuario, IdCarpetaAnterior, NivelAnterior,IsCarpetaUsuarioAnterior,Ruta,RutaAnterior,IdReceptorEntregable,IsPozo,Etapa)
            SELECT
                4,
				D.IdEtapaContrato,
                ISNULL(ML.Alias,ML.MarcoLegal),  
                D.IdMarcoLegal,
                NULL,
                'Carpeta',
                NULL,
                0,
                0,
                'Carpeta de Lineamientos',
                'Lineamientos',
                0,
                SC.IdCarpetaAnterior,
                SC.NiveAnterior,
                SC.IsCarpetaUsuarioAnterior,
                SC.Ruta,
                SC.RutaAnterior,
                D.IdInstalacion,
                1,
                D.EtapaPozoId
            FROM #Documentos D    
            JOIN EN_MarcoLegal AS ML (NOLOCK)
                ON D.IdMarcoLegal = ML.IdMarcoLegal
            LEFT JOIN EN_SecuenciaCarpetas AS SC (NOLOCK)
                    ON SC.IdCarpeta = @IdCarpeta
                        AND SC.Nivel = @Nivel
                        AND SC.IdContrato = @ContratoId
                        AND SC.IsPozo = 1
                        AND SC.IdReceptorEntregable = @IdReceptorEntregable
						AND SC.IdEtapaContrato = @IdEtapaContrato
            WHERE D.EtapaPozoId = @IdCarpeta
                AND D.EsDeProceso = 1
                AND D.IdInstalacion = @IdReceptorEntregable
				AND (D.IdEtapaContrato = @IdEtapaContrato OR D.IdEtapaContrato =0)
            GROUP BY
				D.IdEtapaContrato,
                ML.MarcoLegal,
				ML.Alias,
                D.IdMarcoLegal,
                SC.IdCarpetaAnterior,
                SC.NiveAnterior,
                SC.IsCarpetaUsuarioAnterior,
                SC.Ruta,
                SC.RutaAnterior,
                D.IdInstalacion,
                D.EtapaPozoId
            ORDER BY D.IdMarcoLegal ASC;
        END
        ELSE
        BEGIN
			--CONSULTA DE LAS FRECUENCIAS --> #ESTRUCTURA ENTREGABLES
            INSERT INTO @CONTRACT_FILES(Nivel,IdEtapaContrato,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos,Frecuencia, Funcion, FuncionTipo,IsCarpetaUsuario, IdCarpetaAnterior, NivelAnterior,IsCarpetaUsuarioAnterior,Ruta,RutaAnterior,IdReceptorEntregable)
            SELECT
                4,
				D.IdEtapaContrato,
                D.FrecuenciaEntregable,
                D.IdMarcoLegal,
                NULL,
                'Carpeta',
                NULL,
                0,
                D.FrecuenciaEntregableID,
                'Carpeta de Frecuencia',
                'Frecuencia',
                0,
                SC.IdCarpetaAnterior,
                SC.NiveAnterior,
                SC.IsCarpetaUsuarioAnterior,
                SC.Ruta,
                SC.RutaAnterior,
                D.IdReceptorEntregable
            FROM #Documentos D    
            LEFT JOIN EN_SecuenciaCarpetas AS SC (NOLOCK)
                    ON SC.IdCarpeta = @IdCarpeta
                        AND SC.Nivel = @Nivel
                        AND SC.IdContrato = @ContratoId
                        AND SC.IdReceptorEntregable = @IdReceptorEntregable
						AND (SC.IdEtapaContrato = @IdEtapaContrato)
            WHERE D.IdMarcoLegal = @IdCarpeta
                AND D.EsDeProceso = 0
                AND D.IdReceptorEntregable = @IdReceptorEntregable
				AND D.IdEtapaContrato = @IdEtapaContrato
            GROUP BY
                D.FrecuenciaEntregable,
                D.IdMarcoLegal,
                D.FrecuenciaEntregableID,
                SC.IdCarpetaAnterior,
                SC.NiveAnterior,
                SC.IsCarpetaUsuarioAnterior,
                SC.Ruta,
                SC.RutaAnterior,
                D.IdReceptorEntregable,
				D.IdEtapaContrato
            ORDER BY D.FrecuenciaEntregable ASC;
        END;

        --CONSULTA DE LAS CARPETAS POR USUARIO
        INSERT INTO @CONTRACT_FILES(Nivel,IdEtapaContrato,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,Ruta,RutaAnterior,CreadoPor,Limitador,IdReceptorEntregable,IsPozo)
        SELECT
            4,
			CA.IdEtapaContrato,
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
            ISNULL(CA.Limitador,0),
            @IdReceptorEntregable,
            CA.IsPozo
        FROM EN_CarpetasArchivosVisor AS CA (NOLOCK)
        LEFT JOIN EN_SecuenciaCarpetas AS SC (NOLOCK)
                ON SC.IdCarpeta = @IdCarpeta
                    AND SC.Nivel = @Nivel
                    AND SC.IdContrato = @ContratoId
                    AND SC.Etapa = @Etapa
                    AND SC.IdReceptorEntregable = @IdReceptorEntregable
                    AND SC.IsPozo = @IsPozo
					AND SC.IdEtapaContrato = @IdEtapaContrato
        LEFT JOIN AP_Usuario AS US (NOLOCK)
            ON CA.CreadoPor = US.UsuarioID
        WHERE IsCarpeta = 1
			AND (CA.IdEtapaContrato = @IdEtapaContrato OR CA.IdEtapaContrato =0)
            AND IdPadre = @IdCarpeta
            AND CA.Nivel = @Nivel
            AND CA.Activo = 1
            AND CA.IdContrato = @ContratoId
            AND CA.Etapa = @Etapa
            AND CA.IdReceptorEntregable = @IdReceptorEntregable
            AND CA.IsPozo = @IsPozo;

        --CONSULTA DE LOS ARCHIVOS POR USUARIO
        INSERT INTO @CONTRACT_FILES(Nivel,IdEtapaContrato,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,Ruta,RutaAnterior, CreadoPor,Folder,UUID,Meta,CredoPorUsuario,IdReceptorEntregable)
        SELECT
            4,
			CA.IdEtapaContrato,
            CA.Nombre,
            NULL,
            CA.IdElemento,
            CASE
                WHEN CA.Meta = 'application/pdf' THEN 'Archivo PDF'
                WHEN CA.Meta = 'image/jpeg' THEN 'Archivo JPG'
                WHEN CA.Meta = 'image/png' THEN 'Archivo PNG'
                WHEN CA.Meta = 'text/xml' THEN 'Archivo XML'
                WHEN CA.Meta = 'text/plain' THEN 'Archivo TXT'
                WHEN CA.Meta = 'text/html' THEN 'Archivo HTML'
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
            CA.Meta,
            1,
            @IdReceptorEntregable
        FROM EN_CarpetasArchivosVisor AS CA (NOLOCK)
        LEFT JOIN EN_SecuenciaCarpetas AS SC (NOLOCK)
                ON SC.IdCarpeta = @IdCarpeta
                    AND SC.Nivel = @Nivel
                    AND SC.IdContrato = @ContratoId
                    AND SC.Etapa = @Etapa
                    AND SC.IdReceptorEntregable = @IdReceptorEntregable
                    AND SC.IsPozo = @IsPozo
					AND SC.IdEtapaContrato = @IdEtapaContrato
        LEFT JOIN AP_Usuario AS US (NOLOCK)
            ON CA.CreadoPor = US.UsuarioID
        WHERE IsArchivo = 1
			AND (CA.IdEtapaContrato = @IdEtapaContrato OR CA.IdEtapaContrato =0)
            AND IdPadre = @IdCarpeta
            AND CA.Nivel = @Nivel
            AND CA.Activo = 1
            AND CA.IdContrato = @ContratoId
            AND CA.Etapa = @Etapa
            AND CA.IdReceptorEntregable = @IdReceptorEntregable
            AND CA.IsPozo = @IsPozo;
        SET @LIMITADOR = @Nivel;
    END

    IF @Nivel IN (5) AND @IsCarpetaUsuario = 0--AÑO-MES ENTREGA
    BEGIN
        IF @IsPozo = 1
        BEGIN
            INSERT INTO @CONTRACT_FILES(Nivel,IdEtapaContrato,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,NivelAnterior,IsCarpetaUsuarioAnterior,Ruta,RutaAnterior, Frecuencia,IdReceptorEntregable,Etapa,IsPozo)
            SELECT
                5,
				D.IdEtapaContrato,
                E.DocumentoEntregable,
                E.IdEntregable,
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
                0,
                D.IdInstalacion,
                D.EtapaPozoId,
                1
            FROM #Documentos D 
            JOIN EN_Entregable  E (NOLOCK)
                ON  D.IdEntregable  = E.IdEntregable
            LEFT JOIN EN_SecuenciaCarpetas AS SC (NOLOCK)
                    ON SC.IdCarpeta = @IdCarpeta
                        AND SC.Nivel = @Nivel
                        AND SC.IdContrato = @ContratoId
                        AND SC.Frecuencia = @Frecuencia
                        AND SC.Etapa = @Etapa
                        AND SC.IsPozo = 1
                        AND SC.IdReceptorEntregable = @IdReceptorEntregable
						AND SC.IdEtapaContrato = @IdEtapaContrato
            WHERE D.IdMarcoLegal = @IdCarpeta
                AND D.EsDeProceso = 1
                AND D.IdInstalacion = @IdReceptorEntregable
                AND D.EtapaPozoId = @Etapa
				AND D.IdEtapaContrato = @IdEtapaContrato
            GROUP BY
				D.IdEtapaContrato,
                E.DocumentoEntregable,
                SC.IdCarpetaAnterior,
                SC.NiveAnterior,
                SC.IsCarpetaUsuarioAnterior,
                SC.Ruta,
                SC.RutaAnterior,
                D.IdInstalacion,
                D.EtapaPozoId,
                E.IdEntregable
            ORDER BY E.IdEntregable ASC;
        END
        ELSE
        BEGIN
			-- CONSULTA DE AÑO-MES --> #ESTRUCTURA ENTREGABLES
            INSERT INTO @CONTRACT_FILES(
                Nivel,
				IdEtapaContrato,
                Nombre,
                IdCarpeta,
                IdDocumento,
                Tipo,
                CreadoEl,
                CantidadArchivos,
                Funcion,
                FuncionTipo,
                IsCarpetaUsuario,
                Ruta,
                Frecuencia,
                IdReceptorEntregable,
                AnioMes,
                RutaAnterior
            )
            SELECT DISTINCT
                5,
				D.IdEtapaContrato,
                D.FechaProgramadaEntregaAnioMes,
                D.IdMarcoLegal,
                NULL,
                'Carpeta',
                NULL,
                0,
                'Carpeta de Año-Mes Entregable',
                'Año-Mes Entrega',
                0,
                SC.Ruta,
                @Frecuencia,
                D.IdReceptorEntregable,
                D.FechaProgramadaEntregaAnioMes,
                SC.RutaAnterior
            FROM #Documentos D 
            LEFT JOIN EN_SecuenciaCarpetas AS SC (NOLOCK)
                    ON SC.IdCarpeta = @IdCarpeta
                        AND SC.Nivel = @Nivel
                        AND SC.IdContrato = @ContratoId
                        AND SC.Frecuencia = @Frecuencia
                        AND SC.IdReceptorEntregable = @IdReceptorEntregable
						AND (SC.IdEtapaContrato = @IdEtapaContrato)
            WHERE D.IdMarcoLegal = @IdCarpeta
                AND FrecuenciaEntregableID = @Frecuencia
                AND D.EsDeProceso = 0
                AND D.IdReceptorEntregable = @IdReceptorEntregable
				AND D.IdEtapaContrato = @IdEtapaContrato
            GROUP BY
                D.FechaProgramadaEntregaAnioMes,
                SC.IdCarpetaAnterior,
                SC.NiveAnterior,
                SC.IsCarpetaUsuarioAnterior,
                SC.Ruta,
                SC.RutaAnterior,
                SC.Frecuencia,
                D.FrecuenciaEntregableID,
                D.IdReceptorEntregable,
                D.IdMarcoLegal,
				D.IdEtapaContrato
            ORDER BY D.FechaProgramadaEntregaAnioMes ASC;
        END;

        --CONSULTA DE LOS ARCHIVOS POR USUARIO
        INSERT INTO @CONTRACT_FILES(Nivel,IdEtapaContrato,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,Ruta,RutaAnterior, CreadoPor,Frecuencia,Folder,UUID,Meta,CredoPorUsuario,IdReceptorEntregable)
        SELECT
            5,
			CA.IdEtapaContrato,
            CA.Nombre,
            NULL,
            CA.IdElemento,
            CASE
                WHEN CA.Meta = 'application/pdf' THEN 'Archivo PDF'
                WHEN CA.Meta = 'image/jpeg' THEN 'Archivo JPG'
                WHEN CA.Meta = 'image/png' THEN 'Archivo PNG'
                WHEN CA.Meta = 'text/xml' THEN 'Archivo XML'
                WHEN CA.Meta = 'text/plain' THEN 'Archivo TXT'
                WHEN CA.Meta = 'text/html' THEN 'Archivo HTML'
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
            Us.Nombre,
            SC.Frecuencia,
            CA.Folder,
            CA.UUIDAmazon,
            CA.Meta,
            1,
            @IdReceptorEntregable
        FROM EN_CarpetasArchivosVisor AS CA (NOLOCK)
        LEFT JOIN EN_SecuenciaCarpetas AS SC (NOLOCK)
                ON SC.IdCarpeta = @IdCarpeta
                    AND SC.Nivel = @Nivel
                    AND SC.IdContrato = @ContratoId
                    AND SC.IdReceptorEntregable = @IdReceptorEntregable
                    AND SC.Frecuencia = @Frecuencia
                    AND SC.AnioMes = @AnioMes
                    AND SC.Etapa = @Etapa
                    AND SC.IsPozo = @IsPozo
                    AND SC.IdReceptorEntregable = @IdReceptorEntregable
					AND SC.IdEtapaContrato = @IdEtapaContrato
        LEFT JOIN AP_Usuario AS US (NOLOCK)
            ON CA.CreadoPor = US.UsuarioID
        WHERE IsArchivo = 1		
            AND IdPadre = @IdCarpeta
			AND (CA.IdEtapaContrato = @IdEtapaContrato OR CA.IdEtapaContrato =0)
			AND CA.IdContrato = @ContratoId
            AND CA.Nivel = @Nivel
            AND CA.Activo = 1
            AND CA.IdReceptorEntregable = @IdReceptorEntregable
            AND CA.Etapa = @Etapa
			AND CA.Frecuencia = @Frecuencia
            AND CA.IsPozo = @IsPozo;

        SET @LIMITADOR = @Nivel;
    END

    IF @Nivel IN (6) AND @IsCarpetaUsuario = 0 --FRECUENCIAS
    BEGIN
        IF @IsPozo = 1
        BEGIN
            INSERT INTO @CONTRACT_FILES(Nivel,IdEtapaContrato,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos,Funcion,IsCarpetaUsuario,IdCarpetaAnterior,NivelAnterior,IsCarpetaUsuarioAnterior,Ruta,RutaAnterior,Frecuencia,IdReceptorEntregable,IsPozo,Bucket,Folder,UUID,
Meta)
            SELECT
                6,
				D.IdEtapaContrato,
                D.NombreArchivo,
                NULL,
                D.DocumentoEntregableId,
                CASE
                WHEN ED.Meta = 'application/pdf' THEN 'Archivo PDF'
                WHEN ED.Meta = 'image/jpeg' THEN 'Archivo JPG'
                WHEN ED.Meta = 'image/png' THEN 'Archivo PNG'
                WHEN ED.Meta = 'text/xml' THEN 'Archivo XML'
                WHEN ED.Meta = 'text/plain' THEN 'Archivo TXT'
                WHEN ED.Meta = 'text/html' THEN 'Archivo HTML'
                WHEN ED.Meta = 'application/vnd.openxmlformats-officedocument.spre' THEN 'Archivo XLSX'
                WHEN ED.Meta = 'application/zip' THEN 'Archivo ZIP'
                WHEN ED.Meta = 'application/x-zip-compressed' THEN 'Archivo ZIP'
                WHEN ED.Meta = 'application/vnd.openxmlformats-officedocument.word' THEN 'Archivo DOCX'
                WHEN ED.Meta = 'application/msword' THEN 'Archivo DOCX'
                WHEN ED.Meta = 'application/vnd.ms-excel' THEN 'Archivo XLSX'
                WHEN ED.Meta = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' THEN 'Archivo XLSX'
                WHEN ED.Meta = 'application/mspowerpoint' THEN 'Archivo PPT'
                WHEN ED.Meta = 'application/vnd.openxmlformats-officedocument.pres' THEN 'Archivo PPT'
                WHEN ED.Meta = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' THEN 'Archivo DOCX'
                WHEN ED.Meta = 'application/vnd.openxmlformats-officedocument.presentationml.presentation'THEN 'Archivo PPT'
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
                @Frecuencia,
                D.IdReceptorEntregable,
                1,
                ED.Bucket,
                ED.Folder,
                ED.UUIDAmazon,
                ED.Meta
            FROM #Documentos D 
            LEFT JOIN EN_SecuenciaCarpetas AS SC (NOLOCK)
                    ON SC.IdCarpeta = @IdCarpeta
                        AND SC.Nivel = @Nivel
                        AND SC.IdContrato = @ContratoId
                        AND SC.IsPozo = 1
                        AND SC.IdReceptorEntregable = @IdReceptorEntregable
						AND SC.IdEtapaContrato = @IdEtapaContrato
            LEFT JOIN EN_EntregableDocumento AS ED (NOLOCK)
                ON D.DocumentoEntregableId = ED.DocumentoEntregableId
            WHERE D.IdEntregable = @IdCarpeta
                AND D.EsDeProceso = 1
                AND D.EtapaPozoId = @Etapa
                AND D.IdInstalacion = @IdReceptorEntregable
				AND D.IdEtapaContrato = @IdEtapaContrato
            GROUP BY
                D.NombreArchivo,
                D.DocumentoEntregableId,
                D.MIME,
                SC.IdCarpetaAnterior,
                SC.NiveAnterior,
                SC.IsCarpetaUsuarioAnterior,
                SC.Ruta,
                SC.RutaAnterior,
                D.IdReceptorEntregable,
                ED.Bucket,
                ED.Folder,
                ED.UUIDAmazon,
                ED.Meta,
				D.IdEtapaContrato 
            ORDER BY D.NombreArchivo ASC;
        END
        ELSE
        BEGIN
			-- CONSULTA FRECUENCIAS --> #ESTRUCTURA ENTREGABLES
            INSERT INTO @CONTRACT_FILES(
                Nivel,
				IdEtapaContrato,
                Nombre,
                IdCarpeta,
                IdDocumento,
                Tipo,
                CreadoEl,
                CantidadArchivos,
                Funcion,
                FuncionTipo,
                IsCarpetaUsuario,
                Ruta,
                RutaAnterior,
                Frecuencia,
                IdReceptorEntregable,
                AnioMes,
                IdEntregable
            )
            SELECT DISTINCT
                6,
				D.IdEtapaContrato,
                D.Entregable,
                D.IdMarcoLegal,
                NULL,
                'Carpeta',
                NULL,
                0,
                'Carpeta de Entregable',
                'Entregable',
                0,
                SC.Ruta,
                SC.RutaAnterior,
                SC.Frecuencia,
                D.IdReceptorEntregable,
                SC.AnioMes,
                D.IdEntregable
            FROM #Documentos D 
            LEFT JOIN EN_SecuenciaCarpetas AS SC (NOLOCK)
                    ON SC.IdCarpeta = D.IdMarcoLegal
                        AND SC.Nivel = @Nivel
                        AND SC.IdContrato = @ContratoId
                        AND SC.AnioMes = @AnioMes
                        AND SC.Frecuencia = @Frecuencia
                        AND SC.IdReceptorEntregable = @IdReceptorEntregable
						AND SC.IdEtapaContrato = @IdEtapaContrato
            WHERE D.FechaProgramadaEntregaAnioMes = @AnioMes
                AND D.FrecuenciaEntregableID = @Frecuencia
                AND D.IdReceptorEntregable = @IdReceptorEntregable
                AND D.IdMarcoLegal = @IdCarpeta
				AND D.IdEtapaContrato = @IdEtapaContrato
            ORDER BY D.Entregable ASC;

        END

        --CONSULTA DE LOS ARCHIVOS POR USUARIO
        INSERT INTO @CONTRACT_FILES(
            Nivel,
			IdEtapaContrato,
            Nombre,
            IdCarpeta,
            IdDocumento,
            Tipo,
            CreadoEl,
            CantidadArchivos,
            Funcion,
            FuncionTipo,
            IsCarpetaUsuario,
            IdCarpetaAnterior,
            Ruta,
            RutaAnterior,
            CreadoPor,
            Frecuencia,
            Folder,
            UUID,
            Meta,
            CredoPorUsuario,
            AnioMes,
            IdReceptorEntregable
        )
        SELECT
            6,
			CA.IdEtapaContrato,
            CA.Nombre,
            NULL,
            CA.IdElemento,
            CASE
                WHEN CA.Meta = 'application/pdf' THEN 'Archivo PDF'
                WHEN CA.Meta = 'image/jpeg' THEN 'Archivo JPG'
                WHEN CA.Meta = 'image/png' THEN 'Archivo PNG'
                WHEN CA.Meta = 'text/xml' THEN 'Archivo XML'
                WHEN CA.Meta = 'text/plain' THEN 'Archivo TXT'
                WHEN CA.Meta = 'text/html' THEN 'Archivo HTML'
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
            SC.Ruta,
            SC.RutaAnterior,
            US.Nombre,
            SC.Frecuencia,
            CA.Folder,
            CA.UUIDAmazon,
            CA.Meta,
            1,
            SC.AnioMes,
            SC.IdReceptorEntregable
        FROM EN_CarpetasArchivosVisor AS CA (NOLOCK)
        LEFT JOIN EN_SecuenciaCarpetas AS SC (NOLOCK)
                ON SC.IdCarpeta = @IdCarpeta
                    AND SC.Nivel = @Nivel
                    AND SC.IdContrato = @ContratoId
                    AND SC.IdReceptorEntregable = @IdReceptorEntregable
                    AND SC.Frecuencia = @Frecuencia
                    AND SC.AnioMes = @AnioMes
                    AND SC.Etapa = @Etapa
                    AND SC.IsPozo = @IsPozo
                    AND SC.IdReceptorEntregable = @IdReceptorEntregable
					AND SC.IdEtapaContrato = @IdEtapaContrato
        LEFT JOIN AP_Usuario AS US (NOLOCK)
            ON CA.CreadoPor = US.UsuarioID
        WHERE IsArchivo = 1
            AND IdPadre = @IdCarpeta
            AND CA.Nivel = @Nivel
            AND CA.Activo = 1
            AND CA.IdReceptorEntregable = @IdReceptorEntregable
            AND CA.Etapa = @Etapa
            AND CA.IsPozo = @IsPozo
            AND CA.IdContrato = @ContratoId
			AND CA.AnioMes = @AnioMes
			AND (CA.IdEtapaContrato = @IdEtapaContrato OR CA.IdEtapaContrato =0)
        GROUP BY CA.Nombre,
			CA.IdEtapaContrato,
            CA.IdElemento,
            CA.Meta,
            CA.CreadoEl,
            CA.IdPadre,
            SC.Ruta,
            SC.RutaAnterior,
            US.Nombre,
            CA.Folder,
            CA.UUIDAmazon,
            CA.Meta,
            SC.Frecuencia,
            SC.AnioMes,
            SC.IdReceptorEntregable;
            SET @LIMITADOR = @Nivel;
    END

    IF @Nivel IN (7) AND @IsCarpetaUsuario = 0 --ARCHIVO ENTREGABLE
    BEGIN
		-- ARCHIVO ENTREGABLE --> #ESTRUCTURA ENTREGABLES
        INSERT INTO @CONTRACT_FILES(
            Nivel,
			IdEtapaContrato,
            Nombre,
            IdCarpeta,
            IdDocumento,
            Tipo,
            CreadoEl,
            CantidadArchivos,
            Funcion,
            IsCarpetaUsuario,
            Ruta,
            RutaAnterior,
            Frecuencia,
            IdReceptorEntregable,
            AnioMes,
            Bucket,
            Folder,
            UUID,
            Meta,
            IdEntregable
        )
        SELECT
            7,
			D.IdEtapaContrato,
            D.NombreArchivo,
            NULL,
            D.DocumentoEntregableId,
            CASE
                WHEN D.MIME = 'application/pdf' THEN 'Archivo PDF'
                WHEN D.MIME = 'image/jpeg' THEN 'Archivo JPG'
                WHEN D.MIME = 'image/png' THEN 'Archivo PNG'
                WHEN D.MIME = 'text/xml' THEN 'Archivo XML'
                WHEN D.MIME = 'text/plain' THEN 'Archivo TXT'
                WHEN D.MIME = 'text/html' THEN 'Archivo HTML'
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
            SC.Ruta,
            SC.RutaAnterior,
            SC.Frecuencia,
            D.IdReceptorEntregable,
            SC.AnioMes,
            ED.Bucket,
            ED.Folder,
            ED.UUIDAmazon,
            ED.Meta,
            SC.IdEntregable
        FROM #Documentos D 
        LEFT JOIN EN_SecuenciaCarpetas AS SC (NOLOCK)
                ON SC.IdCarpeta = @IdCarpeta
                    AND SC.Nivel = @Nivel
                    AND SC.IdContrato = @ContratoId
                    AND SC.AnioMes = @AnioMes
                    AND SC.Frecuencia = @Frecuencia
                    AND SC.IdEntregable = @IdEntregable
					AND SC.IdEtapaContrato = @IdEtapaContrato
        LEFT JOIN EN_EntregableDocumento AS ED (NOLOCK)
            ON D.DocumentoEntregableId = ED.DocumentoEntregableId
        WHERE D.IdMarcoLegal = @IdCarpeta
            AND D.EsDeProceso = 0
            AND D.FechaProgramadaEntregaAnioMes = @AnioMes
            AND D.IdReceptorEntregable = @IdReceptorEntregable
            AND D.FrecuenciaEntregableID = @Frecuencia
            AND D.IdEntregable = @IdEntregable
			AND D.IdEtapaContrato = @IdEtapaContrato
        GROUP BY
			D.IdEtapaContrato,
            D.NombreArchivo,
            D.DocumentoEntregableId,
            D.MIME,
            SC.IsCarpetaUsuarioAnterior,
            SC.Ruta,
            SC.RutaAnterior,
            D.IdReceptorEntregable,
            SC.Frecuencia,
            SC.AnioMes,
            ED.Bucket,
            ED.Folder,
            ED.UUIDAmazon,
            ED.Meta,
            SC.IdEntregable
        ORDER BY D.NombreArchivo ASC;

        --CONSULTA DE LOS ARCHIVOS POR USUARIO
        INSERT INTO @CONTRACT_FILES(Nivel,IdEtapaContrato,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,Ruta,RutaAnterior,IsCarpetaUsuarioAnterior,NivelAnterior, CreadoPor,Folder,UUID,Meta,CredoPorUsuario,
Frecuencia,IdEntregable)
        SELECT
            CA.Nivel,
			CA.IdEtapaContrato,
            CA.Nombre,
            NULL,
            CA.IdElemento,
            CASE
                WHEN CA.Meta = 'application/pdf' THEN 'Archivo PDF'
                WHEN CA.Meta = 'image/jpeg' THEN 'Archivo JPG'
                WHEN CA.Meta = 'image/png' THEN 'Archivo PNG'
                WHEN CA.Meta = 'text/xml' THEN 'Archivo XML'
                WHEN CA.Meta = 'text/plain' THEN 'Archivo TXT'
                WHEN CA.Meta = 'text/html' THEN 'Archivo HTML'
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
            CA.Meta,
            1,
            SC.Frecuencia,
            CA.IdEntregable
        FROM EN_CarpetasArchivosVisor AS CA (NOLOCK)
        LEFT JOIN EN_SecuenciaCarpetas AS SC (NOLOCK)
                ON SC.IdCarpeta = CA.IdPadre
                    AND SC.Nivel = @Nivel
                    AND SC.IdContrato = @ContratoId
                    AND SC.IdEntregable = @IdEntregable
                    AND SC.Frecuencia = @Frecuencia
                    AND SC.AnioMes = @AnioMes
                    AND SC.IdReceptorEntregable = @IdReceptorEntregable
					AND SC.IdEtapaContrato = @IdEtapaContrato
        LEFT JOIN AP_Usuario AS US (NOLOCK)
            ON CA.CreadoPor = US.UsuarioID
        WHERE CA.IsArchivo = 1
            AND CA.IdPadre = @IdCarpeta
            AND CA.Activo = 1
            AND CA.IdContrato = @ContratoId
            AND CA.IdEntregable = @IdEntregable
            AND CA.Frecuencia = @Frecuencia
            AND CA.AnioMes = @AnioMes
			AND (CA.IdEtapaContrato = @IdEtapaContrato OR CA.IdEtapaContrato =0)
        GROUP BY CA.Nivel,
			CA.IdEtapaContrato,
            CA.Nombre,
            CA.IdElemento,
            CA.Meta,
            CA.CreadoEl,
            SC.IdCarpetaAnterior,
            SC.Ruta,
            SC.RutaAnterior,
            SC.IsCarpetaUsuarioAnterior,
            SC.NiveAnterior,
            US.Nombre,
            CA.Folder,
            CA.UUIDAmazon,
            CA.Meta,
            SC.Frecuencia,
            CA.IdEntregable;
        SET @LIMITADOR = @Nivel;
    END

    IF @IsCarpetaUsuario = 1
    BEGIN
        --BUSCAR LAS CARPETAS DE USUARIO DENTRO DE LAS CARPETAS DE USUARIO
        INSERT INTO @CONTRACT_FILES(Nivel,IdEtapaContrato,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,NivelAnterior,IsCarpetaUsuarioAnterior,Ruta,RutaAnterior, CreadoPor,Frecuencia,IdReceptorEntregable,AnioMes,Limitador,IsPozo)
        SELECT
            CA.Nivel,
			CA.IdEtapaContrato,
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
            (SC.Nivel - 1),
            SC.IsCarpetaUsuarioAnterior,
            SC.Ruta,
            SC.RutaAnterior,
            US.Nombre,
            SC.Frecuencia,
            SC.IdReceptorEntregable,
            SC.AnioMes,
            ISNULL(CA.Limitador,0),
            CA.IsPozo
        FROM EN_CarpetasArchivosVisor AS CA (NOLOCK)
        LEFT JOIN EN_SecuenciaCarpetas AS SC (NOLOCK)
                ON SC.IdCarpeta = @IdCarpeta
                    AND SC.Nivel = @Nivel
                    AND CA.IdContrato = SC.IdContrato 
					AND SC.IdEtapaContrato = @IdEtapaContrato
                    --AND SC.IsCarpetaUsuario = 1
        LEFT JOIN AP_Usuario AS US (NOLOCK)
            ON CA.CreadoPor = US.UsuarioID
        WHERE IsCarpeta = 1
            AND IdPadre = @IdCarpeta
            AND CA.Activo = 1
            AND CA.IdContrato = @ContratoId
			AND (CA.IdEtapaContrato = @IdEtapaContrato OR CA.IdEtapaContrato =0)
        GROUP BY CA.Nivel,
			CA.IdEtapaContrato,
            CA.Nombre,
            CA.IdElemento,
            CA.CreadoEl,
            SC.IdCarpetaAnterior,
            SC.NiveAnterior,
            SC.IsCarpetaUsuarioAnterior,
            SC.Ruta,
            SC.RutaAnterior,
            US.Nombre,
            SC.Frecuencia,
            SC.IdReceptorEntregable,
            SC.AnioMes,
            CA.Limitador,
            SC.Nivel,
            CA.IsPozo;

        --CONSULTA DE LOS ARCHIVOS POR USUARIO
        INSERT INTO @CONTRACT_FILES(Nivel,IdEtapaContrato,Nombre,IdCarpeta,IdDocumento,Tipo,CreadoEl,CantidadArchivos, Funcion, FuncionTipo,IsCarpetaUsuario,IdCarpetaAnterior,Ruta,RutaAnterior,IsCarpetaUsuarioAnterior,NivelAnterior, CreadoPor,Folder,UUID,Meta,CredoPorUsuario,
Frecuencia)
        SELECT
            CA.Nivel,
			CA.IdEtapaContrato,
            CA.Nombre,
            NULL,
            CA.IdElemento,
            CASE
                WHEN CA.Meta = 'application/pdf' THEN 'Archivo PDF'
                WHEN CA.Meta = 'image/jpeg' THEN 'Archivo JPG'
                WHEN CA.Meta = 'image/png' THEN 'Archivo PNG'
                WHEN CA.Meta = 'text/xml' THEN 'Archivo XML'
                WHEN CA.Meta = 'text/plain' THEN 'Archivo TXT'
                WHEN CA.Meta = 'text/html' THEN 'Archivo HTML'
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
            (SC.Nivel - 1),
            US.Nombre,
            CA.Folder,
            CA.UUIDAmazon,
            CA.Meta,
            1,
            SC.Frecuencia
        FROM EN_CarpetasArchivosVisor AS CA (NOLOCK)
        LEFT JOIN EN_SecuenciaCarpetas AS SC (NOLOCK)
                ON CA.IdPadre = SC.IdCarpeta  
                    AND SC.Nivel = @Nivel
                    AND CA.IdContrato = SC.IdContrato  
                    AND SC.IsCarpetaUsuario = 1
                    AND SC.Frecuencia = @Frecuencia
					AND SC.IdEtapaContrato = @IdEtapaContrato
        LEFT JOIN AP_Usuario AS US (NOLOCK)
            ON CA.CreadoPor = US.UsuarioID
        WHERE CA.IsArchivo = 1
            AND CA.IdPadre = @IdCarpeta
            AND CA.IdContrato = @ContratoId
            AND CA.Activo = 1
			AND (CA.IdEtapaContrato = @IdEtapaContrato OR CA.IdEtapaContrato =0)
        GROUP BY CA.Nivel,
			CA.IdEtapaContrato,
            CA.Nombre,
            CA.IdElemento,
            CA.Meta,
            CA.CreadoEl,
            SC.IdCarpetaAnterior,
            SC.Ruta,
            SC.RutaAnterior,
            SC.IsCarpetaUsuarioAnterior,
            SC.NiveAnterior,
            US.Nombre,
            CA.Folder,
            CA.UUIDAmazon,
            CA.Meta,
            SC.Frecuencia,
            SC.Nivel;

        SET @LIMITADOR = (SELECT TOP 1
                                    Limitador
                                FROM EN_CarpetasArchivosVisor 
                                WHERE IdElemento = @IdCarpeta
                                AND IsCarpeta = 1
                                AND IdContrato = @ContratoId);
    END
    IF @Nivel IN (6,7) --NIVELES INFERIORES NO ES NECESARIO EL ANIO MES
    BEGIN
        SET @ANIOMES_INT = @AnioMes;
    END
    ELSE
    BEGIN
        SET @ANIOMES_INT = '';
    END

    SET @CONTARCHIVOS = (SELECT COUNT(IdRow) FROM @CONTRACT_FILES);

    SELECT DISTINCT
        IdRow,
        CF.Nivel,
        --REPLACE(Nombre,'"','') AS NombreLabel,
        CASE 
            WHEN LEN(Nombre) > 20 THEN '<marquee behavior="scroll" direction="left" style="width: 70%;">' + REPLACE(Nombre,'"','') + '</marquee>'
            ELSE REPLACE(Nombre,'"','')
        END AS NombreLabel,
        REPLACE(REPLACE(Nombre,'"',''),'/','-') AS Nombre,
        CF.IdCarpeta,
        IdDocumento,
        Tipo,
        CASE
            WHEN CreadoEl IS NOT NULL THEN 'Creado el ' + CONVERT(varchar,CreadoEl,103)
            ELSE ''
        END AS CreadoEl,
        CantidadArchivos,
        ISNULL((SELECT TOP 1 IdCarpeta FROM EN_SecuenciaCarpetas WHERE Ruta = CF.RutaAnterior AND Activo = 1 AND IdContrato =@ContratoId),0) AS IdCarpetaAnterior,
        ISNULL(CF.Frecuencia,0) AS Frecuencia,
        LEFT(Funcion,50) AS Funcion,
        FuncionTipo,
        CF.IsCarpetaUsuario,
        Bucket,
        Folder,
        UUID,
        Meta,
        Nombre AS NombreArchivo,
        ISNULL((SELECT TOP 1 Nivel FROM EN_SecuenciaCarpetas WHERE Ruta = CF.RutaAnterior AND Activo = 1 AND IdContrato =@ContratoId),(CF.Nivel - 1)) AS NivelAnterior,
        ISNULL((SELECT TOP 1 IsCarpetaUsuario FROM EN_SecuenciaCarpetas WHERE Ruta = CF.RutaAnterior AND Activo = 1 AND IdContrato =@ContratoId),0) AS IsCarpetaUsuarioAnterior,
        CF.RutaAnterior,
        CASE
            WHEN CreadoPor IS NOT NULL THEN ('Por ' + CreadoPor)
            ELSE ''
        END AS CreadoPor,
        @CONTARCHIVOS AS CONTARCHIVOS,
        ISNULL(CredoPorUsuario,0) AS CredoPorUsuario,
        ISNULL(CF.IdReceptorEntregable,0) AS IdReceptorEntregable,
        CAST(ISNULL(IsPozo,0) AS BIT) AS IsPozo,
        ISNULL(Etapa,0) AS Etapa,
        ISNULL(AnioMes,'') AS AnioMes,
        ISNULL((SELECT TOP 1 Etapa FROM EN_SecuenciaCarpetas WHERE Ruta = CF.RutaAnterior AND Activo = 1 AND IdContrato =@ContratoId),0) AS EtapaAnterior,
        CAST(ISNULL((SELECT TOP 1 IsPozo FROM EN_SecuenciaCarpetas WHERE Ruta = CF.RutaAnterior AND Activo = 1 AND IdContrato =@ContratoId),0) AS BIT) AS IsPozoAnterior,
        ISNULL((SELECT TOP 1 IdReceptorEntregable FROM EN_SecuenciaCarpetas WHERE Ruta = CF.RutaAnterior AND Activo = 1 AND IdContrato =@ContratoId),0) AS IdReceptorAnterior,
        ISNULL((SELECT TOP 1 AnioMes FROM EN_SecuenciaCarpetas WHERE Ruta = CF.RutaAnterior AND Activo = 1 AND IdContrato =@ContratoId),'') AS AnioMesAnterior,
        ISNULL(Limitador,0) AS Limitador,
        ISNULL(IdEntregable,0) AS IdEntregable,
        ISNULL(Alias, REPLACE(Nombre,'/','-')) AS Alias,
		ISNULL(CF.IdEtapaContrato,0) AS IdEtapaContrato,
		ISNULL((SELECT TOP 1 IdEtapaContrato FROM EN_SecuenciaCarpetas WHERE Ruta = CF.RutaAnterior AND Activo = 1 AND IdContrato =@ContratoId),'') AS IdEtapaContratoAnterior
    FROM @CONTRACT_FILES AS CF
    WHERE Nombre IS NOT NULL
    ORDER BY IdRow ASC;
    SELECT ISNULL(@LIMITADOR,0) AS LIMITADOR
END