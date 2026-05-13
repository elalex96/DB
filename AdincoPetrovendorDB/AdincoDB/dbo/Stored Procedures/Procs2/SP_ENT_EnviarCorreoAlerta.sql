USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_ENT_EnviarCorreoAlerta'
)
    DROP PROCEDURE SP_ENT_EnviarCorreoAlerta;   
	
	GO
/****** Object:  StoredProcedure [dbo].[SP_ENT_EnviarCorreoAlerta]    Script Date: 19/06/2024 11:20:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ENT_EnviarCorreoAlerta]
	@Para VARCHAR(500),
	@Asunto VARCHAR(250),
	@Mensaje VARCHAR(MAX),
	@De VARCHAR(100),
	@CCO VARCHAR(100) = NULL,
	@FechaProgramadaEnvio DATETIME = NULL
AS
BEGIN

	 DECLARE @IdNotificacion BIGINT
	 SET @IdNotificacion = (SELECT MAX(IdNotificacion) FROM Adinco.dbo.S_Notificacion) + 1;
	 
	 IF @FechaProgramadaEnvio IS NULL 
	 BEGIN 
		SET @FechaProgramadaEnvio = DATEADD(MINUTE, 1, GETDATE())
	 END 
	 ELSE 
	 BEGIN 
		SET @FechaProgramadaEnvio  = DATEADD(MINUTE, 1, @FechaProgramadaEnvio)
	 END 

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
		(   @IdNotificacion,				-- IdNotificacion - bigint
			@Para,							-- Para - varchar(500)
			@Asunto,						-- Asunto - varchar(250)
			@Mensaje,						-- Mensaje - text
			@FechaProgramadaEnvio,	--@FechaProgramada, -- FechaProgramadaEnvio - datetime
			0,								-- Enviada - bit
			@FechaProgramadaEnvio,	-- FechaEnvio - datetime
			1,								--@IdUsuario,         -- CreadoPor - int
			GETDATE(),						-- CreadoEl - datetime
			NULL,							-- ModificadoPor - int
			NULL,							-- ModificadoEl - datetime
			@De,							-- De - varchar(100)
			CASE WHEN ISNULL(@CCO,'') <> '' THEN @CCO ELSE NULL END
		)

		
	SELECT  @IdNotificacion
	  
END

