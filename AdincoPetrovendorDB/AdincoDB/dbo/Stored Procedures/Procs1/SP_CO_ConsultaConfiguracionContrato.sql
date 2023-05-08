-- Author:		<Stephany Vega>
-- Create date: <14/04/2020>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_CO_ConsultaConfiguracionContrato
-- Add the parameters for the stored procedure here
	@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		Sanciones,
		Definiciones,
		AltaProcesos,
		CatalogoActProc

	FROM CO_ConfiguracionContrato 
	WHERE IdContrato=@IdContrato
END