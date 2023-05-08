-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <05/06/2021>
-- Description:	<Consulta de los terminos y condiciones>
-- =============================================
create PROCEDURE [dbo].[SP_AD_TerminosCondicionesProveedor]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		IdTerminosYCondiciones,
		Nombre
	FROM dbo.TC_TerminosYCondicionesDocV2 
	WHERE IdProveedor = @IdProveedor
		AND IsActivo = 1
END
