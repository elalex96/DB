CREATE PROCEDURE [dbo].[SP_ENT_EnviarCorreoAlerta]
	@Para VARCHAR(500),
	@Asunto VARCHAR(250),
	@Mensaje VARCHAR(MAX),
	@De VARCHAR(100)
AS
BEGIN

	 DECLARE @IdNotificacion BIGINT
	 SET @IdNotificacion = (SELECT MAX(IdNotificacion) FROM Adinco.dbo.S_Notificacion) + 1;
	 
	 INSERT INTO Adinco.dbo.S_Notificacion
		(
			IdNotificacion,
			Para,
			Asunto,
			Mensaje,
			FechaProgramadaEnvio,
			Enviada,
			FechaEnvio,
			CreadoPor,
			CreadoEl,
			ModificadoPor,
			ModificadoEl,
			De
		)
		VALUES
		(   @IdNotificacion,				-- IdNotificacion - bigint
			@Para,							-- Para - varchar(500)
			@Asunto,						-- Asunto - varchar(250)
			@Mensaje,						-- Mensaje - text
			dateadd(minute, 1, getdate()),	--@FechaProgramada, -- FechaProgramadaEnvio - datetime
			0,								-- Enviada - bit
			dateadd(minute, 1, getdate()),	-- FechaEnvio - datetime
			1,								--@IdUsuario,         -- CreadoPor - int
			GETDATE(),						-- CreadoEl - datetime
			NULL,							-- ModificadoPor - int
			NULL,							-- ModificadoEl - datetime
			@De								-- De - varchar(100)
		)

		
	SELECT  @IdNotificacion
	  
END

