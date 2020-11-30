
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 26/07/17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ViewPdfFactura] 
	-- Add the parameters for the stored procedure here
	@IdFactura INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

     -- Insert statements for procedure here
	SELECT F.IdFactura, Documento=D.DocumentoByte FROM FI_Factura F
	JOIN FI_DOCUMENTO D ON F.IdFactura = D.IdFactura AND D.IdTipoDocumento = 1
	WHERE F.IdFactura = @IdFactura
	--SELECT IdTransferencia, PDF
	--FROM FI_Transfer
	--WHERE IdTransferencia = 324
	
END

