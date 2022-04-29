USE [Petrovendor]
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_DEA_ConsultarDocumentoFactura'
)
    DROP PROCEDURE SP_DEA_ConsultarDocumentoFactura;
GO
/****** Object:  StoredProcedure [dbo].[SP_DEA_ConsultarDocumentoFactura]    Script Date: 27/04/2022 09:57:19 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 27-04-2022
-- Description:	Issue #1739  Optimizacion pantallas se ordena y revisa joins 
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_ConsultarDocumentoFactura]
	-- Add the parameters for the stored procedure here
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
							JOIN MM_AceptacionFactura AS AF ON AF.IdFactura = F.IdFactura
		   					WHERE AF.IdAceptacionPedido =@IdAceptacionPedido)

		   

		  SELECT (SELECT F.ComprobantePDFByte
				FROM FI_Factura AS F
				INNER JOIN MM_AceptacionFactura AS AF ON AF.IdFactura = F.IdFactura
		   		WHERE AF.IdAceptacionPedido =@IdAceptacionPedido),
				TD.NombreTipoDocumento+'.pdf',
				'.pdf','', 
				'application/pdf',
				ISNULL(@ArchivoPDF, '')  AS ArchivoPDF --> HISTORICO YA QUE LA FACTURA ANTES SE GUARDABA COMO STRING
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
		   			WHERE AF.IdAceptacionPedido =@IdAceptacionPedido) ,
					TD.NombreTipoDocumento+'.xml',
					'.xml',
					@ArchivoXML,
					'text/xml',
					'' AS ArchivoPDF --> HISTORICO YA QUE LA FACTURA PDF ANTES SE GUARDABA COMO STRING 
		   FROM S_TipoDocumento AS TD
		   WHERE TD.IdTipoDocumento = 18 ---> DOCUMENTO DE TIPO XML DE S_TIPODOCUMENTO
		
		 END  
  END;
 
