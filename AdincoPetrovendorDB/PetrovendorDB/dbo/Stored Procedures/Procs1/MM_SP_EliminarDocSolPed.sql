
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <22-11-2018>
-- Description:	<Eliminado logico de documento cargado en la solped>
-- =============================================

CREATE PROCEDURE MM_SP_EliminarDocSolPed	
	@IdDocumento INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	UPDATE dbo.MM_DocumentosSolPed
	SET Activo = 0,
		ModificadoPor = @IdUsuario,
		ModificadoEl = GETDATE()
	WHERE IdDocumento = @IdDocumento
END