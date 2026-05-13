
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 22-05-17
-- Description:	Regresa la información del asignador de una tarea
				
-- =============================================
	CREATE  PROCEDURE [dbo].[SP_MPY_TA_ConsultarAsignador] 
	-- Add the parameters for the stored procedure here
	 @IdAsignador int 
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	 SELECT IdUsuario, Nombre, Correo
	 FROM S_Usuario
	 WHERE IdUsuario = @IdAsignador

END


