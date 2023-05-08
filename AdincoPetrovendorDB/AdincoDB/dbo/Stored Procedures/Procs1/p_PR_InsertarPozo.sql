
Create Proc p_PR_InsertarPozo
@pId	int	,
@pClave	varchar(20),
@pNombre	varchar(200),
@pDescripcion	nvarchar(4000),
@pEstatus	int	,
@pLDD	tinyint	,
@pEstacion	int	,
@pCampo	int	,
@pProduccionNeta	decimal(24,8),
@pTanque	int	,
@pUltimoControl	datetime,
@pSubEstado	int	,
@pTipoProduccion	int,
@pActividadIncremental	int,
@pTipoSistema	int,
@pPozoTipo	int,
@pComentarios	nvarchar,
@pAnioActividad	int	,
@pUltimoControlValido	int,
@pProduccionBruta	decimal(24,8),
@pPorcentajeAgua	decimal	(8,4),
@pX	float	,
@pY	float	,
@pPotencialOperativo	decimal(24,8),
@pPotencialOptimo	decimal(24,8),
@pOFM	varchar(20),
@pRegionFiscal	nvarchar(200),
@pTipoFluidoPetroleo	nvarchar(300),
@pTipoFluidoGas	nvarchar(300),
@pPuntoEntregaID	int	,
@pCreadoPor int,
@pError varchar(250) out
as


	if exists (
		select 1
		from PR_Pozo
		where upper(rtrim(clave )) = upper(rtrim(@pclave ))
	)
	begin
		set @pError = 'Ya existe un pozo con la misma clave'
		return
	end


	insert into PR_Pozo(				Clave,			Nombre,				Descripcion,		Estatus,
						LDD,			Estacion,		Campo,				ProduccionNeta,		Tanque,
						UltimoControl,	SubEstado,		TipoProduccion,		ActividadIncremental,TipoSistema,
						PozoTipo,		Modificado,		ModificadoPor,		ModificadoServer,	Alta,
						Comentarios,	AnioActividad,	UltimoControlValido,ProduccionBruta,	PorcentajeAgua,
						X,				Y,				PotencialOperativo,	PotencialOptimo,	OFM,
						RegionFiscal,	TipoFluidoPetroleo,TipoFluidoGas,PuntoEntregaID)
	select								@pClave,		@pNombre,			@pDescripcion,			@pEstatus,
						@pLDD,			@pEstacion,		@pCampo,				@pProduccionNeta,		@pTanque,
						@pUltimoControl,@pSubEstado,	@pTipoProduccion,	@pActividadIncremental,	@pTipoSistema,
						@pPozoTipo,		getdate(),		@pCreadoPor,		getdate(),				getdate(),
						@pComentarios,	@pAnioActividad,@pUltimoControlValido,@pProduccionBruta,	@pPorcentajeAgua,
						@pX,			@pY,			@pPotencialOperativo,@pPotencialOptimo,		@pOFM,
						@pRegionFiscal,	@pTipoFluidoPetroleo,@pTipoFluidoGas,@pPuntoEntregaID