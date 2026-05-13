CREATE PROCEDURE [dbo].[SP_FI_ConsultarFactura] 
	@IdFactura INT 
AS
BEGIN
-- =============================================
-- Author:		Miguel - DANIEL MODIFICACION
-- Create date: 5-12-16 - 15/08/2017
-- Description:	Consulta una factura
-- =============================================
	SET NOCOUNT ON;
-- =============================================
 
	SELECT [IdFactura]
      ,[Serie]
      ,[Folio]
      ,[Fecha]
      ,[Sello]
      ,[FormaPago]
      ,[NoCertificado]
      ,[Certificado]
      ,[CondicionesDePago]
      ,[SubTotal]
      ,[Descuento]
      ,[TipoCambio]
      ,[Moneda]
      ,[MontoConIva]
      ,[TipoComprobante]
      ,[MetodoPago]
      ,[LugarExpedicion]
      ,[NumCtaPago]
      ,[Emisor]
      ,[Receptor]
      ,[UUID]
      ,[FechaTimbrado]
      ,[SelloCFD]
      ,[NoCertificadoSAT]
      ,[SelloSAT]
      ,[Tipo]
      ,[FechaRecepcion]
      ,[IdSubcontratista]
      ,[IdMoneda]
      ,[IdContrato]
      ,[XML]
      ,[Activa]
      ,[ArchivoPDF]
      ,[ArchivoXML]
      ,[CreadoPor]
      ,[CreadoEn]
      ,[ModificadoPor]
      ,[ModificadoEn]
      ,[PDF]
      ,[IdReceptor]
      ,[IdentificadorSIPAC]
      ,[NombreXML]
      ,[IdEstudioPrecioTransfer]
      ,[IdDocFacturacionSIPAC]
      ,[ProcesadoSIPAC]
      ,[ClaveFormaPago]
      ,[IdEstatusEnviado]
  FROM [FI_Factura]
  WHERE IdFactura = @IdFactura


END

