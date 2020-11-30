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
								VALUES ((SELECT MAX(IdNotificacion)	+	1 FROM S_Notificacion ),@Para,@Asunto,@Mensaje,GETDATE(),@Enviada,GETDATE(),@idUsuario,GETDATE(),@De ,@EN_MsjEnviado)

SELECT '' AS error

	END;
