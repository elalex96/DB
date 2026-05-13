-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <16/10/2019>
-- Description:	<consultar los impuestos de una factura xml>
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_DatosImpuestosFactura]
	-- Add the parameters for the stored procedure here
	@IdFactura INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		F.SubTotal,
		IM.Impuesto,
		IM.Tasa,
		IM.Importe
	FROM dbo.FI_CFDIImpuesto AS IM
		LEFT JOIN dbo.FI_Factura AS F ON F.IdFactura = IM.IdFactura
	WHERE IM.IdFactura = @IdFactura
	GROUP BY F.SubTotal,
             IM.Impuesto,
             IM.Tasa,
             IM.Importe;
END
