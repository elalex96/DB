Create Proc p_IN_AL_InsertarAlmacen
@pIdContrato int,
@pIdAlmacen	int out,
@pNombre	varchar(250),
@pClave	varchar(10),
@pTelefono	varchar(15),
@pCalle	varchar(500),
@pPais	varchar(300),
@pEstado	varchar(300),
@pMunicipio	varchar(300),
@pColonia	varchar(300),
@pNoExterior	varchar(300),
@pNoInterior	varchar(300),
@pCodigoPostal	varchar(300),
@pEmail	varchar(50),
@pUEPS	bit,
@pCreadoPor	varchar(100)
as

	declare @creadoPor int,
			@idProveedor int
	
	select @pIdAlmacen = isnull(max(IdAlmacen),0)+1
	from Petrovendor.dbo.IN_ALMACEN

	select @creadoPor = IdUsuario
	from Petrovendor.dbo.S_Usuario
	where Correo = @pCreadoPor

	select @idProveedor = prov.IdProveedor
	from CO_Contrato c
	inner join CO_Contratista ctista on ctista.IdCOntratista = c.IdContratista
	inner join Petrovendor.dbo.S_Proveedor prov on prov.RFC collate SQL_Latin1_General_CP1_CI_AS = ctista.RFC collate SQL_Latin1_General_CP1_CI_AS
	where idContrato = @pIdContrato

	begin tran

	insert into Petrovendor.dbo.IN_ALMACEN(
		IdAlmacen,Nombre,Clave,Telefono,Domicilio,
		Email,UEPS,Activo,CreadoPor,CreadoEl,
		ModificadoPor,ModificadoEl,IdLineaPresupuestoMes
	)
	values(
		@pIdAlmacen,@pNombre,@pClave,@pTelefono,@pCalle,
		@pEmail,@pUEPS,1,@creadoPor,getdate(),
		null,null,null
	)

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	insert into Petrovendor.dbo.[IN_ContratoAlmacen](
		IdContrato,IdAlmacen,CreadoPor,CreadoEl
	)
	select @pIdContrato,@pIdAlmacen,@creadoPor,getdate()

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	insert into Petrovendor.dbo.[S_UsuarioAlmacen]
	select @creadoPor,@pIdAlmacen,@creadoPor,getdate()

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	--INSERTAR DIRECCIÓN
	insert into Petrovendor.dbo.DG_Domicilio(
		Pais,			Estado,				Municipio,		Colonia,
		TipoViabilidad,	NombreViabilidad,	NoExterior,		NoInterior,
		CodigoPostal,	IdTipoDomicilio,	IdProveedor,	IdCreadoPor,
		FechaAlta,		Activo,				IdPais,			IdEstado,
		Calle,			Publico,			IdActualizadoPor,FechaCambio,
		NoSecuencia
	)
	select @pPais,@pEstado,@pMunicipio,@pColonia,
		null,			null,				@pNoExterior,	@pNoInterior,
		@pCodigoPostal, 5,					@idProveedor,			@creadoPor,
		getdate(),		1,					null,			null,
		@pCalle,		0,					null,			null,
		1

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	insert into Petrovendor..[IN_AL_Domicilio] (
		CreadoEl,CreadoPor,IdAlmacen,IdDomicilio
	)
	select getdate(),@creadoPor,@pIdAlmacen,scope_identity()

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	commit tran

	fin:


