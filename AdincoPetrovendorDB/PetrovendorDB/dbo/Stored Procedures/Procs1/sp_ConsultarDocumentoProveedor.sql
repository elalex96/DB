-- =============================================
-- Author:	Daniel AC
-- Create date: 04/01/2022
-- Description: Se agrega columna de Bucket
-- =============================================

CREATE PROCEDURE [dbo].[sp_ConsultarDocumentoProveedor]
	-- Add the parameters for the stored procedure here
	@IdDoc INT
AS
	BEGIN
		SELECT	doc.Carpeta, doc.Identificador, doc.Mime, doc.NombreDocumento, doc.Bucket
		FROM	dbo.S_Documento_S3 doc
		WHERE	doc.IdDocumento = @IdDoc
	END
