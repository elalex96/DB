-- =============================================
-- Author:		Alexander Gomez
-- Create date: 19/12/2018
-- Description:	Consulta de monedas
-- =============================================
CREATE PROCEDURE [dbo].[SP_MPY_Monedas]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		IdMoneda,
		TipoMonedaCorto
	FROM dbo.PV_TipoMoneda
	WHERE Eliminado = 1
END
