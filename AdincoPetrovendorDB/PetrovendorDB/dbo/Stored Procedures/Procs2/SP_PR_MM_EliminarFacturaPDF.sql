-- =============================================
-- Author:		Daniel Cruz
-- Create date: 08-08-17
-- Description:	 Elimina la factura de mercadeo de lado de petrovendor
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_EliminarFacturaPDF]
	-- Add the parameters for the stored procedure here

@IdAceptacionPedido int,
@IdDocumento int  

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		
		DECLARE @IdFactura INT = (SELECT IdFactura
								  FROM MM_AceptacionFactura
								  WHERE IdAceptacionPedido = @IdAceptacionPedido)

	 IF @IdDocumento = 17 
	 BEGIN
			UPDATE FI_Factura 
			SET [ArchivoPDF]= NULL,
			[ComprobantePDFByte]=NULL
			WHERE [IdFactura]= @IdFactura

			UPDATE MM_AceptacionFactura
			SET [FechaCargaPDF]=NULL,
			[FechaEvaluacionPDF]=NULL,
			[IdEstatusPDF]= 4
			WHERE [IdAceptacionPedido]= @IdAceptacionPedido

			SELECT 'Factura PDF Eliminado'
	END

	IF @IdDocumento =18
	BEGIN 
		    UPDATE FI_Factura 
			SET [Serie]= NULL
			  ,[Folio]= NULL
			  ,[Fecha]= NULL
			  ,[Sello]= NULL
			  ,[FormaPago]= NULL
			  ,[NoCertificado]= NULL
			  ,[Certificado]= NULL
			  ,[CondicionesDePago]= NULL
			  ,[SubTotal]= NULL
			  ,[Descuento]= NULL
			  ,[TipoCambio]= NULL
			  ,[Moneda]= NULL
			  ,[MontoConIva]= NULL
			  ,[TipoComprobante]= NULL
			  ,[MetodoPago]= NULL
			  ,[LugarExpedicion]= NULL
			  ,[NumCtaPago]= NULL
			  ,[Emisor]= NULL
			  ,[Receptor]= NULL
			  ,[UUID]= NULL
			  ,[FechaTimbrado]= NULL
			  ,[SelloCFD]= NULL
			  ,[NoCertificadoSAT]= NULL
			  ,[SelloSAT]= NULL
			  ,[Tipo]= NULL
			  ,[FechaRecepcion]= NULL
			  ,[IdSubcontratista]= NULL
			  ,[IdMoneda]= NULL
			  ,[IdContrato]= NULL
			  ,[XML]= NULL
			  ,[Activa]= NULL
			  ,[ArchivoXML]= NULL
			  ,[CreadoPor]= NULL
			  ,[CreadoEn]= NULL
			  ,[ModificadoPor]= NULL
			  ,[ModificadoEn]= NULL
			  ,[PDF]= NULL
			  ,[IdReceptor]= NULL
			  ,[IdentificadorSIPAC]= NULL
			  ,[NombreXML]= NULL
			  ,[IdEstudioPrecioTransfer]= NULL
			  ,[IdDocFacturacionSIPAC]= NULL
			  ,[ProcesadoSIPAC]= NULL
			  ,[ClaveFormaPago]= NULL
			  ,[IdEstatusEnviado]= NULL,
			  [ComprobanteXMLByte]=NULL
			WHERE [IdFactura]= @IdFactura

			---Eliminar Facturas Detalle 
			DELETE FROM  FI_CFDIConcepto
			WHERE IdFactura = @IdFactura

			DELETE FROM  FI_CFDIImpuesto
			WHERE IdFactura = @IdFactura
			

			--Actualizar estatus en Aceptación Factura 
			UPDATE MM_AceptacionFactura
			SET [FechaCargaXML]=NULL,
			[FechaEvaluacionXML]=NULL,

			[IdEstatusXML]	= 4	
			WHERE [IdAceptacionPedido]= @IdAceptacionPedido
			SELECT 'Factura XML Eliminado'
	END 
		
		 
				
  END;
