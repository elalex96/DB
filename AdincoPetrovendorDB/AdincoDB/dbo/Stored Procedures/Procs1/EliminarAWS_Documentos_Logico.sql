CREATE PROCEDURE  [dbo].[EliminarAWS_Documentos_Logico]
	@IdUsuario INT,
	@IdContrato INT,
	@AWSDocumentoId INT
AS    
BEGIN      
	UPDATE AWS_Documentos
	SET Activo = 0,
		ModificadoPor = @IdUsuario,
		ModificadoEl = GETDATE()
	WHERE AWSDocumentoId = @AWSDocumentoId
END




