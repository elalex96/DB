-- =============================================
-- Author:		DANIEL AC
-- Create date: 26/054/2016
-- Description:	VALIDACION SI EXISTE EL DOCUMENTO
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarDocumentosCargados_S3] 
@IdProveedor int,
@IdTipoDocumento int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
		SELECT IdDocumento
		FROM dbo.S_Documento_S3 doc
		WHERE doc.IdProveedor = @IdProveedor
				AND doc.IdTipoDocumento = @IdTipoDocumento
				AND doc.Activo = 1
				
		
END