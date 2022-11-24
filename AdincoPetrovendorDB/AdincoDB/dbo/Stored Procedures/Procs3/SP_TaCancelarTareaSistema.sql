-- =============================================
-- Author:		Manuel Cruz
-- Create date: 29-12-16
-- Description:	SP que ejecuta el servicio de windows para actualizar el estatus de la tabla Tarea y Tarea Aprobador
				-- al Estatus de vencido y el campo de Activo a false para deshabilitar la tarea
				-- tambien inserta en la tabla ComentarioCancelacionTarea un comentario y usuario por defaul del sistema
-- =============================================
CREATE PROCEDURE [dbo].[SP_TaCancelarTareaSistema] 

@IdTarea int

AS
BEGIN
	
	
	UPDATE TaTareaAprobador
	SET IdEstatus = 6
	WHERE IdTarea = @IdTarea AND IdEstatus = 1

	UPDATE TaTarea
	SET IdEstatus = 6, Activo = 0 
	WHERE IdTarea = @IdTarea

	INSERT INTO TaComentarioCancelacionTarea(IdUsuario,IdTarea,Comentario)
	VALUES(10, @IdTarea, 'Cancelado por sistema')

END


