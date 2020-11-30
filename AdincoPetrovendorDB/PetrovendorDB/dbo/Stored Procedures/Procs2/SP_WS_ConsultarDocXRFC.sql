-- =============================================
-- Author:		DANIEL AC
-- UPDATE date: 08/05/2018
-- Description:	CAMBIO DE REFERENCIA DE S_DOCUMENTO A S_DOCUMENTO_S3
-- =============================================
CREATE PROCEDURE [dbo].[SP_WS_ConsultarDocXRFC]
@RFC VARCHAR(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT D.* FROM S_Documento_S3 D
	INNER JOIN S_Proveedor P
	ON D.IdProveedor = P.IdProveedor 
	WHERE P.RFC = @RFC

END