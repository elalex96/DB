create procedure [dbo].[SP_MPY_Vendors] 
	-- Add the parameters for the stored procedure here
	@RFCProveedor NVARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		V.VendorIDSAP,
		V.VendorName
	FROM Adinco.dbo.CO_SAPVendor AS V
	WHERE V.TaxID != @RFCProveedor
END
