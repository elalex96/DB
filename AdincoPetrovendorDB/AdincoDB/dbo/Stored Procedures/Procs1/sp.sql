-- =============================================
-- Author:		Miguel Gomez
-- Create date: -
-- Description:	1-1-2017
-- =============================================
CREATE PROCEDURE sp 
	-- Add the parameters for the stored procedure here
	@IdProgramaActividad int = 0, 
	@p2 int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT @IdProgramaActividad, @p2
END
