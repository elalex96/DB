
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <01-04-2018>
-- Description:	<Consulta para los documentos de soporte de recepcion de factura.>
-- =============================================

CREATE procedure [dbo].[MM_SP_ConsultaDocSoporteRecepcionFactura]
	@IdAceptacionPedido INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT 
		DSF.IdDocSoporteRecepcionFactura,
		DSF.NombreDoc,
		DSF.Comentario,
		DSF.CargadoEl,
		US.Nombre
	FROM dbo.MM_DocSoporteRecepcionFactura AS DSF
	LEFT JOIN S_Usuario AS US 
		ON DSF.CargadoPor = US.IdUsuario
	WHERE IdAceptacionPedido = @IdAceptacionPedido
		AND Eliminado = 0;
END