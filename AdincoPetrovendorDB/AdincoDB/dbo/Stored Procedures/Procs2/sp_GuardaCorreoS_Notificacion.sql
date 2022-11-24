
-- =============================================
-- Author:		Reyna Olvera
-- Create date:03032020
-- Description:	Guarda correo 
-- =============================================
CREATE PROCEDURE [dbo].[sp_GuardaCorreoS_Notificacion]
	@Para VARCHAR(500),
	@Asunto VARCHAR(500),
	@Mensaje TEXT,
	@Enviada BIT,
	@De  VARCHAR(100),
	@EN_MsjEnviado BIT,
    @idContrato INT,
    @idUsuario INT
AS
BEGIN

    SET NOCOUNT ON;
 
	IF(@idContrato = 0)
	 BEGIN
		SELECT @idContrato = IdContrato FROM CO_Contrato WHERE NumeroContrato='CNH-R01-L03-A00/2015'
	 END

	IF(@idUsuario = 0)
	 BEGIN
		SET @idUsuario = 1; -- administrador@smps-adinco.com
	 END

	INSERT INTO S_Notificacion	(IdNotificacion,
								Para,
								Asunto,
								Mensaje,
								FechaProgramadaEnvio,
								Enviada,
								FechaEnvio,
								CreadoPor,
								CreadoEl,
								De,
								EN_MsjEnviado)
								VALUES ((SELECT MAX(IdNotificacion)	+	1 FROM S_Notificacion ),@Para,@Asunto,@Mensaje,GETDATE(),@Enviada,
								CASE @Enviada
								WHEN 1
								THEN
									GETDATE()
									ELSE NULL
								END,
								@idUsuario,GETDATE(),@De ,@EN_MsjEnviado)

	SELECT '[Registrado correctamente] en S_Notificacion '+  CASE @Enviada WHEN 1 THEN 'y enviado correctamente' ELSE 'se enviará en breve' END AS error

	END;


