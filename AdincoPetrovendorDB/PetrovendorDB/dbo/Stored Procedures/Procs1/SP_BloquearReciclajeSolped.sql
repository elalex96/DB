-- =============================================
-- Author:		Alexander G
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_BloquearReciclajeSolped]
	-- Add the parameters for the stored procedure here
	@IdSolPed int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM TA_RecicajeSolPed WHERE IdSolPedAnterior = @IdSolPed
END

