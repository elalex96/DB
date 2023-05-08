-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <16/10/2019>
-- Description:	<consultar conceptos de la factura XML>
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_DatosConceptosFacturaXML]
	-- Add the parameters for the stored procedure here
	@IdFactura INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		FC.Descripcion,
		FC.Cantidad,
		FC.ValorUnitario,
		FC.Importe
	FROM dbo.FI_CFDIConcepto AS FC
	WHERE FC.IdFactura = @IdFactura;

END
