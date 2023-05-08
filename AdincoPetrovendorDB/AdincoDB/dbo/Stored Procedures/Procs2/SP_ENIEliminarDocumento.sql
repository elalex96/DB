CREATE PROCEDURE SP_ENIEliminarDocumento
@UUID varchar(Max),
@IdUsuario int = null,
@Contrato int = null
AS
BEGIN
	DELETE FROM AWS_DocumentoENI 
	WHERE uuidamazon = @UUID
END