-- =============================================
-- Author:	DAVID DE LA CRUZ
-- Create date:11/11/19
-- Description:	<Consulta para los documentos de soporte de recepcion de nota de credito.>
-- =============================================
CREATE PROCEDURE p_NC_ConsultaComprobantesNotaCredito
    @IdNotaCredito INT,
    @IdProveedor INT,
    @IdUsuario INT,
    @IdAceptacionPedido INT,
    @TipoDocumento NVARCHAR(MAX)
AS
BEGIN
    IF @TipoDocumento = 'XML'
    BEGIN
	  
	SELECT
	CONCAT('Nota de crédito referencia ', CAST(NC.IdAceptacionNotaCredito AS NVARCHAR(MAX)),' aceptación pedido ',  CAST(NC.IdAceptacionPedido AS NVARCHAR(MAX)), '.xml') AS [fileName],
	F.ComprobanteXMLByte AS byteArray,
	'text/xml' AS Mime
	FROM dbo.mpy_MM_AceptacionNotaCredito NC
	INNER JOIN dbo.FI_Factura F ON F.IdFactura = NC.IdFacturaNotaCredito
	WHERE 
	NC.IdAceptacionNotaCredito= @IdNotaCredito
	AND NC.IdAceptacionPedido = @IdAceptacionPedido		

    END;

    IF @TipoDocumento = 'PDF'
    BEGIN
    SELECT 
	CONCAT('Nota de crédito referencia ', CAST(NC.IdAceptacionNotaCredito AS NVARCHAR(MAX)),' aceptación pedido ',  CAST(NC.IdAceptacionPedido AS NVARCHAR(MAX)), '.pdf') AS [fileName],
	F.ComprobanteXMLByte AS byteArray,
	'application/pdf' AS Mime
	FROM dbo.MPY_MM_AceptacionNotaCredito NC
	INNER JOIN dbo.FI_Factura F ON F.IdFactura = NC.IdFacturaNotaCredito
	WHERE 
	NC.IdAceptacionNotaCredito=@IdNotaCredito
	AND NC.IdAceptacionPedido=@IdAceptacionPedido
    END;
	
END;
