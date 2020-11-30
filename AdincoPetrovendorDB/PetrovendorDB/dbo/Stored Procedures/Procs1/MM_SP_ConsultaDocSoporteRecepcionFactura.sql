
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <01-04-2018>
-- Description:	<Consulta para los documentos de soporte de recepcion de factura.>
-- =============================================

CREATE procedure MM_SP_ConsultaDocSoporteRecepcionFactura
	@IdAceptacionPedido INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT IdDocSoporteRecepcionFactura,
		NombreDoc,
		Comentario
	FROM dbo.MM_DocSoporteRecepcionFactura
	WHERE IdAceptacionPedido = @IdAceptacionPedido
		AND Eliminado = 0
END