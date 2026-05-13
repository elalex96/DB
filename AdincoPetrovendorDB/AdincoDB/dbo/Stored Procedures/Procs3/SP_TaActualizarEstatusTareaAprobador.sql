-- =============================================
-- Author:		Manuel Cruz
-- Create date: 04-01-17
-- Description:	Actualiza la tabla TareaAprobador ingresando la fecha en que evaluó la tarea
				--e ingresa el comentario que resibe como parámetro, de acuerdo al id del usuario
				--y al id de la tarea.
-- =============================================
CREATE PROCEDURE [dbo].[SP_TaActualizarEstatusTareaAprobador] 
	-- Add the parameters for the stored procedure here
	@IdTarea INT,
	@IdEstatus INT,
	@IdUsuario INT,
	@Comentario NVARCHAR(MAX)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.TaTareaAprobador
	SET IdEstatus = @IdEstatus, Fecha = GETDATE(), Comentario = @Comentario
	WHERE IdTarea = @IdTarea AND IdUsuario = @IdUsuario

	EXEC SP_TaObtenerEstatus @IdTarea

END


