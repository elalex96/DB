-- =============================================
-- Author:	DANIEL AC
-- Create date: 26/04/2018
-- Description:	CONSULTAR RPPC
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarDocumentoRPPC_S3]
@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT IdDocumento FROM dbo.S_Documento_S3 WHERE IdTipoDocumento = 23 AND IdProveedor = @IdProveedor AND Activo = 1

END