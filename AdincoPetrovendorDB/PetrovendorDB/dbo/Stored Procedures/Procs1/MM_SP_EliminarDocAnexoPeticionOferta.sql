-- =============================================
-- Author:		<Jose Roman>
-- Create date: <05-04-2018>
-- Description:	<Se elimina un documento anexo en peticion oferta>
-- UPDATE:	DANIEL AC 10/05/2018 AGREGUE FECHA DE ELIMINACIÓN
-- =============================================

CREATE procedure [dbo].[MM_SP_EliminarDocAnexoPeticionOferta]
	@IdDocAnexoPeticionOferta INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	UPDATE dbo.MM_DocAnexosPeticionOferta
	SET Eliminado = 1,
	EliminadoEl = GETDATE()
	WHERE IdDocAnexoPeticionOferta = @IdDocAnexoPeticionOferta
END