--0 Comentario Base [JA_ComentarioBase]
--1 Comentario Respuesta [JA_ComentarioRespuesta]
--2 Comentario Base Convocatoria [JA_ComentariosBasesConvocatoria]
--3 Comentario Respuesta Convocatoria [JA_ComentariosBasesConvocatoriaRespuesta]
--4 Encabezado [JA_EncabezadoComentarios]
--5 Junta Aclaracion 

CREATE PROCEDURE [dbo].[sp_RevisarMensajesSinLeer] (@IdProveedor INT)
AS
BEGIN
    DECLARE @TablaRetornoMensajes TABLE
    (
        Id INT,
        RazonSocial NVARCHAR(MAX),
        TipoMensaje INT,
        Enviado BIT,
        FechaEnviado DATETIME,
        IdOFerta INT,
        IdSolPed INT,
        IdProveedor INT,
        IdPrimario INT,
        Descripcion NVARCHAR(150),
        CreadorProveedor INT,
        IdEncabezadoAux INT,
        FechaCreado DATETIME
    )

    INSERT INTO @TablaRetornoMensajes
    (
        Id,
        TipoMensaje,
        Enviado,
        FechaEnviado,
        IdOFerta,
        IdSolPed,
        IdProveedor,
        IdPrimario,
        Descripcion,
        IdEncabezadoAux,
        CreadorProveedor,
        FechaCreado
    )
    --[JA_ComentarioBase TipoMensaje = 0]
    SELECT comBase.IdComentarioBase,
           mensajes.TipoMensaje,
           mensajes.Enviado,
           mensajes.FechaEnviado,
           mensajes.IdOferta,
           mensajes.IdSolPed,
           mensajes.IdProveedor,
           mensajes.IdPrimario,
           'Tienes Un Comentario de ',
           0,
           mensajes.IdProveedorCreador,
           mensajes.FechaCreado
    FROM dbo.Ja_MensajesPendientesComentarios mensajes
        INNER JOIN dbo.S_Proveedor prov
            ON prov.IdProveedor = mensajes.IdProveedor
        INNER JOIN JA_ComentarioBase comBase
            ON comBase.IdComentarioBase = mensajes.IdPrimario
    WHERE (
              mensajes.Enviado = 0 -- no se le ha enviado el mensaje al usuario
              OR (
                     mensajes.Enviado = 1
                     AND DATEDIFF(HOUR, mensajes.FechaEnviado, GETDATE()) >= 2 -- o ya pasaron 2 horas de haberle notificado del ultimo mensaje
                 )
          )
          AND mensajes.TipoMensaje = 0 --Comentario Base [JA_ComentarioBase]
          AND mensajes.IdProveedor = @IdProveedor
          AND mensajes.Visto = 0

    INSERT INTO @TablaRetornoMensajes
    (
        Id,
        TipoMensaje,
        Enviado,
        FechaEnviado,
        IdOFerta,
        IdSolPed,
        IdProveedor,
        IdPrimario,
        Descripcion,
        IdEncabezadoAux,
        CreadorProveedor,
        FechaCreado
    )
    --[JA_ComentarioRespuesta TipoMensaje = 1]
    SELECT resp.IdComentarioRespuesta,
           mensajes.TipoMensaje,
           mensajes.Enviado,
           mensajes.FechaEnviado,
           mensajes.IdOferta,
           mensajes.IdSolPed,
           mensajes.IdProveedor,
           mensajes.IdPrimario,
           'Tienes Una Respuesta de ',
           0,
           mensajes.IdProveedorCreador,
           mensajes.FechaCreado
    FROM dbo.Ja_MensajesPendientesComentarios mensajes
        INNER JOIN dbo.S_Proveedor prov
            ON prov.IdProveedor = mensajes.IdProveedor
        INNER JOIN JA_ComentarioRespuesta resp
            ON resp.IdComentarioRespuesta = mensajes.IdPrimario
    WHERE (
              mensajes.Enviado = 0 -- no se le ha enviado el mensaje al usuario
              OR (
                     mensajes.Enviado = 1
                     AND DATEDIFF(HOUR, mensajes.FechaEnviado, GETDATE()) >= 2 -- o ya pasaron 2 horas de haberle notificado del ultimo mensaje
                 )
          )
          AND mensajes.TipoMensaje = 1 --Comentario Respuesta [JA_ComentarioRespuesta]
          AND mensajes.IdProveedor = @IdProveedor
          AND mensajes.Visto = 0

    INSERT INTO @TablaRetornoMensajes
    (
        Id,
        TipoMensaje,
        Enviado,
        FechaEnviado,
        IdOFerta,
        IdSolPed,
        IdProveedor,
        IdPrimario,
        Descripcion,
        CreadorProveedor,
        IdEncabezadoAux,
        FechaCreado
    )
    --[JA_ComentariosBasesConvocatoria TipoMensaje = 2]
    SELECT com.IdComentarioBases,
           mensajes.TipoMensaje,
           mensajes.Enviado,
           mensajes.FechaEnviado,
           mensajes.IdOferta,
           mensajes.IdSolPed,
           mensajes.IdProveedor,
           mensajes.IdPrimario,
           'Tienes Un Comentario de ',
           mensajes.IdProveedorCreador,
           dbo.Func_Ja_ObtenerIdEncabezado(2, mensajes.IdPrimario, mensajes.IdProveedor),
           mensajes.FechaCreado
    FROM dbo.Ja_MensajesPendientesComentarios mensajes
        INNER JOIN dbo.S_Proveedor prov
            ON prov.IdProveedor = mensajes.IdProveedor
        INNER JOIN JA_ComentariosBasesConvocatoria com
            ON com.IdComentarioBases = mensajes.IdPrimario
    WHERE (
              mensajes.Enviado = 0 -- no se le ha enviado el mensaje al usuario
              OR (
                     mensajes.Enviado = 1
                     AND DATEDIFF(HOUR, mensajes.FechaEnviado, GETDATE()) >= 2 -- o ya pasaron 2 horas de haberle notificado del ultimo mensaje
                 )
          )
          AND mensajes.TipoMensaje = 2 --Comentario Base Convocatoria [JA_ComentariosBasesConvocatoria]
          AND mensajes.IdProveedor = @IdProveedor
          AND mensajes.Visto = 0

    INSERT INTO @TablaRetornoMensajes
    (
        Id,
        TipoMensaje,
        Enviado,
        FechaEnviado,
        IdOFerta,
        IdSolPed,
        IdProveedor,
        IdPrimario,
        Descripcion,
        CreadorProveedor,
        IdEncabezadoAux,
        FechaCreado
    )
    --[JA_ComentariosBasesConvocatoriaRespuesta TipoMensaje = 3]
    SELECT resp.IdRespuesta,
           mensajes.TipoMensaje,
           mensajes.Enviado,
           mensajes.FechaEnviado,
           mensajes.IdOferta,
           mensajes.IdSolPed,
           mensajes.IdProveedor,
           mensajes.IdPrimario,
           'Tienes Una Respuesta de ',
           mensajes.IdProveedorCreador,
           dbo.Func_Ja_ObtenerIdEncabezado(3, mensajes.IdPrimario, mensajes.IdProveedor),
           mensajes.FechaCreado
    FROM dbo.Ja_MensajesPendientesComentarios mensajes
        INNER JOIN dbo.S_Proveedor prov
            ON prov.IdProveedor = mensajes.IdProveedor
        INNER JOIN JA_ComentariosBasesConvocatoriaRespuesta resp
            ON resp.IdRespuesta = mensajes.IdPrimario
    WHERE (
              mensajes.Enviado = 0 -- no se le ha enviado el mensaje al usuario
              OR (
                     mensajes.Enviado = 1
                     AND DATEDIFF(HOUR, mensajes.FechaEnviado, GETDATE()) >= 2 -- o ya pasaron 2 horas de haberle notificado del ultimo mensaje
                 )
          )
          AND mensajes.TipoMensaje = 3 --Comentario Respuesta Convocatoria [JA_ComentariosBasesConvocatoriaRespuesta]
          AND mensajes.IdProveedor = @IdProveedor
          AND mensajes.Visto = 0

    INSERT INTO @TablaRetornoMensajes
    (
        Id,
        TipoMensaje,
        Enviado,
        FechaEnviado,
        IdOFerta,
        IdSolPed,
        IdProveedor,
        IdPrimario,
        Descripcion,
        IdEncabezadoAux,
        CreadorProveedor,
        FechaCreado
    )
    --[JA_EncabezadoComentarios TipoMensaje = 4]
    SELECT enc.IdEncabezado,
           mensajes.TipoMensaje,
           mensajes.Enviado,
           mensajes.FechaEnviado,
           mensajes.IdOferta,
           mensajes.IdSolPed,
           mensajes.IdProveedor,
           mensajes.IdPrimario,
           'Tienes Una Nueva Pregunta de ',
           0,
           mensajes.IdProveedorCreador,
           mensajes.FechaCreado
    FROM dbo.Ja_MensajesPendientesComentarios mensajes
        INNER JOIN dbo.S_Proveedor prov
            ON prov.IdProveedor = mensajes.IdProveedor
        INNER JOIN JA_EncabezadoComentarios enc
            ON enc.IdEncabezado = mensajes.IdPrimario
    WHERE (
              mensajes.Enviado = 0 -- no se le ha enviado el mensaje al usuario
              OR (
                     mensajes.Enviado = 1
                     AND DATEDIFF(HOUR, mensajes.FechaEnviado, GETDATE()) >= 2 -- o ya pasaron 2 horas de haberle notificado del ultimo mensaje
                 )
          )
          AND mensajes.TipoMensaje = 4 --Encabezado [JA_EncabezadoComentarios]
          AND mensajes.IdProveedor = @IdProveedor
          AND mensajes.Visto = 0


    INSERT INTO @TablaRetornoMensajes
    (
        Id,
        TipoMensaje,
        Enviado,
        FechaEnviado,
        IdOFerta,
        IdSolPed,
        IdProveedor,
        IdPrimario,
        Descripcion,
        IdEncabezadoAux,
        CreadorProveedor,
        FechaCreado
    )
    --[JA_TopicAclaraciones TipoMensaje = 5]
    SELECT junta.IdTopic,
           mensajes.TipoMensaje,
           mensajes.Enviado,
           mensajes.FechaEnviado,
           mensajes.IdOferta,
           mensajes.IdSolPed,
           mensajes.IdProveedor,
           mensajes.IdPrimario,
           'Tienes Una Junta por revisar de  ',
           0,
           mensajes.IdProveedorCreador,
           mensajes.FechaCreado
    FROM dbo.Ja_MensajesPendientesComentarios mensajes
        INNER JOIN dbo.S_Proveedor prov
            ON prov.IdProveedor = mensajes.IdProveedor
        INNER JOIN JA_TopicAclaraciones junta
            ON junta.IdTopic = mensajes.IdPrimario
    WHERE (
              mensajes.Enviado = 0 -- no se le ha enviado el mensaje al usuario
              OR (
                     mensajes.Enviado = 1
                     AND DATEDIFF(HOUR, mensajes.FechaEnviado, GETDATE()) >= 2 -- o ya pasaron 2 horas de haberle notificado del ultimo mensaje
                 )
          )
          AND mensajes.TipoMensaje = 5 --Nueva Junta o Edicion de junta [JA_TopicAclaraciones]
          AND mensajes.IdProveedor = @IdProveedor
          AND mensajes.Visto = 0

    UPDATE mensaj
    SET RazonSocial = prov.RazonSocial
    FROM @TablaRetornoMensajes mensaj
        INNER JOIN dbo.S_Proveedor prov
            ON prov.IdProveedor = mensaj.CreadorProveedor

    --retorno a la vista los mensajes pendientes por notificar
    SELECT *
    FROM @TablaRetornoMensajes
    ORDER BY Id ASC

END
