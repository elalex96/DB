-- =============================================
-- Author:		MG
-- Create date: 01-01-2014
-- Description:	Obtiene lista de servicios programados de acuerdo a los parametros enviados
-- =============================================
CREATE PROCEDURE [dbo].[spObtenProgramasServicios] 
	-- Add the parameters for the stored procedure here
	@p1 int = 0, 
	@p2 int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT @p1, @p2
END


