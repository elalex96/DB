
-- =============================================
-- Author:	Daniel AC
-- Create date:08/09/2019
-- Description:	<Consulta para los documentos de soporte de recepcion de nota de credito.>
-- =============================================
CREATE PROCEDURE SP_NC_ConsultaComprobantesNotaCredito
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
	FROM dbo.MM_AceptacionNotaCredito NC
	INNER JOIN dbo.FI_Factura F ON F.IdFactura = NC.IdFacturaNotaCredito
	LEFT JOIN dbo.MM_AceptacionPedido AP ON AP.IdAceptacionPedido=NC.IdAceptacionPedido
	WHERE NC.IdAceptacionNotaCredito=@IdNotaCredito
	AND NC.IdAceptacionPedido=@IdAceptacionPedido		

    END;

    IF @TipoDocumento = 'PDF'
    BEGIN
       SELECT 
	CONCAT('Nota de crédito referencia ', CAST(NC.IdAceptacionNotaCredito AS NVARCHAR(MAX)),' aceptación pedido ',  CAST(NC.IdAceptacionPedido AS NVARCHAR(MAX)), '.pdf') AS [fileName],
	F.ComprobanteXMLByte AS byteArray,
	'application/pdf' AS Mime
	FROM dbo.MM_AceptacionNotaCredito NC
	INNER JOIN dbo.FI_Factura F ON F.IdFactura = NC.IdFacturaNotaCredito
	LEFT JOIN dbo.MM_AceptacionPedido AP ON AP.IdAceptacionPedido=NC.IdAceptacionPedido
	WHERE NC.IdAceptacionNotaCredito=@IdNotaCredito
	AND NC.IdAceptacionPedido=@IdAceptacionPedido
    END;
	
END;

