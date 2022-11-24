CREATE PROCEDURE [dbo].[sp_JAObtenerEncabezadoConvocatoria]
(
    @IdSolPed INT,
    @IdEncabezado INT = 0,
    @IdProveedor INT
)
AS
BEGIN
    IF (@IdEncabezado = 0) --Si lo inicio el grid
    BEGIN
        SELECT encab.IdEncabezado,
               encab.Nombre,
               encab.Paginas,
               encab.PuntosBases,
               encab.Pregunta,
               encab.FechaCreado
        FROM dbo.JA_EncabezadoComentarios encab
        WHERE encab.IdSolPed = @IdSolPed
    --AND encab.IdOferta = @IdOferta
    END
    ELSE --si fue consulta desde la aplicacion
    BEGIN
        --Cambiar el estatus de los mensajes pendientes de notificacion
        UPDATE dbo.Ja_MensajesPendientesComentarios
        SET Visto = 1,
            Enviado = 1,
            FechaEnviado = GETDATE()
        WHERE IdPrimario = @IdEncabezado
              AND TipoMensaje = 4 --un nuevo encabezado(Pregunta)
              AND Visto = 0
              AND IdProveedor = @IdProveedor

        --Retorno a la vista
        SELECT encab.IdEncabezado,
               encab.Nombre,
               encab.Paginas,
               encab.PuntosBases,
               encab.Pregunta,
               encab.FechaCreado
        FROM dbo.JA_EncabezadoComentarios encab
        WHERE encab.IdSolPed = @IdSolPed
              AND encab.IdEncabezado = @IdEncabezado

    END

END
