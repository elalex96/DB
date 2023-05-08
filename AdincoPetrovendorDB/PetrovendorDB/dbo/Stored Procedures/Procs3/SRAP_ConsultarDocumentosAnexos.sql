CREATE PROCEDURE [dbo].[SRAP_ConsultarDocumentosAnexos]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT, 
	@IdSolicitudAceptacionPedido INT, 
	@Accion NVARCHAR(MAX), 
	@IdDocumento INT	
AS
	BEGIN
-- =============================================
-- Author:	Daniel AC
-- Create date: <18-06-2021>
-- Description:	Consultar detalle de los documentos 
-- =============================================
    SET NOCOUNT ON ;
    IF @Accion = 'TABLA'
        BEGIN

         /*TABLA DE DOCUMENTOS*/
		 SELECT  D.IdDocumento, D.NombreDocumento, D.IdDocumentoTabla 
         FROM  S_Documento_S3 D  
		 JOIN S_TipoDocumento TD
			ON D.IdTipoDocumento=TD.IdTipoDocumento
			AND TD.NombreTipoDocumento='Aceptacion Pedido'
         WHERE  D.IdDocumentoTabla=@IdSolicitudAceptacionPedido
		 AND D.Activo=1 
		

        END
    IF @Accion = 'DESCARGA'
        BEGIN

			/*CONSULTA EL DOCUMENTO EN LA TABLA DE DOCUMENTOS DE PETROVENDOR*/
	     SELECT  D.IdDocumento, D.NombreDocumento,D.Carpeta, D.Extension,
                        D.Identificador, d.Bucket AS Bucket, D.Mime, D.IdDocumentoTabla 
         FROM  S_Documento_S3 D 
         WHERE  D.IdDocumentoTabla=@IdSolicitudAceptacionPedido
		 AND D.IdDocumento=@IdDocumento
		 AND D.Activo=1             
     END
END