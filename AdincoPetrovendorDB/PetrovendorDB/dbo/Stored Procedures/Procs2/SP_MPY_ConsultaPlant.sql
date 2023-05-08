-- =============================================
-- Author:		Alexander Gomez
-- Create date: 09/11/2018
-- Description:	Consulta de las plants del proveedir
-- =============================================
CREATE procedure [dbo].[SP_MPY_ConsultaPlant]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		CO.RazonSocial AS NombreContratista,
		PL.Planta
	FROM Adinco.dbo.CO_SAPPO AS PO
	 JOIN Adinco.dbo.CO_SAPContratista_Planta AS PL ON PO.Plant = PL.Planta
	 JOIN Adinco.dbo.CO_Contratista AS CO ON CO.IdContratista = PL.IdContratista
	GROUP BY CO.RazonSocial,
		PL.Planta

END
