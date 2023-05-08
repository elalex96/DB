-- =============================================
-- Author:	Daniel Ac
-- Create date: 04/11/2020
-- Description:	Guarda correo de aplicación móvil 
-- =============================================
CREATE PROCEDURE [dbo].[Mobile_sp_GuardaCorreoS_Notificacion]
    @Para VARCHAR(500),
    @De VARCHAR(100),
    @Asunto VARCHAR(500),
    @Mensaje TEXT,
    @Enviada BIT,
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @IdNotificacion INT;
    SET @IdNotificacion =
    (
        SELECT MAX(IdNotificacion) + 1 FROM S_Notificacion
    );

    INSERT INTO S_Notificacion
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
    (@IdNotificacion, @Para, @Asunto, @Mensaje, GETDATE(), @Enviada, NULL, @IdUsuario, GETDATE(), @De);

    SELECT @IdNotificacion AS IdNotificacion;

END;
