USE [Adinco]
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'EliminarAWS_Documentos_Logico'
)
    DROP PROCEDURE EliminarAWS_Documentos_Logico
GO
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




