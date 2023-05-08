-- =============================================
-- Author:		<Jose Roman>
-- Create date: <01-04-2018>
-- Description:	<Se elimina logicamente un documento de soporte de recepcion de factura>
-- UPDATE: DANIEL AC 10/05/2018 AGREGUE FECHA DE ELIMINACIÓN
-- =============================================

CREATE procedure [dbo].[MM_SP_EliminarDocSoporteRecepcionFactura]
	@IdDocSoporteRecepcionFactura INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	   UPDATE dbo.MM_DocSoporteRecepcionFactura
		SET Eliminado = 1,
		EliminadoEl=GETDATE()
	WHERE IdDocSoporteRecepcionFactura = @IdDocSoporteRecepcionFactura
END