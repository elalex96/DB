-- =============================================
-- Author:		Daniel AC
-- Create date: <03/03/2022>
-- Description:	Se manda a llamar la ruta inicial del folder de dropbox
-- =============================================
CREATE PROCEDURE [dbo].[SP_MPY_FI_InsertaFacturaMercadeo] 
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
	@IdSubcontratista	INT = NULL,
	@IdMoneda	int ,
	@IdContrato	int ,
	@XML	nvarchar(MAX) ,
	@Activa	bit ,
	@ArchivoPDF	nvarchar(MAX) ,
	@ArchivoXML	nvarchar(MAX) , 
	@IdUsuario int,
	@IdAceptacionPedido INT,
	@ComprobanteXMLByte IMAGE,
	@IdTipoPedido INT,
	@IdWS_LectorFactura INT=null,
	@ErroSAT nvarchar(MAX)=null
AS
BEGIN
	SET NOCOUNT ON;
DECLARE @ENCONTRADO AS INTEGER
DECLARE @IdContratoF INT 
DECLARE @IdFactura INT = (SELECT IdFactura FROM dbo.MPY_MM_AceptacionFactura WHERE IdAceptacionPedido = @IdAceptacionPedido)


IF ISNULL(@IdContratoF,0) = 0
BEGIN
	SET @IdContratoF = (SELECT TOP 1 CAST(AP.IdContrato AS INT)
								  FROM dbo.MPY_MM_AceptacionPedido AS AP
								  WHERE AP.IdAceptacionPedido = @IdAceptacionPedido);
END

IF @IdFactura IS NULL OR @IdFactura = 0

	BEGIN 

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
				,[IdTipoPedido],
				 IdLectorXMLSAT,
			     ErroSAT)
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
					@IdTipoPedido,
					@IdWS_LectorFactura,
					@ErroSAT)

				SELECT CAST( @@IDENTITY  as nvarchar)  AS INSERTADO , 'La factura ' + @Serie +'-'+ @Folio + ' se ha registrado correctamente con el id ' + CAST( @@IDENTITY  as nvarchar)  as MSG,@@IDENTITY
		 



	END 
	ELSE
	BEGIN 
			
			UPDATE  [dbo].[FI_Factura]
			SET [Serie]=null
			  ,[Folio]=null
			  ,[Fecha]=null
			  ,[Sello]=null
			  ,[FormaPago]=null
			  ,[NoCertificado]=null
			  ,[Certificado]=null
			  ,[CondicionesDePago]=null
			  ,[SubTotal]=null
			  ,[Descuento]=null
			  ,[TipoCambio]=null
			  ,[Moneda]=null
			  ,[MontoConIva]=null
			  ,[TipoComprobante]=null
			  ,[MetodoPago]=null
			  ,[LugarExpedicion]=null
			  ,[NumCtaPago]=null
			  ,[Emisor]=null
			  ,[Receptor]=null
			  ,[UUID]=null
			  ,[FechaTimbrado]=null
			  ,[SelloCFD]=null
			  ,[NoCertificadoSAT]=null
			  ,[SelloSAT]=null
			  ,[Tipo]=null
			  ,[FechaRecepcion]=null
			  ,[IdSubcontratista]=null
			  ,[IdMoneda]=null
			  ,[IdContrato]=null
			  ,[XML]=null
			  ,[Activa]=null
			  ,[ArchivoXML]=null
			  ,[CreadoPor]=null
			  ,[CreadoEn]=null
			  ,[ModificadoPor]=null
			  ,[ModificadoEn]=null
			  ,[PDF]=null
			  ,[IdReceptor]=null
			  ,[IdentificadorSIPAC]=null
			  ,[NombreXML]=null
			  ,[IdEstudioPrecioTransfer]=null
			  ,[IdDocFacturacionSIPAC]=null
			  ,[ProcesadoSIPAC]=null
			  ,[ClaveFormaPago]=null
			  ,[IdEstatusEnviado]=NULL			  
			  ,[ComprobanteXMLByte]=NULL
			  ,[IdTipoPedido]=NULL,
			  IdLectorXMLSAT =NULL,
			  ErroSAT =NULL
			WHERE IdFactura = @IdFactura
			
		
			UPDATE  [dbo].[FI_Factura]
			SET [Serie]= @Serie
			,[Folio]=@Folio 
			,[Fecha]= @Fecha
			,[Sello]= @Sello
			,[FormaPago]= @FormaPago
			,[NoCertificado]= @NoCertificado
			,[Certificado]= @Certificado
			,[CondicionesDePago]= @CondicionesDePago
			,[SubTotal]= @SubTotal
			,[Descuento]= @Descuento
			,[TipoCambio]= @TipoCambio
			,[Moneda]= @Moneda
			,[MontoConIva]=@MontoConIva
			,[TipoComprobante]=@TipoComprobante
			,[MetodoPago]=@MetodoPago
			,[LugarExpedicion]=@LugarExpedicion
			,[NumCtaPago]=@NumCtaPago
			,[Emisor]=@Emisor
			,[Receptor]=@Receptor
			,[UUID]=@UUID
			,[FechaTimbrado]=@FechaTimbrado
			,[SelloCFD]=@SelloCFD
			,[NoCertificadoSAT]=@NoCertificadoSAT
			,[SelloSAT]=@SelloSAT
			,[Tipo]=@Tipo
			,[FechaRecepcion]=@FechaRecepcion
			,[IdMoneda]=@IdMoneda
			,[IdContrato]=@IdContratoF
			,[XML]=@XML
			,[Activa]=@Activa
			,[ArchivoXML]=@ArchivoXML
			,[CreadoPor]=@IdUsuario
			,[CreadoEn]=CURRENT_TIMESTAMP
			,[ModificadoPor]=@IdUsuario
			,[ModificadoEn]=CURRENT_TIMESTAMP
			,[ProcesadoSIPAC]=0
			,[ComprobanteXMLByte]=@ComprobanteXMLByte
			,[IdTipoPedido]=@IdTipoPedido	
			, IdLectorXMLSAT =@IdWS_LectorFactura,
			  ErroSAT =@ErroSAT
			WHERE IdFactura = @IdFactura

			SELECT CAST( @IdFactura  as nvarchar)  AS INSERTADO , 'La factura ' + @Serie +'-'+ @Folio + ' se ha Actualizado correctamente con el id ' + CAST(@IdFactura  as nvarchar)  as MSG, @IdFactura


	END 

END
