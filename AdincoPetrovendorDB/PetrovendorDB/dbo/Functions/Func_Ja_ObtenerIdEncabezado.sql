
CREATE FUNCTION [dbo].[Func_Ja_ObtenerIdEncabezado]
(
    @TipoMensaje INT,
    @IdPrimario INT,
    @IdProveedor INT
)
RETURNS INT
BEGIN
    DECLARE @idEncabezado INT

	--Comentario Convocatoria
	IF (@TipoMensaje = 2)
    BEGIN
        SELECT @idEncabezado = encab.IdEncabezado
        FROM dbo.Ja_MensajesPendientesComentarios mensaj
            INNER JOIN dbo.JA_EncabezadoComentarios encab
                ON encab.IdSolPed = mensaj.IdSolPed
            INNER JOIN dbo.JA_ComentariosBasesConvocatoria com
                ON com.IdEncabezado = encab.IdEncabezado
                   AND com.IdComentarioBases = mensaj.IdPrimario
        WHERE mensaj.IdPrimario = @IdPrimario
              AND mensaj.TipoMensaje = @TipoMensaje
              AND mensaj.IdProveedor = @IdProveedor
    END

	--Comentario Respuesta
	IF (@TipoMensaje = 3)
    BEGIN
        SELECT @idEncabezado = encab.IdEncabezado
        FROM dbo.Ja_MensajesPendientesComentarios mensaj
            INNER JOIN dbo.JA_EncabezadoComentarios encab
                ON encab.IdSolPed = mensaj.IdSolPed
            INNER JOIN dbo.JA_ComentariosBasesConvocatoriaRespuesta resp
                ON resp.IdEncabezado = encab.IdEncabezado
                   AND resp.IdRespuesta = mensaj.IdPrimario
        WHERE mensaj.IdPrimario = @IdPrimario
              AND mensaj.TipoMensaje = @TipoMensaje
              AND mensaj.IdProveedor = @IdProveedor
    END

    RETURN @idEncabezado
END



