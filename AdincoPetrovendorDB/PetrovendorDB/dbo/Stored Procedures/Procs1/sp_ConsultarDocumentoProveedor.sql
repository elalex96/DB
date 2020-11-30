---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <02/07/2017>
-- Description:	<Consulta la infomacion del documento>
-- DANIEL AC 08/05/2018 CAMBIO DE REFERENCIAS DE S_DOCUMENTO A S_DOCUMENTO_S3
-- =============================================

CREATE PROCEDURE [dbo].[sp_ConsultarDocumentoProveedor]
	-- Add the parameters for the stored procedure here
	@IdDoc INT
AS
	BEGIN
		SELECT	doc.Carpeta, doc.Identificador, doc.Mime, doc.NombreDocumento
		FROM	dbo.S_Documento_S3 doc
		WHERE	doc.IdDocumento = @IdDoc
	END
