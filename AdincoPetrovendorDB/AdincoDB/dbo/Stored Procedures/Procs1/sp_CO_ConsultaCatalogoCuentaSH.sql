-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaCatalogoCuentaSH] 
	-- Add the parameters for the stored procedure here
	@IdCatalogoCuentasSH int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT        *
FROM            CO_CatalogoCuentaSH
WHERE        (IdCatalogoCuentasSH = @IdCatalogoCuentasSH)
END