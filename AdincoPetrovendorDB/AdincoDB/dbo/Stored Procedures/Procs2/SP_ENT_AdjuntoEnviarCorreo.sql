CREATE PROCEDURE [dbo].[SP_ENT_AdjuntoEnviarCorreo]
	@IdNotificacion INT,
	@NombreArchivo NVARCHAR(MAX),
	@Adjunto IMAGE
AS
BEGIN

	DECLARE @IdNotificacionAdjunto BIGINT;

	SET @IdNotificacionAdjunto = (ISNULL((SELECT MAX(IdNotificacionAdjunto) FROM Adinco.dbo.S_NotificacionAdjunto),1000) + 1);


	INSERT INTO Adinco.dbo.S_NotificacionAdjunto
	(
		     IdNotificacionAdjunto,
		     IdNotificacion,
		     NombreArchivo,
		     Adjunto,
		     CreadoPor,
		     CreadoEl
	)
	VALUES
	(   
		@IdNotificacionAdjunto,        -- IdNotificacionAdjunto - bigint
		@IdNotificacion,        -- IdNotificacion - bigint
		ISNULL(@NombreArchivo,''),       -- NombreArchivo - varchar(250)
		@Adjunto,     -- Adjunto - image
		1,        -- CreadoPor - int
		GETDATE() -- CreadoEl - datetime
	)
	
	SELECT @IdNotificacionAdjunto
END

