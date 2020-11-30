-- =============================================
-- Author:		Alexander Gomez
-- Create date: 06/11/2018
-- Description:	Consultar el VendorAccountGroup de un proveedor logueado
-- =============================================
CREATE procedure [dbo].[SP_MPY_VendorAccountGroup]
	-- Add the parameters for the stored procedure here
	@PONumber NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		V.VendorAccountGroup
	FROM Adinco.dbo.CO_SAPVendor AS V
	WHERE V.TaxID = @PONumber
END
