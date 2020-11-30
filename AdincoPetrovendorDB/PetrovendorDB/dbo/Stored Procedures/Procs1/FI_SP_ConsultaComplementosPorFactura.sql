-- =============================================  
-- Author:  <Jose Roman>  
-- Create date: <04-12-2018>  
-- Description: <Se consultan los complementos por factura>  
-- =============================================  
-- Author:  <Alexander Gomez>  
-- Create date: <18-11-2020>  
-- Description: <se agregan las validaciones de moneda y calculos de montos>  
-- =============================================  
CREATE PROCEDURE [dbo].[FI_SP_ConsultaComplementosPorFactura]   
 @IdFactura INT,  
 /*---------------------Parametros contrato---------------------*/  
 @IdContrato INT = NULL,  
 @IdUsuario INT = NULL,  
 @FechaRegistro DATETIME = NULL   
 /*---------------------Parametros contrato---------------------*/  
AS  
BEGIN  

 SELECT 
   fc.IdComplemento,  
   f.IdFactura,  
   f.MontoConIva AS SubTotal, 
   CASE	
		--SI LA FACTURA Y EL COMPROBANTE ESTAN EN PESOS
		WHEN f.Moneda = 'MXN' AND FCF.MonedaP = 'MXN' THEN fc.MontoPagado
		--SI LA FACTURA ESTA EN PESOS EL COMPROBANTE EN DOLARES Y SI CUENTA CON TIPO DE CAMBIO
		WHEN f.Moneda = 'MXN' AND FCF.MonedaP = 'USD' AND ISNULL(f.TipoCambio,0) > 0 THEN (f.TipoCambio * fc.MontoPagado)
		--SI LA FACTURA ESTA EN PESOS EL COMPROBANTE EN DOLARES Y NO CUENTA CON TIPO DE CAMBIO
		WHEN f.Moneda = 'MXN' AND FCF.MonedaP = 'USD' AND ISNULL(f.TipoCambio,0) = 0 THEN dbo.FN_DolaresPesosTipoCambio(fc.MontoPagado,f.FechaTimbrado)
		--SI LA FACTURA Y EL COMPROBANTE ESTAN EN DOLARES
		WHEN f.Moneda = 'USD' AND FCF.MonedaP = 'USD' THEN fc.MontoPagado
		--SI LA FACTURA ESTA EN DOLARES EL COMPROBANTE EN PESOS Y SI CUENTA CON TIPO DE CAMBIO
		WHEN f.Moneda = 'USD' AND FCF.MonedaP = 'MXN' AND ISNULL(f.TipoCambio,0) > 0 THEN (fc.MontoPagado/f.TipoCambio)
		--SI LA FACTURA ESTA EN DOLARES EL COMPROBANTE EN PESOS Y NO CUENTA CON TIPO DE CAMBIO
		WHEN f.Moneda = 'MXN' AND FCF.MonedaP = 'USD' AND ISNULL(f.TipoCambio,0) = 0 THEN dbo.FN_PesosDolaresTipoCambio(fc.MontoPagado,f.FechaTimbrado)
	END AS MontoPagado,  
   CASE	
		--SI LA FACTURA Y EL COMPROBANTE ESTAN EN PESOS
		WHEN f.Moneda = 'MXN' AND FCF.MonedaP = 'MXN' THEN (f.MontoConIva - fc.MontoPagado)
		--SI LA FACTURA ESTA EN PESOS EL COMPROBANTE EN DOLARES Y SI CUENTA CON TIPO DE CAMBIO
		WHEN f.Moneda = 'MXN' AND FCF.MonedaP = 'USD' AND ISNULL(f.TipoCambio,0) > 0 THEN (f.MontoConIva - (f.TipoCambio * fc.MontoPagado))
		--SI LA FACTURA ESTA EN PESOS EL COMPROBANTE EN DOLARES Y NO CUENTA CON TIPO DE CAMBIO
		WHEN f.Moneda = 'MXN' AND FCF.MonedaP = 'USD' AND ISNULL(f.TipoCambio,0) = 0 THEN (f.MontoConIva - (dbo.FN_DolaresPesosTipoCambio(fc.MontoPagado,f.FechaTimbrado)))
		--SI LA FACTURA Y EL COMPROBANTE ESTAN EN DOLARES
		WHEN f.Moneda = 'USD' AND FCF.MonedaP = 'USD' THEN (f.MontoConIva - fc.MontoPagado)
		--SI LA FACTURA ESTA EN DOLARES EL COMPROBANTE EN PESOS Y SI CUENTA CON TIPO DE CAMBIO
		WHEN f.Moneda = 'USD' AND FCF.MonedaP = 'MXN' AND ISNULL(f.TipoCambio,0) > 0 THEN (f.MontoConIva - (fc.MontoPagado/f.TipoCambio))
		--SI LA FACTURA ESTA EN DOLARES EL COMPROBANTE EN PESOS Y NO CUENTA CON TIPO DE CAMBIO
		WHEN f.Moneda = 'MXN' AND FCF.MonedaP = 'USD' AND ISNULL(f.TipoCambio,0) = 0 THEN (f.MontoConIva - (dbo.FN_PesosDolaresTipoCambio(fc.MontoPagado,f.FechaTimbrado)))
	END AS MontoRemanente,
   ISNULL(pdf.IdPDFComplemento, 0) AS IdPDF  
 FROM dbo.FI_FacturaComplemento fc  
	INNER JOIN dbo.FI_Factura f 
		ON f.IdFactura = fc.IdFactura  
	LEFT JOIN dbo.FI_PDFComplemento pdf 
		ON pdf.IdFacturaComplemento = fc.IdFacturaComplemento 
	LEFT JOIN dbo.FI_ComplementoDePago AS FCF
		ON fc.IdComplemento = FCF.IdFactura
 WHERE fc.IdFactura = @IdFactura  
	--AND ISNULL(pdf.Activo, 0) = 1  

END