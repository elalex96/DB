-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE TA_SP_InsertarCorreoReenviado
	@Para VARCHAR(500),
	@Asunto VARCHAR(250),
	@Mensaje TEXT,
	--@FechaProgramada DATETIME,
	@IdUsuario INT,
	@De VARCHAR(100),
	@IdCorreo INT,
	@IdIdentificacion NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

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
	    De
	)
	VALUES
	(   @IdNotificacion,         -- IdNotificacion - bigint
	    @Para,        -- Para - varchar(500)
	    @Asunto,        -- Asunto - varchar(250)
	    @Mensaje,        -- Mensaje - text
	    GETDATE(),--@FechaProgramada, -- FechaProgramadaEnvio - datetime
	    1,      -- Enviada - bit
	    NULL, -- FechaEnvio - datetime
	    3,--@IdUsuario,         -- CreadoPor - int
	    GETDATE(), -- CreadoEl - datetime
	    NULL,         -- ModificadoPor - int
	    NULL, -- ModificadoEl - datetime
	    @De         -- De - varchar(100)
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
	)


END
