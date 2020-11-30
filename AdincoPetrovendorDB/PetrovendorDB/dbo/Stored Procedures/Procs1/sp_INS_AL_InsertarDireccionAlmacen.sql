

-- sp_INS_AL_InsertarDireccionAlmacen 1,
Create Proc [dbo].[sp_INS_AL_InsertarDireccionAlmacen]
@pIdAlmacen int,
@pIdProveedor int,
@pIdDomicilio	int,
@pPais	varchar(100),
@pEstado	varchar(100),
@pMunicipio	varchar(100),
@pColonia	varchar(100),
@pTipoViabilidad	varchar(100),
@pNombreViabilidad	varchar(100),
@pNoExterior	varchar(100),
@pNoInterior	varchar(100),
@pCodigoPostal	varchar(100),
--@pIdTipoDomicilio	int,
@pIdCreadoPor	int,
@pFechaAlta	datetime,
@pActivo	bit,
@pIdPais	int,
@pIdEstado	int,
@pCalle	varchar(100),
@pPublico	bit,
@pIdActualizadoPor	int,
@pNoSecuencia	int
as


	
	
	begin tran

	insert into DG_Domicilio(Pais,	Estado,		Municipio,			Colonia,		TipoViabilidad,
					NombreViabilidad,	NoExterior,		NoInterior,	CodigoPostal,		IdTipoDomicilio,IdProveedor,
					IdCreadoPor,		FechaAlta,		Activo,		IdPais,				IdEstado,		Calle,
					Publico,			IdActualizadoPor,FechaCambio,NoSecuencia)
	values(			@pPais,			@pEstado,	@pMunicipio,		@pColonia,		@pTipoViabilidad,
					@pNombreViabilidad,	@pNoExterior,		@pNoInterior,	@pCodigoPostal,		5/*ALMACÉN*/,@pIdProveedor,
					@pIdCreadoPor,		@pFechaAlta,		@pActivo,		@pIdPais,				@pIdEstado,		@pCalle,
					@pPublico,			@pIdActualizadoPor,	NULL,	@pNoSecuencia)


	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	

	select @pIdDomicilio = isnull(max(IdDomicilio),0) 
	from DG_Domicilio

	select @pIdDomicilio

	insert into [IN_AL_Domicilio](IdAlmacen,IdDomicilio,CreadoPor,CreadoEl)
	select @pIdAlmacen,@pIdDomicilio,@pIdCreadoPor,getdate()

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end


	commit tran

	fin:
