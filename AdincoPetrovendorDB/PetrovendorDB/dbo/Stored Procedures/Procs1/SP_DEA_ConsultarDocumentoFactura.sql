-- =============================================
-- Author:		Daniel Cruz
-- Create date: 08-08-17
-- Description:	 
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_ConsultarDocumentoFactura]
	-- Add the parameters for the stored procedure here
--- SP_PR_MM_ConsultarDocumentoFactura 43,17
@IdAceptacionPedido int,
@IdDocumento int
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		DECLARE @ArchivoPDF NVARCHAR(MAX)  
		DECLARE @ArchivoXML NVARCHAR(MAX) 
		 
		  
		 IF @IdDocumento = 17 ---PDF
		 BEGIN 

		 SET @ArchivoPDF   = ( SELECT F.ArchivoPDF
											  FROM FI_Factura AS F
											  INNER JOIN MM_AceptacionFactura AS AF ON AF.IdFactura = F.IdFactura
		   									  WHERE AF.IdAceptacionPedido =@IdAceptacionPedido)

		   

		  SELECT (SELECT F.ComprobantePDFByte
				FROM FI_Factura AS F
				INNER JOIN MM_AceptacionFactura AS AF ON AF.IdFactura = F.IdFactura
		   		WHERE AF.IdAceptacionPedido =@IdAceptacionPedido),TD.NombreTipoDocumento+'.pdf','.pdf','', 'application/pdf'
		  FROM S_TipoDocumento AS TD
		  WHERE TD.IdTipoDocumento = 17 ---> DOCUMENTO DE TIPO PDF DE S_TIPODOCUMENTO
		
		 END 

		 IF @IdDocumento = 18 ---XML
		 BEGIN 


		  SET @ArchivoXML   = (SELECT ISNULL(( SELECT XML
											  FROM FI_Factura AS F
											  INNER JOIN MM_AceptacionFactura AS AF ON AF.IdFactura = F.IdFactura
		   									  WHERE AF.IdAceptacionPedido = @IdAceptacionPedido),''))

		   SELECT  (SELECT F.ComprobanteXMLByte
					FROM FI_Factura AS F
					INNER JOIN MM_AceptacionFactura AS AF ON AF.IdFactura = F.IdFactura
		   			WHERE AF.IdAceptacionPedido =@IdAceptacionPedido) ,TD.NombreTipoDocumento+'.xml','.xml',@ArchivoXML,'text/xml'
		   FROM S_TipoDocumento AS TD
		   WHERE TD.IdTipoDocumento = 18 ---> DOCUMENTO DE TIPO XML DE S_TIPODOCUMENTO
		
		 END  
  END;
 
