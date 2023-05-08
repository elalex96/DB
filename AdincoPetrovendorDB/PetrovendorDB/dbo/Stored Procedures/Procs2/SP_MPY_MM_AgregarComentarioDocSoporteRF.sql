
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <20-06-2018>
-- Description:	<Se agrega un comentario a los documentos que se subieron en la carga de facturas>
-- =============================================

CREATE procedure [dbo].[SP_MPY_MM_AgregarComentarioDocSoporteRF]
	@IdDocSoporteRecepcionFactura INT,
	@Comentario VARCHAR(1500),
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	UPDATE dbo.MPY_MM_DocSoporteRecepcionFactura
		SET Comentario = @Comentario
	WHERE IdDocSoporteRecepcionFactura = @IdDocSoporteRecepcionFactura
END
