USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_EN_DescargarCarpeta]    Script Date: 17/01/2022 02:43:15 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <13/02/2022>
-- Description:	<Descarga de carpetas etapas, reguladores, marcos legales, frecuencias, años y entregables>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_DescargarCarpeta] --SP_EN_DescargarCarpeta 'Exploración/Carpeta Descarga/',3,1000
	-- Add the parameters for the stored procedure here
	@Ruta VARCHAR(MAX),
	@IdContrato		int,
    @IdUsuario		int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

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
		DocumentoEntregableId	int
	)

	create table #tmpResultadoRuta
	(
		Id						int,
		Ruta					varchar(max),
		Titulo					varchar(max)
	)

	declare @maxNivel int, @i int, @query varchar(max)
	
	insert into #Rutas
	exec EN_SHELL_ObtenerDocumentosEntregables @IdContrato, @IdUsuario
	
	insert 
	into	#tmpResultado
	select	Id, IdPadre, Nivel, Titulo, Titulo, DocumentoEntregableId
	from	#Rutas 

	select @maxNivel = max(Nivel), @i = 0 from #Rutas

	while(@i < @maxNivel)
	begin
		
		update		#tmpResultado	
		set			#tmpResultado.Ruta		=	substring( r.Titulo,0,50)+'/'+tr.Ruta,
					#tmpResultado.IdPadre	=	r.IdPadre
		from		#tmpResultado	tr
		inner join	#Rutas			r
		on			tr.IdPadre		=	r.Id
			
		select @i = @i  + 1
	end



	--TODAS LAS RUTAS
	select	Id,
			Ruta,
			Titulo
	from	#tmpResultado 
	where	DocumentoEntregableId is not null
	UNION ALL
	SELECT
		(IdElemento + 2000) AS Id,
		Ruta,
		Nombre
	FROM EN_CarpetasArchivosVisor
	WHERE IdContrato = @IdContrato
	AND Ruta IS NOT NULL;

	--SELECT * FROM #tmpResultado

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
		AND R.Ruta LIKE '%' + @Ruta + '%'
	UNION ALL
	SELECT
		(IdElemento + 2000) AS Id,
		Ruta,
		Nombre AS Titulo,
		IdElemento as DocumentoEntregableId,
		0 AS idContratoEntregable,
		0 AS idInstanciaEntregable,
		Bucket,
		Folder,
		UUIDAmazon,
		Nombre AS NombreArchivo,
		Meta,
		CreadoPor,
		CreadoEl,
		NULL AS ModificadoPor,
		NULL AS ModificadoEl
	FROM EN_CarpetasArchivosVisor
	WHERE IdContrato = @IdContrato
	AND Ruta IS NOT NULL
	AND Ruta LIKE '%' + @Ruta + '%';


END
