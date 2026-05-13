CREATE PROC AP_sp_EdicionComentarioBitacoraBloqueoFacturas
@Folio int,
@Motivo varchar(300),
@usuarioId int
as
begin
	UPDATE AP_BitacoraBloqueoFactura
	SET Motivo = @Motivo,
	ModificadoEl = GETDATE(),
	ModificadoPor = @usuarioId
	where Id = @folio

end