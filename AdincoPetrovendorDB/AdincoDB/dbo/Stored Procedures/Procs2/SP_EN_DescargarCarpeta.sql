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
    CREATE TABLE #tabla (dato varchar(500))
    DECLARE @maxNivel int, @i int, @query varchar(max), @maxIds int,@size int=20, @NuevaRuta VARCHAR(MAX) = ''
    
	INSERT INTO #tabla(dato)
    SELECT 
	splitdata as Ruta
    FROM [dbo].[fnSplitString](@Ruta,'/')

	--SE AGREGA JOIN A MARCOS LEGALES PARA SUSTITUIR POR EL ALIAS
	UPDATE t
	set dato = isnull(ML.alias,ML.MarcoLegal)
	FROM #tabla T
	JOIN EN_MARCOLEGAL ML
		ON T.dato = ML.MarcoLegal

    SELECT 
		@NuevaRuta = @NuevaRuta + CASE
									WHEN CHARINDEX('- (',dato,1) > 0 THEN substring(LTRIM(RTRIM(SUBSTRING((SUBSTRING(dato,CHARINDEX('- (',dato,1)+3,30)),1,(len(SUBSTRING(dato,CHARINDEX('- (',dato,2)+3,30)) - 1)))),0,20) + '/'
									ELSE substring(LTRIM(RTRIM(dato)),0,20) + '/'
								END
    FROM #tabla;

	SET @NuevaRuta = REPLACE(@NuevaRuta,':','');

    -- Insert statements for procedure here
    create table #Rutas
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
    create table #tmpResultado
    (
        Id                      int,
        IdPadre                 int,
        Nivel                   int,
        Ruta                    varchar(max),
        Titulo                  varchar(max),
        DocumentoEntregableId   int,
        RutaCompleta            nvarchar(max)
    )
    create table #tmpResultadoRuta
    (
        Id                      int,
        Ruta                    varchar(max),
        Titulo                  varchar(max)
    )
    create table #tmpResultadoVisor
    (
        Id                      int,
        Ruta                    varchar(max),
        RutaCompleta            nvarchar(max),
        Titulo                  varchar(max)
    )
    insert into #Rutas
    exec EN_SHELL_ObtenerDocumentosEntregablesDescarga @IdContrato, @IdUsuario
    insert
    into    #tmpResultado
    select  Id, IdPadre, Nivel, Titulo, Titulo, DocumentoEntregableId,Titulo
    from    #Rutas 
    select @maxNivel = max(Nivel), @i = 0 from #Rutas
    while(@i < @maxNivel)
    begin
        update      #tmpResultado   
        set         #tmpResultado.Ruta      =   CONCAT(substring(RTRIM(LTRIM(r.Titulo)),0,@size),'/',tr.Ruta),
                    #tmpResultado.RutaCompleta      =  CONCAT(RTRIM(LTRIM(r.Titulo)),'/',tr.Ruta),
                    #tmpResultado.IdPadre   =   r.IdPadre
        from        #tmpResultado   tr
        inner join  #Rutas          r
        on          tr.IdPadre      =   r.Id
        select @i = @i  + 1
    end
    select @maxIds = MAX(Id)
    from #tmpResultado
    insert into #tmpResultadoVisor(Id,Ruta,RutaCompleta,Titulo)
    SELECT
        (IdElemento + @maxIds) AS Id,
        [dbo].[fn_ent_RutaArchivo_CF](Ruta,@size),
        Ruta,
        Nombre
    FROM EN_CarpetasArchivosVisor (NOLOCK)
    WHERE IdContrato = @IdContrato
    AND Ruta IS NOT NULL
    AND Activo = 1;

    --TODAS LAS RUTAS
    select  Id,
            REPLACE(Ruta,':','') AS Ruta,
            Titulo
    from    #tmpResultado 
    where   DocumentoEntregableId is not null
    UNION ALL
    select Id,
    REPLACE(Ruta,':',''),
    Titulo
    from #tmpResultadoVisor
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
    where   R.DocumentoEntregableId is not null
        AND REPLACE(R.RutaCompleta,':','') LIKE '%' + @NuevaRuta + '%'
        AND Activo = 1
    UNION ALL
    SELECT
        (V.IdElemento + @maxIds) AS Id,
        REPLACE(REPLACE(RV.Ruta,'//','/'),'///','/') AS Ruta,
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
    AND REPLACE(REPLACE(RV.Ruta,'//','/'),'///','/') LIKE '%' + @NuevaRuta + '%'
    AND V.Activo = 1;

END
