USE Petrovendor
GO
--Modifier: Luis David
-- Modifier date: 24-06-2021
-- Description: Edición del comentario de bitacora de carga de facturas
DROP PROCEDURE IF EXISTS AP_sp_EdicionComentarioBitacoraBloqueoFacturas
GO
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