USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_EN_DescargarCarpeta]    Script Date: 22/04/2022 12:24:01 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <13/02/2022>
-- Description:	<Descarga de carpetas etapas, reguladores, marcos legales, frecuencias, años y entregables>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: <25/03/2022>
-- Description:	<Se agrego función para acortar rutas de los archivos de las carpetas del visor>
-- =============================================
ALTER PROCEDURE [dbo].[SP_EN_DescargarCarpeta] --SP_EN_DescargarCarpeta 'Exploración/',10112,1000
	-- Add the parameters for the stored procedure here
	@Ruta VARCHAR(MAX),
	@IdContrato		int,
    @IdUsuario		int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @maxNivel int, @i int, @query varchar(max), @maxIds int,@size int=20
    -- Insert statements for procedure here
	create table #Rutas
	(
		Id						int,
		IdPadre					int,
		Titulo					varchar(max),
		EtapaId					varchar(max),
		ReceptorEntregableId	int,
		PozoInstalacionId		int,
		MarcoLegalId			int,
		EtapaPozoId				int,
		EntregableId			int,
		FrecuenciaId			varchar(max),
		Frecuencia				varchar(max),
		FechaEntregaAnioMes		varchar(max),
		FechaProgramadaEntrega	date,
		DocumentoEntregableId	int,
		CantidadArchivos		int,
		Detalle					varchar(max),
		Icono					varchar(max),
		Acciones				varchar(max),
		Mime					varchar(max),
		Nivel					int,
		TipoArchivo				varchar(max),
		FechaCarga				date,
		CargadoPor				varchar(max),
		Origen					varchar(max),
		FechaInicioEtapa		date,
		FechaFinEtapa			date
	)
	
	create table #tmpResultado
	(
		Id						int, 
		IdPadre					int, 
		Nivel					int, 
		Ruta					varchar(max),
		Titulo					varchar(max),
		DocumentoEntregableId	int,
		RutaCompleta			nvarchar(max)
	)

	create table #tmpResultadoRuta
	(
		Id						int,
		Ruta					varchar(max),
		Titulo					varchar(max)		
	)

	create table #tmpResultadoVisor
	(
		Id						int, 
		Ruta					varchar(max),
		RutaCompleta			nvarchar(max),
		Titulo					varchar(max)
	)


	
	insert into #Rutas
	exec EN_SHELL_ObtenerDocumentosEntregables @IdContrato, @IdUsuario
	
	insert 
	into	#tmpResultado
	select	Id, IdPadre, Nivel, Titulo, Titulo, DocumentoEntregableId,Titulo
	from	#Rutas 

	select @maxNivel = max(Nivel), @i = 0 from #Rutas

	while(@i < @maxNivel)
	begin
		
		update		#tmpResultado	
		set			#tmpResultado.Ruta		=	substring(RTRIM(LTRIM(r.Titulo)),0,@size)+'/'+tr.Ruta,
					#tmpResultado.RutaCompleta		=	RTRIM(LTRIM(r.Titulo))+'/'+tr.Ruta,
					#tmpResultado.IdPadre	=	r.IdPadre
		from		#tmpResultado	tr
		inner join	#Rutas			r
		on			tr.IdPadre		=	r.Id
			
		select @i = @i  + 1
	end

	select @maxIds = MAX(Id) 
	from #tmpResultado


	insert into #tmpResultadoVisor(Id,Ruta,RutaCompleta,Titulo)
	SELECT
		(IdElemento + @maxIds) AS Id,
		[dbo].[fn_ent_RutaArchivo](Ruta,@size),
		Ruta,
		Nombre
	FROM EN_CarpetasArchivosVisor
	WHERE IdContrato = @IdContrato
	AND Ruta IS NOT NULL
	AND Activo = 1;

	--TODAS LAS RUTAS
	select	Id,
			Ruta,
			Titulo
	from	#tmpResultado 
	where	DocumentoEntregableId is not null
	UNION ALL
	select Id, 
	Ruta,
	Titulo
	from #tmpResultadoVisor
	
	--RUTAS DE LA CARPETA QUE SE DESEA DESCARGAR
	select	R.Id,
			R.Ruta,
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
	from	#tmpResultado AS R
	JOIN EN_EntregableDocumento AS DE ON R.DocumentoEntregableId = DE.DocumentoEntregableId
	where	R.DocumentoEntregableId is not null
		AND R.RutaCompleta LIKE '%' + @Ruta + '%'
		AND Activo = 1
	UNION ALL
	SELECT
		(V.IdElemento + @maxIds) AS Id,
		RV.Ruta,
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
	FROM EN_CarpetasArchivosVisor V
	JOIN #tmpResultadoVisor RV
		ON(V.IdElemento + @maxIds) = RV.Id
	WHERE V.IdContrato = @IdContrato	
	AND RV.RutaCompleta LIKE '%' + @Ruta + '%'
	AND V.Activo = 1


END
