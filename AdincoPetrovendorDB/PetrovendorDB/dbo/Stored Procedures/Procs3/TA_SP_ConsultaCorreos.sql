USE [Petrovendor]
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TA_SP_ConsultaCorreos]') AND type IN (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [dbo].[TA_SP_ConsultaCorreos];
END
GO

CREATE PROCEDURE [dbo].[TA_SP_ConsultaCorreos]
    -- Cambiamos a DATETIME2 para soportar la precisión que envía el código C#
    @fechaInicio DATETIME2 = NULL, 
    @fechaFin DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON; 

    SELECT *
    FROM
    (
        SELECT 
            n.IdNotificacion,
            n.Para,
            n.Asunto,
            n.Enviada,
            ISNULL(u.Nombre, 'Administrador Petrovendor') AS EnviadoPor,
            ec.EnviadoEl,
            ec.IdIdentificacion,
            n.Mensaje
        FROM Adinco.dbo.S_Notificacion n WITH (NOLOCK)
        INNER JOIN dbo.TA_EnvioCorreo ec WITH (NOLOCK)
            ON ec.IdEnvioAdinco = n.IdNotificacion
        LEFT JOIN dbo.S_Usuario u WITH (NOLOCK)
            ON u.IdUsuario = ec.EnviadoPor
        WHERE n.CreadoPor IN (3, 1) -- > ctes
          AND n.CreadoEl BETWEEN @fechaInicio AND DATEADD(HOUR, 24, @fechaFin)

        UNION ALL

        SELECT 
            n.IdNotificacion,
            n.Para,
            n.Asunto,
            n.Enviada,
            'Administrador Petrovendor' AS EnviadoPor,
            ec.EnviadoEl,
            ec.IdIdentificacion,
            n.Mensaje
        FROM Adinco.dbo.S_Notificacion n WITH (NOLOCK)
        INNER JOIN dbo.TA_EnvioCorreo ec WITH (NOLOCK)
            ON ec.IdEnvioAdinco = n.IdNotificacion
        WHERE n.CreadoPor IN (3, 1) -- > ctes
          AND ec.EnviadoPor = 0
          AND n.CreadoEl BETWEEN @fechaInicio AND DATEADD(HOUR, 24, @fechaFin)
          
    ) AS Correos
    ORDER BY Correos.IdNotificacion DESC;
END;
