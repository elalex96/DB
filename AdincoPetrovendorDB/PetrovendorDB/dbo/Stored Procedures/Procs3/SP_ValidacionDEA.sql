
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 10/08/2021
-- Description:	Validacion Operadora DEA
-- =============================================
CREATE PROCEDURE [dbo].[SP_ValidacionDEA] 
	-- Add the parameters for the stored procedure here
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @RFC_ACTUAL NVARCHAR(100) = (SELECT RFC FROM dbo.S_Proveedor WHERE IdProveedor = @IdProveedor);

	DECLARE @PROVEEDORDEA INT = (SELECT TOP 1 COUNT(RFC) FROM DEA_Proveedor WHERE RFC = @RFC_ACTUAL);

	IF @PROVEEDORDEA > 0
	BEGIN
		
		SELECT 'true'

	END
	ELSE
	BEGIN

		SELECT 'false'

	END

END
