-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <18/05/2020>
-- Description:	<Consultar reportes para DEA>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_VerificacionContratoActual]
	-- Add the parameters for the stored procedure here
	@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--IF @IdContrato = 10038
	--BEGIN
	--    SELECT 'true'
	--END
	--ELSE
	--BEGIN
	    SELECT 'false'
	--END

END
