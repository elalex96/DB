CREATE PROCEDURE ENT_sp_GuardaBitacora
--===========================================
--===========================================
--Creado Por: Luis David
--Creado El: 17/12/2021
--===========================================
--===========================================
	@Ruta varchar(300),
	@Archivo varchar(500),
	@AWSArchivoId int,
	@AWSIdentificador varchar(max),	
	@UsuarioId int,
	@IdContrato int,
	@Accion varchar(300)
AS
BEGIN
	INSERT INTO ENT_BitacoraArchivos(
	Fecha,				Ruta,			Archivo,	
	AWSIdentificador,	UsuarioId,		IdContrato,
	Accion,				AWSArchivoId) VALUES
	(GETDATE(),			@Ruta,			@Archivo,
	@AWSIdentificador,	@UsuarioId,		@IdContrato,
	@Accion,			@AWSArchivoId)
END