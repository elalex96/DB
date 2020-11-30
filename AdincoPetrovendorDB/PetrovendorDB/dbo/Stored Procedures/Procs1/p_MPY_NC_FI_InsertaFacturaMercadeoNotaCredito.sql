
-- Author:   Luis David
-- Create date: 07/11/2019
-- Description:   Se agrego columnas de error SAT
-- =============================================
CREATE  PROCEDURE [dbo].[p_MPY_NC_FI_InsertaFacturaMercadeoNotaCredito] 
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
	@IdUsuario int,
	@IdAceptacionPedido INT,
	@ComprobanteXMLByte IMAGE,
	@ComprobantePDFByte IMAGE,
	@IdTipoPedido INT,
	@IdLectorXMLSAT INT, 
	@ErrorSAT NVARCHAR(MAX)
AS
BEGIN
-- =============================================
-- Author:		DANIEL AC
-- Create date: 11/09/2019
-- Description:	Inserta una factura de tipo nota de crédito
-- =============================================
	SET NOCOUNT ON;
-- =============================================
DECLARE @ENCONTRADO AS INTEGER
DECLARE @IdContratoF INT 

IF @IdContrato = 0 
	BEGIN  
	SET @IdContratoF = (SELECT SP.IdContrato
						FROM MM_SolicitudPedido AS SP
						INNER JOIN MM_Pedido AS P ON P.IdSolicitudPedido= SP.IdSolicitudPedido
						INNER JOIN MM_AceptacionPedido As AP ON AP.IdPedido = P.IdPedido
						WHERE AP.IdAceptacionPedido  = @IdAceptacionPedido)
	END 
ELSE 
BEGIN
	SET @IdContratoF = @IdContrato
END 


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
				,[ArchivoXML]
				,[CreadoPor]
				,[CreadoEn]
				,[ModificadoPor]
				,[ModificadoEn]
				,[ProcesadoSIPAC]
				,[ComprobanteXMLByte]
				,[ComprobantePDFByte]
				,[IdTipoPedido]
				,[IdLectorXMLSAT]
				,[ErroSAT])
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
				    @IdSubcontratista,
				    @IdMoneda,
				    @IdContratoF,
				    @XML,
				    @Activa,
				    @ArchivoXML,
				    @IdUsuario,
				    CURRENT_TIMESTAMP,
				    @IdUsuario,
				    CURRENT_TIMESTAMP,
				    0,
					@ComprobanteXMLByte,
					@ComprobantePDFByte,
					NULL,
					@IdLectorXMLSAT,
					@ErrorSAT)
							 
 

	SELECT SCOPE_IDENTITY()  AS IdFactura
END