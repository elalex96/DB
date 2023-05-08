
create proc [dbo].[sp_Aprobaciones_Ins]
(
	@table		varchar(50),
	@IdGenerico	int,-- es el IdPrevio
	@IdContrato	int,
	@IdMenu		int,
	@Url		varchar(max)
)
as
begin
	begin tran
	set nocount on

	select		@Url			=		REPLACE(@Url,'.aspx/SendToApprobation','Edit.aspx?id='+cast(@IdGenerico as varchar))+'&PorAprobar=true'
	declare		@IdFlujo		int,
				@IdFlujoDetalle	int,
				@IdAprobacion	int,
				@IdRol			int

	--Obtengo el Flujo correspondiente a la opcion de Menu
	select		@IdFlujo		=	IdFlujo 
	from		FlujosMenu 
	where		IdMenu			=	@IdMenu 
	and			Activo			=	1
	--Obtengo el IdAprobacion Maxima de la tabla
	select @IdAprobacion		=	isnull(Max(IdAprobacion),0) 
	from	Aprobaciones
	--Creo una temporal con la información que se requerira insertar en la tabla de Aprobaciones
	select	IdAprobacion		=	ROW_NUMBER() OVER (Order by IdFlujo)	+	@IdAprobacion,
			IdFlujoDetalle,
			Aprobado			=	0,
			Activo				=	1,
			IdGenerico			=	@IdGenerico,
			Tabla				=	rtrim(ltrim(@table))
	into	#tmp
	from	CAT_FlujosDetalle 
	where	IdFlujo				=	@IdFlujo 
	and		Activo				=	1
	--select * from #tmp
	--Reviso si la tabla de Aprobaciones ya tiene la información de la temporal
	if((
		select		count(*)
		from		#tmp					t1
		inner join	Aprobaciones			a
		on			t1.IdFlujoDetalle		=	a.IdFlujoDetalle
		and			t1.IdGenerico			=	a.IdGenerico
		and			rtrim(ltrim(t1.tabla))	=	rtrim(ltrim(a.tabla))
	)=0)
	begin
		--Si no la tiene, le inserto la infomacion
		insert into Aprobaciones
		select	IdAprobacion, 
				IdFlujoDetalle,
				Aprobado,
				Activo,
				IdGenerico,
				Tabla,
				null
		from	#tmp

		--Obtengo el IdFlujoDetalle y el IdAprobacion siguiente (que no ha sido aprobado) para enviarlos a la tabla de AprobacionesDetalle
		select		top 1 
					@IdFlujoDetalle		=	IdFlujoDetalle, 
					@IdAprobacion		=	IdAprobacion 
		from		Aprobaciones 
		where		Aprobado			=	0 
		and			Activo				=	1 
		and			IdGenerico			=	@IdGenerico 
		and			Tabla				=	@table 
	
		--select		top 1 
		--			* 
		--from		Aprobaciones 
		--where		Aprobado			=	0 
		--and			Activo				=	1 
		--and			IdGenerico			=	@IdGenerico 
		--and			Tabla				=	@table

		--Obtengo el IdRol que debera autorizar la AprobacionDetalle
		select		@IdRol				=	r.IdRol
		from		Roles				r
		inner join	RolesFlujosDetalle	rfd
		on			r.IdRol				=	rfd.IdRol
		inner join	CAT_FlujosDetalle	fd
		on			fd.IdFlujoDetalle	=	rfd.IdFlujoDetalle
		inner join	CAT_Flujos			f
		on			f.IdFlujo			=	fd.IdFlujo
		inner join	FlujosContratos		fc
		on			fc.IdFlujo			=	f.IdFlujo
		where		fc.IdContrato		=	@IdContrato 
		and			r.Activo			=	1
		and			rfd.IdFlujoDetalle	=	@IdFlujoDetalle

		order by	fd.Orden
		--Inserto en la tabla de AprobacionesDetalle la IdAprobacion y el IdRol
		exec sp_AprobacionesDetalle_Ins @IdAprobacion, @IdRol, @Url
	end

	commit
end

