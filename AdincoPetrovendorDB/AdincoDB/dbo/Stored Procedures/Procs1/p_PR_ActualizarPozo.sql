CREATE Proc p_PR_ActualizarPozo
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
@pComentarios	nvarchar(1000),
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
		where upper(rtrim(clave )) = upper(rtrim(@pclave )) and
		id <> @pId
	)
	begin
		set @pError = 'Ya existe un pozo con la misma clave'
		return
	end

	update PR_Pozo
	set					Clave=@pClave,	Nombre=@pNombre,		Descripcion=@pDescripcion,	Estatus=@pEstatus,
						LDD=@pLDD,		Estacion=@pEstacion,	Campo=@pCampo,				ProduccionNeta=@pProduccionNeta,		Tanque=@pTanque,
						UltimoControl=@pUltimoControl,	SubEstado=@pSubEstado,		TipoProduccion=@pTipoProduccion,		ActividadIncremental=@pActividadIncremental,TipoSistema=@pTipoSistema,
						PozoTipo=@pPozoTipo,		Modificado=getdate(),		ModificadoPor=@pCreadoPor,		ModificadoServer=getdate(),	Alta=getdate(),
						Comentarios=@pComentarios,	AnioActividad=@pAnioActividad,	UltimoControlValido=@pUltimoControlValido,ProduccionBruta=@pProduccionBruta,	PorcentajeAgua=@pPorcentajeAgua,
						X=@pX,				Y=@pY,				PotencialOperativo=@pPotencialOperativo,	PotencialOptimo=@pPotencialOptimo,	OFM=@pOFM,
						RegionFiscal=@pRegionFiscal,	TipoFluidoPetroleo=@pTipoFluidoPetroleo,TipoFluidoGas=@pTipoFluidoGas,PuntoEntregaID=@pPuntoEntregaID
	where Id = @pId


	update PR_PozoCargaValidacion
	set ValidadoPor = @pCreadoPor,
		ValidadoEl = getdate()
	where IdPozo = @pId and
	ValidadoPor is null
							


