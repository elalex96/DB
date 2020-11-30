
-- =============================================
-- Author:		Josue Glez
-- Create date: 10-07-17
-- Description:	Regresa los aprobadores de un flujo de tarea
				
-- =============================================
	create  PROCEDURE [dbo].[SP_TA_EliminarFlujo] 
	-- Add the parameters for the stored procedure here
	 @IdFlujoTarea int 
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 update TA_FlujoTarea set eliminado = 'true'
	 WHERE IdFlujoTarea = @IdFlujoTarea;

END



