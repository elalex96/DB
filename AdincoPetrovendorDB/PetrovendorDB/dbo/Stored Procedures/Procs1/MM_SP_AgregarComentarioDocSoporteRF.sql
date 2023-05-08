
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <02-04-2018>
-- Description:	<Se agrega un comentario a los documentos que se subieron en la carga de facturas>
-- =============================================

CREATE procedure MM_SP_AgregarComentarioDocSoporteRF
	@IdDocSoporteRecepcionFactura INT,
	@Comentario VARCHAR(1500),
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	UPDATE dbo.MM_DocSoporteRecepcionFactura
		SET Comentario = @Comentario
	WHERE IdDocSoporteRecepcionFactura = @IdDocSoporteRecepcionFactura
END