-- =============================================
-- Author:		Alexander Gomez
-- Create date: 30/10/2018
-- Description:	Guardar PRE-SES
-- =============================================
CREATE PROCEDURE [dbo].[SP_MPY_GuardarPRESES]
	-- Add the parameters for the stored procedure here
	@PONumber VARCHAR(20),
	@VendorNumber VARCHAR(20),
	@IdUsuario INT,
	@SESNumber VARCHAR(50),
	@MontoTotal FLOAT,
	@Plant VARCHAR(10) = 'MX01',
	@SES NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @SAPIDVENDORNUMBER VARCHAR(20) = (SELECT TOP 1
													VendorIDSAP
												FROM Adinco.dbo.CO_SAPVendor
												WHERE TaxID = @VendorNumber);

    -- Insert statements for procedure here
	INSERT INTO Adinco.dbo.CO_SAPPRESES
	(
	    SAPPONumber,
	    SAPVendorNumber,
	    CreadoPor,
	    CreadoEl,
	    IdEstatus,
		SAPSESNumber,
		MontoTotalPrefactura,
		Plant,
		SESN
	)
	VALUES
	(   @PONumber,  -- SAPPONumber - varchar(20)
	    @SAPIDVENDORNUMBER,  -- SAPVendorNumber - varchar(20)
	    @IdUsuario,   -- CreadoPor - int
	    GETDATE(), -- CreadoEl - nchar(10)
	    1,   -- IdEstatus - int
		@SESNumber,
		@MontoTotal,
		'',
		@SES
	    )

		SELECT @@IDENTITY

END