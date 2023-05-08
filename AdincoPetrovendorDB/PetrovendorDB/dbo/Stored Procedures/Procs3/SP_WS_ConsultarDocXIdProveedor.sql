-- =============================================
-- Author:		DANIEL AC
-- Create date: 08/05/2018
-- Description:	CAMBIO DE REFERENCIA DE S_DOCUMENTO A S_DOCUMENTO_S3
-- =============================================
CREATE PROCEDURE [dbo].[SP_WS_ConsultarDocXIdProveedor]
@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT * FROM dbo.S_Documento_S3 WHERE IdProveedor = @IdProveedor

END