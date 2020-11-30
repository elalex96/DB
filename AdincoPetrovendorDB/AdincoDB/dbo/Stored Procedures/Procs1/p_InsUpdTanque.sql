

CREATE  proc p_InsUpdTanque
@pId	int out,
@pClave	varchar(20),
@pNombre	varchar(200),
@pDescripcion	nvarchar(4000),
@pEstatus	tinyint,
@pEstacion	int,
@pCapacidad	decimal(24,8),
@pProducto	int,
@pDiametro	decimal(24,8),
@pAltura	decimal(24,8),
@pConstante	decimal(24,8),
@pPctNoBombeable	decimal(8,4),
@pVolNoBombeable	decimal(24,8),
@pPctMaximo	decimal(8,4),
@pVolMaximo	decimal(24,8),
@pPorcentajeAgua	float,
@pProductoAlmacenado	varchar(250),
@pIdTipoTanque	int,
@pMedicionManual	bit,
@pPuntoEntregaID int

as

	

	set @pEstacion = case when @pEstacion = 0 then  null else @pEstacion end

	if not exists (
		select 1
		from PR_Tanque
		where Id = @pId
	)
	begin

		insert into PR_Tanque(
							Clave,					Nombre,		Descripcion,
			Estatus,		Estacion,				Capacidad,	Producto,
			Diametro,		Altura,					Constante,	PctNoBombeable,
			VolNoBombeable,	PctMaximo,				VolMaximo,	PorcentajeAgua,
			/*[timestamp],*/		ProductoAlmacenado,		IdTipoTanque,	MedicionManual,
			PuntoEntregaID
		)
		select
							@pClave,					@pNombre,		@pDescripcion,
			@pEstatus,		@pEstacion,				@pCapacidad,	@pProducto,
			@pDiametro,		@pAltura,					@pConstante,	@pPctNoBombeable,
			@pVolNoBombeable,	@pPctMaximo,				@pVolMaximo,	@pPorcentajeAgua,
			/*@ptimestamp,*/		@pProductoAlmacenado,		@pIdTipoTanque,	@pMedicionManual,
			@pPuntoEntregaID

	End
	Else
	Begin
		
		update PR_Tanque
		set Clave = @pClave,
			Nombre = @pNombre,
			Descripcion =@pDescripcion ,
			Estatus = @pEstatus,
			Estacion = @pEstacion,
			Capacidad = @pCapacidad,
			Producto = @pProducto,
			Diametro = @pDiametro,
			Altura = @pAltura,
			Constante = @pConstante,
			PctNoBombeable=@pPctNoBombeable,
			VolNoBombeable = @pVolNoBombeable,
			PctMaximo =@pPctMaximo ,
			VolMaximo = @pVolMaximo,
			PorcentajeAgua = @pPorcentajeAgua,			
			ProductoAlmacenado =@pProductoAlmacenado,
			IdTipoTanque = @pIdTipoTanque,
			MedicionManual = @pMedicionManual,
			PuntoEntregaID = @pPuntoEntregaID
		where Id = @pId

	End
	


