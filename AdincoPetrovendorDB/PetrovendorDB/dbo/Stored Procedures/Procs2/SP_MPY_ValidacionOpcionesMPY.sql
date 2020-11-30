-- =============================================
-- Author:		Alexander Gomez
-- Create date: 29-01-2019
-- Description:	Se valida el contrato para mostrar las opciones de murphy
-- =============================================
CREATE PROCEDURE SP_MPY_ValidacionOpcionesMPY 
	-- Add the parameters for the stored procedure here
	@RFCContratista NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		ISNULL(COUNT(CP.Planta),0)
	FROM Adinco.dbo.CO_Contratista AS CO
		JOIN Adinco.dbo.CO_SAPContratista_Planta AS CP ON CP.IdContratista = CO.IdContratista
	WHERE CO.RFC = @RFCContratista

END
