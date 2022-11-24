CREATE PROCEDURE [dbo].[SP_TaInsertarDetalleNotificarTarea] 
	@IdTarea int,
	@IdUsuario int,
	@FechaNotificacion nvarchar(max),
	@EstatusEnviado bit,
	@TipoNotificacion int
AS
BEGIN
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 12-01-17
-- Description:	SP inserta o actualiza en la tabla de FechasNotificaciones de acuerdo a los parámetros recibidos
-- =============================================
	SET NOCOUNT ON;
	DECLARE @no_registro int =0;

-- ASIGNACION DE VARIABLES CON EL MISMO SELECT, USAR COUNT(1) EN LUGAR DE COUNT(*)
    --SET @no_registro = (SELECT COUNT (*)
     SELECT @no_registro = COUNT (1)
	FROM TaFechasNotificacion
	WHERE IdTarea = @IdTarea 
	AND IdUsuario = @IdUsuario 
	AND FechaNotificacion = @FechaNotificacion 
	AND TipoNotificacion = @TipoNotificacion

	 IF @EstatusEnviado = 1
		BEGIN 
		   IF @no_registro > 0 
				BEGIN 
					UPDATE TaFechasNotificacion SET FechaEnvio = GETDATE()
					WHERE IdTarea = @IdTarea 
					AND IdUsuario = @IdUsuario 
					AND FechaNotificacion = @FechaNotificacion 
					AND TipoNotificacion = @TipoNotificacion
				END 
		    ELSE 
				BEGIN 
					INSERT INTO TaFechasNotificacion(IdTarea,IdUsuario,FechaNotificacion,FechaEnvio,TipoNotificacion)
					 VALUES(@IdTarea,@IdUsuario,@FechaNotificacion,GETDATE(),@TipoNotificacion)
				END
		END 
	 ELSE 
		 BEGIN 
			  IF @no_registro = 0 
				BEGIN
					INSERT INTO TaFechasNotificacion(IdTarea,IdUsuario,FechaNotificacion,TipoNotificacion)
					 VALUES(@IdTarea,@IdUsuario,@FechaNotificacion,@TipoNotificacion)
				END 
		END 
END
