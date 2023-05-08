-- =============================================
-- Author: Pedro Acuña
-- Create date: 28/04/2018
-- Description: se inserta en la tabla para que luego el servicio del correo los envie
-- =============================================

CREATE PROCEDURE [dbo].[SP_MA_WSEnviarCorreo]
	( @Para VARCHAR(500) ,
	  @Asunto VARCHAR(250) ,
	  @Mensaje TEXT ,
	  @IdUsuario INT ,
	  @De VARCHAR(100) ,
	  @IdCorreo INT ,
	  @IdIdentificacion NVARCHAR(MAX)
)
AS
	BEGIN
		SET DATEFORMAT DMY
		DECLARE @IdNotificacion BIGINT

		SET @IdNotificacion =
		( SELECT	MAX ( IdNotificacion ) FROM Adinco.dbo.S_Notificacion ) + 1

		INSERT INTO Adinco.dbo.S_Notificacion
			( IdNotificacion, Para, Asunto, Mensaje, FechaProgramadaEnvio, Enviada, FechaEnvio, CreadoPor, CreadoEl ,
			  ModificadoPor , ModificadoEl, De
		)
		VALUES
			( @IdNotificacion , -- IdNotificacion - bigint
			  @Para ,			-- Para - varchar(500)
		RTRIM(RTRIM(REPLACE(REPLACE(@Asunto,CHAR(10), ' '),CHAR(13), ' '))),			-- Asunto - varchar(250)
			  @Mensaje ,		-- Mensaje - text
			  GETDATE () ,		-- FechaProgramadaEnvio - datetime
			  0 ,				-- Enviada - bit
			  NULL ,			-- FechaEnvio - datetime
			  @IdUsuario ,		-- CreadoPor - int
			  GETDATE () ,		-- CreadoEl - datetime
			  NULL ,			-- ModificadoPor - int
			  NULL ,			-- ModificadoEl - datetime
			  @De				-- De - varchar(100)
		)

		INSERT INTO Adinco.dbo.MA_EnvioCorreo
			( IdEnvioAdinco, IdCorreo, IdIdentificacion, EnviadoPor, EnviadoEl )
		VALUES
			( @IdNotificacion ,		-- IdEnvioAdinco - int
			  @IdCorreo ,			-- IdCorreo - int
			  @IdIdentificacion ,	-- IdIdentificacion - nvarchar(max)
			  @IdUsuario ,			-- EnviadoPor - int
			  GETDATE ()			-- EnviadoEl - smalldatetime
		)
	END
--------------------------------------------------------------------------------------------------------------
