-- =============================================
-- Author:		Alexander Gomez
-- Create date: 13/11/2018
-- Description:	Consulta del total de una po
-- =============================================
CREATE procedure [dbo].[SP_MPY_TotalPO]
	-- Add the parameters for the stored procedure here
	@PONumber VARCHAR(50),
	@RFCProveedor VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		SUM(PO.Total)
	FROM Adinco.dbo.CO_SAPPO AS PO
		LEFT JOIN Adinco.dbo.CO_SAPMaterial AS SM ON SM.SAPMaterialNumber = PO.SAPMaterialNumber
		LEFT JOIN Adinco.dbo.CO_SAPVendor AS SV ON SV.VendorIDSAP = PO.SAPVendorNumber
	WHERE PO.SAPPONumber = @PONumber
	 AND SV.TaxID = @RFCProveedor
	 GROUP BY PO.SAPPONumber
END
