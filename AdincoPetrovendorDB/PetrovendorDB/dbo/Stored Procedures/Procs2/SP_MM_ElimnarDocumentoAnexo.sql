CREATE PROCEDURE [dbo].[SP_MM_ElimnarDocumentoAnexo]
	@IdDocumentoAnexo INT
AS
BEGIN

	UPDATE  dbo.MM_DocumentosAnexos
	SET Activo = 0,
	EliminadoEl=GETDATE()	
	WHERE IdDocumentoAnexo = @IdDocumentoAnexo

END