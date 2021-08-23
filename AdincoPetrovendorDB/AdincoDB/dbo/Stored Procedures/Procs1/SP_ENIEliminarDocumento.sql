-- =============================================
-- Author:		Luis David
-- Create date: 18/08/2021
-- Description:	SP para eliminar documentos
-- =============================================
drop procedure if exists SP_ENIEliminarDocumento
go
CREATE PROCEDURE SP_ENIEliminarDocumento
@UUID varchar(Max),
@IdUsuario int = null,
@Contrato int = null
AS
BEGIN
	DELETE FROM AWS_DocumentoENI 
	WHERE uuidamazon = @UUID
END