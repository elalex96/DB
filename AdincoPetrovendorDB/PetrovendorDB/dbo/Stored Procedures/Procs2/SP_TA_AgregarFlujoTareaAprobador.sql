-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 24/Marzo/2017
-- Description:	Permite agregar un aprobador para hacer relacion con un flujo de tareas
-- =============================================
CREATE  PROCEDURE  [dbo].[SP_TA_AgregarFlujoTareaAprobador] 
	-- Add the parameters for the stored procedure here
		
	@IdFlujoTarea int,
	@IdUsuario int, 
	@NoSecuencia int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
	INSERT INTO TA_Aprobador(IdFlujoTarea,IdUsuario,NoSecuencia)
	VALUES(@IdFlujoTarea,@IdUsuario,@NoSecuencia)

	SELECT 'Aprobador Agregado'

END

