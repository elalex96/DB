Create Proc p_InsUpdEquiposAutoconsumo
@pIdContrato	int,
@pIdEquipo	int,
@pFecha	datetime,
@pUTMX	float,
@pUTMY	float,
@pProducto	varchar(50),
@pTipoEquipo	varchar(250),
@pTAG	varchar(300),
@pFluidoDesplazado	varchar(300),
@pConsumoTeorico	float,
@pConsumoReal	float,
@pConsumoEnergetico	float,
@pDispositivoInyeccion	varchar(1000),
@pObervaciones	varchar(1000)
as




	if not exists (
		select 1
		from [PR_EquiposAutoconsumo]
		where IdContrato = @pIdContrato and
		IdEquipo = @pIdEquipo
	)
	begin

		select @pIdEquipo = isnull(max(IdEquipo),0) + 1
		from [PR_EquiposAutoconsumo]
		where IdContrato = @pIdContrato 

		insert into [PR_EquiposAutoconsumo](
			IdContrato,		/*IdEquipo,*/			Fecha,					UTMX,				UTMY,
			Producto,		TipoEquipo,			TAG,					FluidoDesplazado,	ConsumoTeorico,
			ConsumoReal,	ConsumoEnergetico,	DispositivoInyeccion,	Obervaciones
		)
		values(
			@pIdContrato,		/*@pIdEquipo,*/			@pFecha,				@pUTMX,				@pUTMY,
			@pProducto,		@pTipoEquipo,			@pTAG,					@pFluidoDesplazado,	@pConsumoTeorico,
			@pConsumoReal,	@pConsumoEnergetico,	@pDispositivoInyeccion,	@pObervaciones
		)
	end
	Else
	Begin
		update [PR_EquiposAutoconsumo]
		set 	Fecha = @pFecha,
				UTMX = @pUTMX,
				UTMY = @pUTMY,
				Producto = @pProducto,
				TipoEquipo = @pTipoEquipo,
				TAG = @pTAG,
				FluidoDesplazado = @pFluidoDesplazado,
				ConsumoTeorico = @pConsumoTeorico,
				ConsumoReal =@pConsumoReal ,
				ConsumoEnergetico = @pConsumoEnergetico,
				DispositivoInyeccion = @pDispositivoInyeccion,
				Obervaciones = @pObervaciones
		where  IdContrato = @pIdContrato and
		IdEquipo = @pIdEquipo
	End

