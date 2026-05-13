-- =============================================
-- Author:		<Jose Roman>
-- Create date: <13-06-2018>
-- Description:	<Se consulta el texto del xml para la descarga del Comprobante de pago relacinado con una factura>
-- =============================================

CREATE procedure FI_SP_DescargarXMLComprobante
	@IdFactura INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT f.XML, f.NombreXML
	FROM dbo.FI_FacturaCompPagoRelacion cp 
	INNER JOIN dbo.FI_Factura f ON f.IdFactura = cp.IdFacturaCompPago
	WHERE cp.IdFactura = @IdFactura
END