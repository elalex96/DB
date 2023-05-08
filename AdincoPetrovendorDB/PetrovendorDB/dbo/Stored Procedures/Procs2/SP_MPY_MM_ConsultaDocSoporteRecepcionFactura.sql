
-- =============================================
-- Author:		Alexander Gomez
-- Create date: <20-06-2018>
-- Description:	<Consulta para los documentos de soporte de recepcion de factura.>
-- =============================================

CREATE procedure [dbo].[SP_MPY_MM_ConsultaDocSoporteRecepcionFactura]
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
	FROM dbo.MPY_MM_DocSoporteRecepcionFactura
	WHERE IdAceptacionPedido = @IdAceptacionPedido
		AND Eliminado = 0
END
