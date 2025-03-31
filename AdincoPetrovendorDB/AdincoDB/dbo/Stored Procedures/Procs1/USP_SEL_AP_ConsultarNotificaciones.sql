-- Eliminar el procedimiento si ya existe
DROP PROCEDURE IF EXISTS [dbo].[USP_SEL_AP_ConsultarNotificaciones]
GO

CREATE PROCEDURE [dbo].[USP_SEL_AP_ConsultarNotificaciones]
    @IdsNotificaciones VARCHAR(500),
    @SoloPendientes BIT = 1,
    @MensajeError NVARCHAR(4000) OUT -- Parámetro de salida para errores
AS
BEGIN
    SET NOCOUNT ON;

        -- Usar una variable de tabla en lugar de una tabla temporal
        DECLARE @tmpNotificacionesIds TABLE (IdNotificacion INT);

        -- Insertar en la variable de tabla si el parámetro no es nulo o vacío
        IF (ISNULL(@IdsNotificaciones, '') <> '')
        BEGIN
            INSERT INTO @tmpNotificacionesIds
            SELECT splitdata
            FROM dbo.fnSplitString(@IdsNotificaciones, ',');
        END
        ELSE
        BEGIN
            INSERT INTO @tmpNotificacionesIds
            SELECT 0;
        END;

        -- Consultar las notificaciones
        SELECT TOP 20
            N.Id,
            N.Para,
            N.Asunto,
            Mensaje = CAST(N.Mensaje AS VARCHAR(MAX)),
            N.FechaProgramadaEnvio,
            N.Enviada,
            N.FechaEnvio,
            TieneError = CASE
                             WHEN MAX(NE.Id) IS NOT NULL THEN
                                 1
                             ELSE
                                 0
                         END,
            N.CreadoPor,
            N.CreadoEl,
            N.ModificadoPor,
            N.ModificadoEl,
            N.De,
            IdNotificacionMA = 0,
            N.CCO
        FROM dbo.AP_Notificacion N (NOLOCK)
            INNER JOIN @tmpNotificacionesIds tmp
                ON (tmp.IdNotificacion = N.Id OR tmp.IdNotificacion = 0)
            LEFT JOIN dbo.AP_NotificacionError NE (NOLOCK)
                ON N.Id = NE.NotificacionId
        WHERE N.Enviada = 0
            AND N.FechaProgramadaEnvio <= GETDATE()
            AND LTRIM(RTRIM(ISNULL(N.Para, ''))) <> ''
        GROUP BY N.Id,
                 N.Asunto,
                 CAST(N.Mensaje AS VARCHAR(MAX)),
                 N.FechaProgramadaEnvio,
                 N.Enviada,
                 N.FechaEnvio,
                 N.CreadoPor,
                 N.CreadoEl,
                 N.ModificadoPor,
                 N.ModificadoEl,
                 N.De,
                 N.Para,
                 N.CCO
        HAVING COUNT(DISTINCT NE.Id) < 3 -- Solo se intentará enviar hasta 3 veces un mismo correo
        ORDER BY N.Id;
        

        -- Si todo ha ido bien, establecer mensaje de error como NULL
        SET @MensajeError = '';
END
