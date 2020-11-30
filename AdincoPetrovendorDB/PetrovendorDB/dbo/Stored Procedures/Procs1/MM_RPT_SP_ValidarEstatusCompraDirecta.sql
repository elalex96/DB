-- =============================================
-- Author:		<Jose Roman>
-- Create date: <12-09-2018>
-- Description:	<Se devuelve el estado de la confirmacion del pedido para el texto de marca de agua en el reporte de OC>
-- =============================================

create PROCEDURE MM_RPT_SP_ValidarEstatusCompraDirecta 
	@IdFactura INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	SELECT CASE
		when ISNULL(f.IsEliminado, 0) = 1 THEN 'CANCELADO POR ELIMINACIÓN DE FACTURA'
		WHEN o.IdEstatusOperacion = 1 AND ISNULL(f.IsEliminado, 0) = 0 THEN 'COMPRA DIRECTA EN APROBACIÓN'
		WHEN O.IdEstatusOperacion = 3 THEN 'COMPRA DIRECTA RECHAZADA'
		ELSE '' END
	FROM dbo.FI_Factura f
	INNER JOIN dbo.TA_Operacion o ON o.IdDocumento = f.IdFactura AND o.IdTipoOperacion = 14
	WHERE f.IdFactura = @IdFactura
END