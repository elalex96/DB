-- =============================================
-- Author:		Alexander Gomez
-- Create date: 03/05/2021
-- Description:	Validacion de area existente en contrato
-- =============================================
CREATE PROCEDURE [dbo].[SP_CAT_ValidarAreaContrato]
	-- Add the parameters for the stored procedure here
	@NombreArea NVARCHAR(MAX),
	@idContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @EXISTE_REGISTRO INT = (SELECT COUNT(1) 
									FROM EN_Area 
									WHERE NombreArea = @NombreArea 
									AND idContrato = @idContrato);

	IF @EXISTE_REGISTRO > 0
	BEGIN 
		SELECT 1
	END
	ELSE
	BEGIN
		SELECT 0
	END

END
