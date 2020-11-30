-- =============================================  
CREATE PROCEDURE [dbo].[SP_DEA_EnviarCorreo]
-- Add the parameters for the stored procedure here  
@Para VARCHAR(500),
@Asunto VARCHAR(250),
@Mensaje TEXT,
@IdUsuario INT,
@De VARCHAR(100),
@IdCorreo INT,
@IdIdentificacion NVARCHAR(MAX),
@EnvioManual BIT = NULL
AS
BEGIN


    DECLARE @IdNotificacion BIGINT
    SET @IdNotificacion =
    (   SELECT TOP 1
               IdNotificacion
        FROM Adinco.dbo.S_Notificacion
        WHERE Asunto = @Asunto
              AND Para = @Para
        ORDER BY IdNotificacion DESC)

    IF ISNULL(@IdNotificacion, 0) = 0
    BEGIN

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
            De
        )
        VALUES
        (   @IdNotificacion,               -- IdNotificacion - bigint  
            @Para,                         -- Para - varchar(500)  
            @Asunto,                       -- Asunto - varchar(250)  
            @Mensaje,                      -- Mensaje - text  
            DATEADD(MINUTE, 1, GETDATE()), --@FechaProgramada, -- FechaProgramadaEnvio - datetime  
            0,                             -- Enviada - bit  
            NULL,                          -- FechaEnvio - datetime  
            1,                             --@IdUsuario,         -- CreadoPor - int  
            GETDATE(),                     -- CreadoEl - datetime  
            @De                            -- De - varchar(100)  
        )

        INSERT INTO dbo.TA_EnvioCorreo (IdEnvioAdinco, IdCorreo, IdIdentificacion, EnviadoPor, EnviadoEl)
        VALUES
        (   @IdNotificacion,   -- IdEnvioAdinco - int  
            @IdCorreo,         -- IdCorreo - int  
            @IdIdentificacion, -- IdIdentificacion - int  
            @IdUsuario, GETDATE())

    END

    SELECT @IdNotificacion

END