
Create proc p_IN_AL_BajaAlmacen
@pIdAlmacen int,
@pModificadoPor varchar(100)
as
	
	declare @creadoPor int

	select @creadoPor = IdUsuario
	from Petrovendor.dbo.S_Usuario
	where Correo = @pModificadoPor

	update Petrovendor.dbo.IN_ALMACEN
	set Activo = 0,
		ModificadoPor = @creadoPor,
		ModificadoEl = getdate()
	where idAlmacen = @pIdAlmacen
