-- =============================================
-- Author:		Manuel Cruz
-- Create date: 29-12-16
-- Description:	SP que recibe los parametros de la web del usuario asignador de cada tarea para cancelar la tarea
				-- actualizando la tabla TareaAprobador cambiando su estatus a cancelado por asignador asi mismo en la
				-- tabla general de la Tarea, tambien actualiza el campo Activo de la tarea a False, y la opcion de ingresar
				-- un comentario del motivo de cancelación a la tabla de ComentarioCancelacionTarea de acuerdo al IdUsuario e IdTarea
-- =============================================
CREATE PROCEDURE [dbo].[sp_CancelarTarea] 

@IdTarea int,
@Comentario varchar(max),
@IdUsuario int

AS
BEGIN

	UPDATE TareaAprobador
	SET IdEstatus = 7
	WHERE IdTarea = @IdTarea AND IdEstatus =1

	UPDATE Tarea
	SET IdEstatus = 7, Activo = 0 
	WHERE IdTarea = @IdTarea

	INSERT INTO ComentarioCancelacionTarea(IdUsuario, IdTarea, Comentario)
	VALUES(@IdUsuario, @IdTarea, @Comentario)

END

