CREATE PROCEDURE [dbo].[TA_SP_EnviarCorreo]
	@Para VARCHAR(500),
	@Asunto VARCHAR(250),
	@Mensaje TEXT,
	--@FechaProgramada DATETIME,
	@IdUsuario INT,
	@De VARCHAR(100),
	@IdCorreo INT,
	@IdIdentificacion NVARCHAR(4000),
	@CCO VARCHAR(2000) = ''

AS
BEGIN
	
	DECLARE @IdNotificacion BIGINT

	SET @IdNotificacion = (SELECT MAX(IdNotificacion) FROM Adinco.dbo.S_Notificacion) + 1

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
	    De,
		CCO
	)
	VALUES
	(   @IdNotificacion,         -- IdNotificacion - bigint
	    @Para,        -- Para - varchar(500)
	    @Asunto,        -- Asunto - varchar(250)
	    @Mensaje,        -- Mensaje - text
	    GETDATE(),--@FechaProgramada, -- FechaProgramadaEnvio - datetime
	    0,      -- Enviada - bit
	    NULL, -- FechaEnvio - datetime
	    1,--@IdUsuario,         -- CreadoPor - int
	    GETDATE(), -- CreadoEl - datetime
	    NULL,         -- ModificadoPor - int
	    NULL, -- ModificadoEl - datetime
	    @De,         -- De - varchar(100)
		@CCO
	)

	INSERT INTO dbo.TA_EnvioCorreo
	(
	    IdEnvioAdinco,
	    IdCorreo,
	    IdIdentificacion,
		EnviadoPor,
		EnviadoEl
	)
	VALUES
	(   @IdNotificacion, -- IdEnvioAdinco - int
	    @IdCorreo, -- IdCorreo - int
	    @IdIdentificacion,  -- IdIdentificacion - int
		@IdUsuario,
		GETDATE()
	);

	--SE VERIFICA QUE SI ESXISTA EL REGISTRO QUE SE ACABA DE INCERTAR
	SET @IdNotificacion = ISNULL((SELECT IdNotificacion FROM Adinco.dbo.S_Notificacion WHERE IdNotificacion = @IdNotificacion),0);

	--SE VALIDA Y SE REGRESA EL RESULTADO
	IF @IdNotificacion > 0
	BEGIN

		SELECT 'true'

	END
	ELSE
	BEGIN
		
		SELECT 'false'

	END;


END

