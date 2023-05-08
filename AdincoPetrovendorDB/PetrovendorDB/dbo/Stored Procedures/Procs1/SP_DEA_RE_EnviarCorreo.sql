-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_RE_EnviarCorreo]
@Para VARCHAR(500),
@Asunto VARCHAR(250),
@Mensaje TEXT,
@IdUsuario INT,
@De VARCHAR(100),
@IdCorreo INT,
@Identificacion NVARCHAR(MAX)
AS
BEGIN
    DECLARE @IdNotificacion BIGINT
    SELECT @IdNotificacion = MAX(IdNotificacion) + 1
    FROM Adinco.dbo.S_Notificacion

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
    (   @IdNotificacion, -- IdNotificacion - bigint
        @Para,           -- Para - varchar(500)
        @Asunto,         -- Asunto - varchar(250)
        @Mensaje,        -- Mensaje - text
        GETDATE(),       --@FechaProgramada, -- FechaProgramadaEnvio - datetime
        1,               -- Enviada - bit
        GETDATE(),       -- FechaEnvio - datetime
        1,               --@IdUsuario,         -- CreadoPor - int
        GETDATE(),       -- CreadoEl - datetime
        @De              -- De - varchar(100)
    )


    INSERT INTO dbo.TA_EnvioCorreo (IdEnvioAdinco, IdCorreo, IdIdentificacion, EnviadoPor, EnviadoEl)
    VALUES
    (   @IdNotificacion, -- IdEnvioAdinco - int
        @IdCorreo,       -- IdCorreo - int
        @Identificacion, -- IdIdentificacion - int
        @IdUsuario, GETDATE())

    SELECT @IdNotificacion
END

