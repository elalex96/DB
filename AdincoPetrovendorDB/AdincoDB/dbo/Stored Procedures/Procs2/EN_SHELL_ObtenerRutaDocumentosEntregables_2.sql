use Adinco

go

if exists (select * from sys.procedures where name = 'EN_SHELL_ObtenerRutaDocumentosEntregables')
begin
	drop proc EN_SHELL_ObtenerRutaDocumentosEntregables
end

go

create proc EN_SHELL_ObtenerRutaDocumentosEntregables
(
	@IdContrato		int,
    @IdUsuario		int
)
as
begin

	Create table #Rutas
	(
		Id						int,
		IdPadre					int,
		Titulo					varchar(max),
		EtapaId					varchar(max),
		ReceptorEntregableId	int,
		PozoInstalacionId		int,
		MarcoLegalId			int,
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
	
	insert into #Rutas
	exec EN_SHELL_ObtenerDocumentosEntregables @IdContrato, @IdUsuario
	
	create table #tmpResultado
	(
		Id						int, 
		IdPadre					int, 
		Nivel					int, 
		Ruta					varchar(max),
		Titulo					varchar(max),
		DocumentoEntregableId	int
	)

	insert 
	into	#tmpResultado
	select	Id, IdPadre, Nivel, Titulo, Titulo, DocumentoEntregableId
	from	#Rutas 
	--where	DocumentoEntregableId in (11584,11586)
	

	declare @maxNivel int, @i int, @query varchar(max)
	select @maxNivel = max(Nivel), @i = 0 from #Rutas

	while(@i < @maxNivel)
	begin
		
		update		#tmpResultado	
		set			#tmpResultado.Ruta		=	substring( r.Titulo,0,20)+'/'+tr.Ruta,
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

go
-- EN_SHELL_ObtenerDocumentosEntregables 3,10109
--exec EN_SHELL_ObtenerRutaDocumentosEntregables 3,10109