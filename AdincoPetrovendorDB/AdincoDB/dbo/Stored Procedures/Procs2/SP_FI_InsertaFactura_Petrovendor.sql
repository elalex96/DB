CREATE PROCEDURE [dbo].[SP_FI_InsertaFactura_Petrovendor] 
	@Serie	nvarchar(MAX) ,
	@Folio	nvarchar(MAX) ,
	@Fecha	datetime ,
	@Sello	nvarchar(MAX) ,
	@FormaPago	nvarchar(MAX) ,
	@NoCertificado	nvarchar(MAX) ,
	@Certificado	nvarchar(MAX) ,
	@CondicionesDePago	nvarchar(MAX) ,
	@SubTotal	money ,
	@Descuento	money ,
	@TipoCambio	money ,
	@Moneda	nvarchar(MAX) ,
	@MontoConIva	decimal ,
	@TipoComprobante	nvarchar(MAX) ,
	@MetodoPago	nvarchar(MAX) ,
	@LugarExpedicion	nvarchar(MAX) ,
	@NumCtaPago	nvarchar(MAX) ,
	@Emisor	nvarchar(MAX) ,
	@Receptor	nvarchar(MAX) ,
	@UUID	nvarchar(MAX) ,
	@FechaTimbrado	datetime ,
	@SelloCFD	nvarchar(MAX) ,
	@NoCertificadoSAT	nvarchar(MAX) ,
	@SelloSAT	nvarchar(MAX) ,
	@Tipo	nvarchar(MAX) ,
	@FechaRecepcion	datetime ,
	@IdSubcontratista	int ,
	@IdMoneda	int ,
	@IdContrato	int ,
	@XML	nvarchar(MAX) ,
	@Activa	bit ,
	@ArchivoPDF	nvarchar(MAX) ,
	@ArchivoXML	nvarchar(MAX) , 
	@IdUsuario int
AS
BEGIN
-- =============================================
-- Author:		Daniel 
-- Create date: 17-08-2017
-- Description:	Inserta una factura 
-- =============================================
	SET NOCOUNT ON;
-- =============================================
DECLARE @ENCONTRADO AS INTEGER

     
		  INSERT INTO [dbo].[FI_Factura]
				([Serie]
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
				,[ProcesadoSIPAC])
				VALUES
				(
				    @Serie,
				    @Folio,
				    @Fecha,
				    @Sello,
				    @FormaPago,
				    @NoCertificado,
				    @Certificado,
				    @CondicionesDePago,
				    @SubTotal,
				    @Descuento,
				    @TipoCambio,
				    @Moneda,
				    @MontoConIva,
				    @TipoComprobante,
				    @MetodoPago,
				    @LugarExpedicion,
				    @NumCtaPago,
				    @Emisor,
				    @Receptor,
				    @UUID,
				    @FechaTimbrado,
				    @SelloCFD,
				    @NoCertificadoSAT,
				    @SelloSAT,
				    @Tipo,
				    @FechaRecepcion,
				    NULL,
				    @IdMoneda,
				    @IdContrato,
				    @XML,
				    @Activa,
				    @ArchivoPDF,
				    @ArchivoXML,
				    @IdUsuario,
				    CURRENT_TIMESTAMP,
				    @IdUsuario,
				    CURRENT_TIMESTAMP,
				    0)

				SELECT @@IDENTITY  AS IdFactura
		  
	   
END
 
