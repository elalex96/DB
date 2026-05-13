CREATE PROCEDURE AP_sp_InsertaBitacoraBloqueoFactura
@IdProveedor int,
@IdProveedorBloqueado Int,
@IdUsuario int,
@Motivo varchar(300),
@Bloqueado bit
as
begin
DECLARE @descripcionStr varchar(100);
	if @Bloqueado = 1
	begin
		SET @descripcionStr = ('Bloqueo')
	end
	else
	begin
		SET @descripcionStr = ('Desbloqueo')
	end
	INSERT INTO AP_BitacoraBloqueoFactura(
	Motivo,			Descripcion,		Bloqueado,		IdProveedorBloqueado,
	IdProveedor,	CreadoEl,			CreadoPor) 
	VALUES (
	@Motivo,		@descripcionStr,	@Bloqueado,		@IdProveedorBloqueado,
	@IdProveedor,	GETDATE(),			@IdUsuario)
end