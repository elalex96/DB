-- =============================================
-- Author:		Alexander Gomez
-- Create date: 08/11/2018
-- Description:	Validacion de ReferenceNumber
-- =============================================
CREATE PROCEDURE SP_MPY_ValidarReferenceNumber
	-- Add the parameters for the stored procedure here
	@ReferenceNumber VARCHAR(50),
	@PONumber VARCHAR(50),
	@RFCProveedor VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @SAPVENDORID VARCHAR(50) = (SELECT TOP 1 V.VendorIDSAP 
											FROM Adinco.dbo.CO_SAPVendor AS V 
												WHERE V.TaxID = @RFCProveedor);

	SELECT
		COUNT(PSES.IdPRESES)
	FROM Adinco.dbo.CO_SAPPRESES AS PSES
	WHERE PSES.SAPPONumber = @PONumber
		AND PSES.SAPSESNumber = @ReferenceNumber
		AND PSES.SAPVendorNumber = @SAPVENDORID and
		PSES.IdEstatus in( 1,2) --Solo validar vs pendientes y aprobadas

END

