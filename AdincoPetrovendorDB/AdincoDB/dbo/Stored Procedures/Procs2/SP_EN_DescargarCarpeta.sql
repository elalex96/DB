USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_EN_DescargarCarpeta'
)
    DROP PROCEDURE SP_EN_DescargarCarpeta; 
GO
/****** Object:  StoredProcedure [dbo].[SP_EN_DescargarCarpeta]    Script Date: 10/05/2024 12:13:01 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Alexander Gomez>
-- Create date: <13/02/2022>
-- Description: <Descarga de carpetas etapas, reguladores, marcos legales, frecuencias, años y entregables>
-- =============================================
-- =============================================
-- Author:      Daniel AC
-- Create date: <10/11/2022>
-- Description: <Se cambio de sp para no contemplar carpetas de la versión anterior>
-- =============================================
-- =============================================
-- Author:      Alexander Gomez
-- Create date: <28/06/2022>
-- Description: <se reemplaza el marco legal por el alias en las carpetas de descarga>
-- =============================================
-- 20221124	BAAC	Se agrega join a marco legal para sustituir alias y join a entregable para aumentar la descripcion a 30 caracteres
-- =============================================
-- Author:      Luis David
-- Create date: <09/12/2022>
-- Description: Se hace la conjuncion de nombres para archivo descarga issue # Entregables 857
-- =============================================
-- Author:      Daniel AC
-- Create date: <10/05/2024>
-- Description: Se agrega replace en la busqueda de la información Issue #1343 Entregables 
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_DescargarCarpeta] --[SP_EN_DescargarCarpeta] 'Exploración/SENER (Secretaría de Energía)/(Resolutivo EvIS) Oficio 117.-DGAEISyCP.4237-18 referente a la Evaluación de Impacto Social/',10103,1000

    -- Add the parameters for the stored procedure here
    @Ruta VARCHAR(MAX),
    @IdContrato     int,
    @IdUsuario      int
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    CREATE TABLE #tabla (
	dato varchar(max),
	esEntregable BIT)

    DECLARE @maxNivel int,
	@i int, 
	@query varchar(max),
	@maxIds int,
	@size int=20, 
	@NuevaRuta VARCHAR(MAX) = '', 
	@TableConjunciones TableConjunciones;
	
    CREATE TABLE #Rutas
    (
        Id                      int,
        IdPadre                 int,
        Titulo                  varchar(max),
        EtapaId                 varchar(max),
        ReceptorEntregableId    int,
        PozoInstalacionId       int,
        MarcoLegalId            int,
        EtapaPozoId             int,
        EntregableId            int,
        FrecuenciaId            varchar(max),
        Frecuencia              varchar(max),
        FechaEntregaAnioMes     varchar(max),
        FechaProgramadaEntrega  date,
        DocumentoEntregableId   int,
        CantidadArchivos        int,
        Detalle                 varchar(max),
        Icono                   varchar(max),
        Acciones                varchar(max),
        Mime                    varchar(max),
        Nivel                   int,
        TipoArchivo             varchar(max),
        FechaCarga              date,
        CargadoPor              varchar(max),
        Origen                  varchar(max),
        FechaInicioEtapa        date,
        FechaFinEtapa           date
    )
    CREATE TABLE #tmpResultado
    (
        Id                      int,
        IdPadre                 int,
        Nivel                   int,
        Ruta                    varchar(max),
        Titulo                  varchar(max),
        DocumentoEntregableId   int,
        RutaCompleta            nvarchar(max)
    )
    CREATE TABLE #tmpResultadoRuta
    (
        Id                      int,
        Ruta                    varchar(max),
        Titulo                  varchar(max)
    )
    CREATE TABLE #tmpResultadoVisor
    (
        Id                      int,
        Ruta                    varchar(max),
        RutaCompleta            nvarchar(max),
        Titulo                  varchar(max),
		RutaCarpetas			varchar(max),
    )

	INSERT INTO @TableConjunciones (
	palabra,
	sustitucion)
	SELECT palabra,
	sustitucion 
	FROM EN_ConjuncionesDocumentos 
	WHERE activo = 1
    
	INSERT INTO #tabla(dato)
    SELECT 
	splitdata as Ruta
    FROM [dbo].[fnSplitString](@Ruta,'/')

	--SE AGREGA JOIN A MARCOS LEGALES PARA SUSTITUIR POR EL ALIAS
	UPDATE t
	SET dato = isnull(ML.alias,ML.MarcoLegal)
	FROM #tabla T
	JOIN EN_MARCOLEGAL ML (NOLOCK)
		ON T.dato = ML.MarcoLegal
	
	UPDATE T
	SET esEntregable = 1
	FROM #tabla T
	JOIN EN_ENTREGABLE E (NOLOCK)
		ON T.dato = E.DocumentoEntregable

    SELECT 
		@NuevaRuta = @NuevaRuta + CASE
									WHEN CHARINDEX('- (',dato,1) > 0 THEN substring(LTRIM(RTRIM(SUBSTRING((SUBSTRING(dato,CHARINDEX('- (',dato,1)+3,30)),1,(len(SUBSTRING(dato,CHARINDEX('- (',dato,2)+3,30)) - 1)))),0,20) + '/'
									WHEN esEntregable = 1 THEN substring(LTRIM(RTRIM(dato)),0,30) + '/'
									ELSE substring(LTRIM(RTRIM(dato)),0,20) + '/'
								END
    FROM #tabla;

	SET @NuevaRuta = REPLACE(REPLACE(@NuevaRuta,':',''),' ','');
	  
	INSERT INTO #Rutas(
	Id                      ,
    IdPadre                 ,
    Titulo                  ,
    EtapaId                 ,
    ReceptorEntregableId    ,
    PozoInstalacionId       ,
    MarcoLegalId            ,
    EtapaPozoId             ,
    EntregableId            ,
    FrecuenciaId            ,
    Frecuencia              ,
    FechaEntregaAnioMes     ,
    FechaProgramadaEntrega  ,
    DocumentoEntregableId   ,
    CantidadArchivos        ,
    Detalle                 ,
    Icono                   ,
    Acciones                ,
    Mime                    ,
    Nivel                   ,
    TipoArchivo             ,
    FechaCarga              ,
    CargadoPor              ,
    Origen                  ,
    FechaInicioEtapa        ,
    FechaFinEtapa           
	)
    EXEC EN_SHELL_ObtenerDocumentosEntregablesDescarga 
	@IdContrato, 
	@IdUsuario
    
	INSERT INTO    #tmpResultado(
	Id                   ,
    IdPadre              ,
    Nivel                ,
    Ruta                 ,
    Titulo               ,
    DocumentoEntregableId,
    RutaCompleta)
    SELECT  Id,
	IdPadre,
	Nivel,
	Titulo, 
	Titulo,
	DocumentoEntregableId,
	Titulo
    FROM    #Rutas 


    SELECT @maxNivel = max(Nivel),
	@i = 0 
	from #Rutas

    WHILE(@i < @maxNivel)
    BEGIN
        UPDATE      #tmpResultado   
        SET         #tmpResultado.Ruta      =    CASE WHEN E.IdEntregable IS NOT NULL THEN CONCAT(substring(RTRIM(LTRIM(r.Titulo)),0,@size+10),'/',tr.Ruta)
													ELSE CONCAT(substring(RTRIM(LTRIM(r.Titulo)),0,@size),'/',tr.Ruta) END ,
                    #tmpResultado.RutaCompleta      =  CONCAT(RTRIM(LTRIM(r.Titulo)),'/',tr.Ruta),
                    #tmpResultado.IdPadre   =   r.IdPadre
        FROM        #tmpResultado   tr
        INNER JOIN  #Rutas          r
        ON          tr.IdPadre      =   r.Id
		LEFT JOIN EN_Entregable E (NOLOCK)
			ON r.Titulo = E.DocumentoEntregable
        SELECT @i = @i  + 1

    END

    SELECT @maxIds = MAX(Id)
    FROM #tmpResultado

    INSERT INTO #tmpResultadoVisor
	(Id,
	Ruta,
	RutaCompleta,
	Titulo,
	RutaCarpetas)
    SELECT
        (IdElemento + @maxIds) AS Id,
        [dbo].[fn_ent_RutaArchivo_CF](Ruta,@size),
        Ruta,
        Nombre,
		REPLACE(REPLACE(REVERSE(STUFF(REVERSE([dbo].[fn_ent_RutaArchivo_CF](Ruta,@size)), 1, LEN(Nombre), '')),'//','/'),'///','/')
    FROM EN_CarpetasArchivosVisor (NOLOCK)
    WHERE IdContrato = @IdContrato
    AND Ruta IS NOT NULL
    AND Activo = 1;

    --TODAS LAS RUTAS
    SELECT  Id,
            REPLACE(Ruta,':','') AS Ruta,
            Titulo
    FROM    #tmpResultado 
    WHERE   DocumentoEntregableId IS NOT NULL

    UNION ALL

    SELECT Id,
    REPLACE(Ruta,':',''),
    Titulo
    FROM #tmpResultadoVisor


    --RUTAS DE LA CARPETA QUE SE DESEA DESCARGAR
    select  R.Id,
            REPLACE(Ruta,':','') AS Ruta,
            R.Titulo,
            DE.DocumentoEntregableId,
            idContratoEntregable,
            idInstanciaEntregable,
            Bucket,
            Folder,
            UUIDAmazon,
            NombreArchivo,
            Meta,
            CreadoPor,
            CreadoEl,
            ModificadoPor,
            ModificadoEl
			from    #tmpResultado AS R
    JOIN EN_EntregableDocumento AS DE (NOLOCK)
        ON R.DocumentoEntregableId = DE.DocumentoEntregableId
    WHERE   R.DocumentoEntregableId IS NOT NULL
        AND REPLACE(REPLACE(R.RutaCompleta,':',''),' ','') LIKE '%' + @NuevaRuta + '%'
        AND Activo = 1

    UNION ALL

    SELECT
        (V.IdElemento + @maxIds) AS Id,
		CONCAT(RV.RutaCarpetas,dbo.fn_EN_getNombreDocumentoConjuncion(@TableConjunciones,CONCAT(' ',V.Nombre,' '))) as Ruta,
        V.Nombre AS Titulo,
        V.IdElemento as DocumentoEntregableId,
        0 AS idContratoEntregable,
        0 AS idInstanciaEntregable,
        V.Bucket,
        V.Folder,
        V.UUIDAmazon,
        V.Nombre AS NombreArchivo,
        V.Meta,
        V.CreadoPor,
        V.CreadoEl,
        NULL AS ModificadoPor,
        NULL AS ModificadoEl
    FROM EN_CarpetasArchivosVisor V (NOLOCK)
    JOIN #tmpResultadoVisor RV
        ON(V.IdElemento + @maxIds) = RV.Id
    WHERE V.IdContrato = @IdContrato
    AND REPLACE(REPLACE(REPLACE(RV.Ruta,'//','/'),'///','/'),' ','') LIKE '%' + @NuevaRuta + '%'
    AND V.Activo = 1;

END