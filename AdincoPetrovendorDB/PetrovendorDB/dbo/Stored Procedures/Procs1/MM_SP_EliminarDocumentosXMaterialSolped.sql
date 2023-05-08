
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <22-11-2018>
-- Description:	<Se elimina logicamente un documentos adjunto al material de una solped>
-- =============================================

CREATE PROCEDURE MM_SP_EliminarDocumentosXMaterialSolped	
	@IdSolPedMaterialDocumentoAdj INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	UPDATE dbo.MM_SolPedArchivoAdjuntoMaterial
	SET Activo = 0,
		ModificadoPor = @IdUsuario,
		ModificadoEl = GETDATE()
	WHERE IdSolPedMaterialDocumentoAdj = @IdSolPedMaterialDocumentoAdj
END