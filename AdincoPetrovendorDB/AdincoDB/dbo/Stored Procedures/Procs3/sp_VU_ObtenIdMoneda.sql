-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE sp_VU_ObtenIdMoneda 
	-- Add the parameters for the stored procedure here
	@moneda nvarchar(MAX)
AS
	DECLARE @ENCONTRADOS AS INT
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	SET NOCOUNT ON;

	SELECT @ENCONTRADOS = COUNT (*) FROM VU_MonedaXML 
	WHERE RTRIM (NombreMonedaXML) = @moneda  
	 
	IF (@ENCONTRADOS >0)
		SELECT IdMoneda AS ID, NombreMonedaXML AS MSG  FROM VU_MonedaXML
		WHERE   RTRIM (NombreMonedaXML) = @moneda
	ELSE
		BEGIN
			INSERT INTO [dbo].[VU_MonedaXML]
			   ([NombreMonedaXML]
			   ,[IdMoneda])
			VALUES
			   ( @moneda
			   ,1)
			SELECT @@IDENTITY AS ID , @moneda AS MSG 
		END

    -- Insert statements for procedure here
	
END
