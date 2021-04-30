-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <28/04/2021>
-- Description:	<Envio y consulta de verificacion de correo enviado>
-- =============================================
CREATE PROCEDURE [dbo].[SP_VerificacionCorreoSHELL] 
	-- Add the parameters for the stored procedure here
	@IdUsuario INT,
	@IdIdentificador INT,
	@Pantalla NVARCHAR(1000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--SE OBTIENE EL IDVERIFICACION CON LOS DATOS MANDADOS
	DECLARE @IDVERIFICACION INT = (SELECT IdVerificacionCorreo FROM dbo.CO_VerificacionCorreo WHERE IdUsuario = @IdUsuario AND IdIdentificadorCorreo = @IdIdentificador AND Pantalla = @Pantalla);
	DECLARE @DESTINATARIO NVARCHAR(100) = (SELECT Para FROM dbo.S_Notificacion WHERE IdNotificacion = @IdIdentificador);
	DECLARE @MaxNotificacion INT = 0;
	DECLARE @NOMBREUSUARIO NVARCHAR(100) = (SELECT Nombre FROM dbo.AP_Usuario WHERE UsuarioID = @IdUsuario);
	DECLARE @CORREOUSUARIO NVARCHAR(100) = (SELECT Usuario FROM dbo.AP_Usuario WHERE UsuarioID = @IdUsuario);

	--SE VERIFICA QUE EL USUARIO QUE SE LOGUEO SEA EL QUE TIENE QUE VER LA NOTIFICACION
	IF @DESTINATARIO = @CORREOUSUARIO
	BEGIN

		IF ISNULL(@IDVERIFICACION,0) = 0
		BEGIN
				--SI NO EXISTE SE ENVIA EL CORREO DE NOTIFICACION DE VISUALIZACION DE CORREO Y SE INSERTA PARA GUARDAR LA VISUALIZACION
			INSERT INTO dbo.CO_VerificacionCorreo(IdUsuario,IdIdentificadorCorreo,Pantalla,FechaVisto) VALUES (@IdUsuario,@IdIdentificador,@Pantalla,GETDATE());

			SELECT
				@MaxNotificacion = MAX(IdNotificacion)
			FROM
				S_Notificacion

			--SE ENVIA LA NOTIFICACION
			INSERT INTO S_Notificacion
			(
				IdNotificacion,
				Para,
				Asunto,
				Mensaje,
				FechaProgramadaEnvio,
				Enviada,
				CreadoPor,
				CreadoEl,
				De,
				EN_MsjEnviado
			)
			VALUES
			(
				(@MaxNotificacion + 1),
				'joshua.gamboa@shell.com',
				'Confirmacion de lectura de notificacion semanal Adinco Compliance',
				'El usuario ' + @NOMBREUSUARIO + '(' + @CORREOUSUARIO + ') ya leyo la notificación semanal de Adinco Compliance',
				GETDATE(),
				0,
				1,
				GETDATE(),
				'notificaciones@adinco.mx',
				0
			);

		END

	END
	

END
