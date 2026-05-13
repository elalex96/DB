-- =============================================
-- Author:		Alexander Gomez
-- Create date: 29-01-2019
-- Description:	Se valida el contrato para mostrar las opciones de murphy
-- =============================================
-- =============================================
-- Author:		DAC
-- Modified date: <07/03/2023>
-- Description:	AGREGADO DE OPTIMIZACÓN
-- =============================================
CREATE PROCEDURE [dbo].[SP_MPY_ValidacionOpcionesMPY] 
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
	FROM Adinco.dbo.CO_Contratista AS CO (NOLOCK)
		JOIN Adinco.dbo.CO_SAPContratista_Planta AS CP (NOLOCK)
		ON CO.IdContratista = CP.IdContratista
	WHERE CO.RFC = @RFCContratista

END
