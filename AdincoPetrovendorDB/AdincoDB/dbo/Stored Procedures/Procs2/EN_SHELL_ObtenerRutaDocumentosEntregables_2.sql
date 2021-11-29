CREATE PROCEDURE [dbo].[EN_SHELL_ObtenerRutaDocumentosEntregables]
(
	@IdContrato		int,
    @IdUsuario		int
)
as
begin

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

	select	Id				=	DocumentoEntregableId,
			Ruta,
			Titulo 
	from	#tmpResultado 
	where	DocumentoEntregableId is not null
end
