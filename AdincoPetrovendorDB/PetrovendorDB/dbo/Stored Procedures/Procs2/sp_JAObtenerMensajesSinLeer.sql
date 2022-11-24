CREATE PROCEDURE [dbo].[sp_JAObtenerMensajesSinLeer] (@idUsuario INT)
AS
BEGIN

    --(BaseoRespuesta) Base es igual a 0 y la respuesta = 1
    DECLARE @tablaAuxiliar TABLE
    (
        BaseoRespuesta BIT,
        IdComentario INT,
        Comentario NVARCHAR(MAX),
        IdUsuario INT,
        IdPerfil INT,
        IdTopic INT,
        Fechacreado DATETIME,
        Visto BIT
    )

    INSERT INTO @tablaAuxiliar
    (
        BaseoRespuesta,
        IdComentario,
        Comentario,
        IdUsuario,
        IdPerfil,
        IdTopic,
        Fechacreado,
        Visto
    )
    SELECT 0,
           IdComentarioBase,
           Comentario,
           IdUsuario,
           IdPerfil,
           IdTopic,
           FechaCreado,
           Visto
    FROM dbo.JA_ComentarioBase

    INSERT INTO @tablaAuxiliar
    (
        BaseoRespuesta,
        IdComentario,
        Comentario,
        IdUsuario,
        IdPerfil,
        IdTopic,
        Fechacreado,
        Visto
    )
    SELECT 1,
           IdComentarioRespuesta,
           Respuesta,
           IdUsuario,
           IdPerfil,
           IdTopic,
           FechaCreado,
           Visto
    FROM dbo.JA_ComentarioRespuesta
  
	--Retorno las conversaciones en las que ah participado siempre y cuando no sea el mismo
    SELECT *
    FROM @tablaAuxiliar
    WHERE IdUsuario != @idUsuario
          AND IdTopic IN (   --el subquery es los topic en los que ah participado
                             SELECT DISTINCT IdTopic FROM @tablaAuxiliar WHERE IdUsuario = @idUsuario
                         )


END
