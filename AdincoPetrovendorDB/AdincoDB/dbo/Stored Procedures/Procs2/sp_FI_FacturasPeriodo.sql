CREATE PROCEDURE  [dbo].[sp_FI_FacturasPeriodo]
-- '02-06-2017', '02-08-2017', 3
	@Inicio date, 
	@Fin date, 
	@IdContrato int
AS
BEGIN
-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
	SET NOCOUNT ON;
	SET LANGUAGE spanish;

SELECT F.IdFactura, 
	   F.Serie, 
	   F.Folio, 
	   F.Fecha, 
	   F.Sello, 
	   F.FormaPago, 
	   F.NoCertificado, 
	   F.Certificado, 
	   F.CondicionesDePago, 
       F.SubTotal, 
	   F.Descuento, 
	   F.TipoCambio, 
	   F.Moneda, 
	   F.MontoConIva AS MontoTotal, 
	   F.TipoComprobante,
	   F.MetodoPago, 
       F.LugarExpedicion, 
	   F.NumCtaPago, 
	   F.Emisor, 
	   F.Receptor, 
	   F.UUID, 
	   F.FechaTimbrado, 
	   F.SelloCFD, 
	   F.NoCertificadoSAT, 
       F.SelloSAT, 
	   F.Tipo, 
	   F.FechaRecepcion, 
	   F.IdSubcontratista,  
	   F.XML, 
	   F.Activa, 
	   F.ArchivoPDF, 
       F.ArchivoXML, 
	   S.RazonSocial, 
	   S.NombreComercial, 
       S.CURP, 
	   I.Impuesto, 
	   SUM(I.Importe) AS ImporteImpuesto, 
	   U.Nombre, 
	   YEAR(F.Fecha) AS Anio, 
       CONCAT(RIGHT('00' + CAST(MONTH(F.Fecha) AS VARCHAR(2)), 2), ' ', DATENAME(mm, F.Fecha)) AS Mes, 
	   M.TipoMonedaCorto as Moneda
FROM
	FI_Factura F (NOLOCK)
INNER JOIN
	FI_CFDIImpuesto I (NOLOCK)
	ON F.IdFactura = I.IdFactura
	AND F.IdContrato = @IdContrato
	AND F.Fecha BETWEEN @inicio AND @fin
INNER JOIN
	AP_Usuario U (NOLOCK) 
	ON F.ModificadoPor = U.UsuarioID 
	AND F.CreadoPor = U.UsuarioID 
INNER JOIN
	PV_TipoMoneda M (NOLOCK) 
	ON F.IdMoneda = M.IdMoneda
LEFT OUTER JOIN
	PV_Subcontratista S (NOLOCK) 
	ON F.IdSubcontratista = S.IdSubcontratista	 
WHERE (F.IdContrato = @IdContrato)
	   AND (F.Fecha BETWEEN @inicio 
	   AND @fin)

GROUP BY F.IdFactura, 
		 F.Serie, 
		 F.Folio, 
		 F.Fecha,
		 F.Sello, 
		 F.FormaPago,
		 F.NoCertificado, 
		 F.Certificado, 
		 F.CondicionesDePago, 
         F.SubTotal, 
		 F.Descuento, 
		 F.TipoCambio, 
		 F.Moneda,
		 F.MontoConIva, 
		 F.TipoComprobante,
		 F.MetodoPago, 
		 F.LugarExpedicion, 
         F.NumCtaPago, 
		 F.Emisor,
		 F.Receptor,
		 F.UUID, 
		 F.FechaTimbrado, 
		 F.SelloCFD, 
		 F.NoCertificadoSAT, 
		 F.SelloSAT, 
		 F.Tipo, 
		 F.FechaRecepcion, 
		 F.IdSubcontratista,
		 F.IdMoneda, 
		 F.IdContrato,
		 F.XML, 
		 F.Activa, 
		 F.ArchivoPDF, 
		 F.ArchivoXML,
		 F.CreadoPor, 
         F.CreadoEn, 
		 F.ModificadoPor,
		 F.ModificadoEn, 
		 S.RazonSocial,
		 S.NombreComercial,
		 S.CURP, 
		 I.Impuesto, 
         U.Nombre, 
		 M.TipoMonedaCorto
    -- Insert statements for procedure here

END