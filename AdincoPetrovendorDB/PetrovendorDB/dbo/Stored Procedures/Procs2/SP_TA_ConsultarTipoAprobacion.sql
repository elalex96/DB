
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 23-03-17
-- Description:	Regresa los tipos de aprobación de una tarea
			
-- =============================================
	CREATE  PROCEDURE [dbo].[SP_TA_ConsultarTipoAprobacion] 
	-- Add the parameters for the stored procedure here
	 
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SELECT TF.IdTipoFlujoTarea, TF.Nombre
	 FROM TA_TipoFlujoTarea AS TF

END



