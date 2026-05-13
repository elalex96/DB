-- =============================================
-- Author:		Daniel AC
-- Create date: 08-03-17
-- Description:	SP que actualiza el estatus Visto de una Tarea indicada
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_UpdateVistoTarea]
	-- Add the parameters for the stored procedure here
	@IdUsuario int,
	@IdTarea int,
	@Estatus bit

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	---validar si existen tareas nuevas 
	UPDATE TaTarea 
	SET Visto=@Estatus
	WHERE IdTarea=@IdTarea


	SELECT 'Estatus cambiado correctamente' AS Response
END  
