-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 27/Marzo/2017
-- Description:	Permite agregar RELACION OPERACION TAREA A un flujo de tareas
-- =============================================
CREATE PROCEDURE  [dbo].[SP_TA_AgregarRelacionOperacionTarea] 
	-- Add the parameters for the stored procedure here
		
	@IdOperacion int,
	@IdTarea int
	 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
	INSERT INTO TA_TareaOperacion(IdTarea,IdOperacion)
	VALUES(@IdTarea,@IdOperacion)


	SELECT @@IDENTITY 

END
