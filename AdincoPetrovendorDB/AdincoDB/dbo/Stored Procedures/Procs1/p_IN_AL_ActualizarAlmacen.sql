Create Proc p_IN_AL_ActualizarAlmacen
@pIdContrato int,
@pIdAlmacen	int out ,
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
@pActivo bit,
@pCreadoPor	varchar(100)
as

	declare @creadoPor int,
			@idProveedor int,			
			@IdDomicilio INT

	select @creadoPor = IdUsuario
	from Petrovendor.dbo.S_Usuario
	where Correo = @pCreadoPor

	select @idProveedor = prov.IdProveedor
	from CO_Contrato c
	inner join CO_Contratista ctista on ctista.IdCOntratista = c.IdContratista
	inner join Petrovendor.dbo.S_Proveedor prov on prov.RFC collate SQL_Latin1_General_CP1_CI_AS = ctista.RFC collate SQL_Latin1_General_CP1_CI_AS
	where idContrato = @pIdContrato

	Begin tran

	update Petrovendor.dbo.IN_ALMACEN
	set Nombre = @pNombre,
		Clave = @pClave,
		Telefono = @pTelefono,
		Domicilio = @pCalle,
		Email = @pEmail,
		UEPS = @pUEPS,
		ModificadoPor = @creadoPor,
		ModificadoEl = getdate(),
		Activo = @pActivo 
	where IdAlmacen = @pIdAlmacen

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	if exists (
		select 1
		from Petrovendor.dbo.DG_Domicilio d
		inner join Petrovendor.dbo.[IN_AL_Domicilio] da on da.IdDomicilio = d.IdDomicilio
		where da.IdAlmacen = @pIdAlmacen
	)
	begin

		update Petrovendor.dbo.DG_Domicilio
		set Calle = @pCalle,
			Pais = @pPais,
			Estado=@pEstado	,
			Municipio = @pMunicipio,
			Colonia = @pColonia	,
			NoExterior = @pNoExterior,
			NoInterior = @pNoInterior,
			CodigoPostal=@pCodigoPostal	
		from Petrovendor.dbo.DG_Domicilio d
		inner join Petrovendor.dbo.[IN_AL_Domicilio] da on da.IdDomicilio = d.IdDomicilio
		where da.IdAlmacen = @pIdAlmacen

	End
	Else
	Begin

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

		select @IdDomicilio=SCOPE_IDENTITY()

		insert into Petrovendor.[dbo].[IN_AL_Domicilio] (IdAlmacen,IdDomicilio,CreadoPor,CreadoEl)
		select @pIdAlmacen,@IdDomicilio,@creadoPor,getdate()


		if @@error <> 0
		begin
			rollback tran
			goto fin
		end
	End
	

	

	commit tran

	fin:

