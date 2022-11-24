CREATE PROCEDURE [dbo].[sp_JaActualizarNotifiNuevaJunta]
(
    @IdTopic INT,
    @IdProveedor INT
)
AS
BEGIN
    UPDATE dbo.Ja_MensajesPendientesComentarios
    SET Visto = 1,
        Enviado = 1,
        FechaEnviado = GETDATE()
    WHERE TipoMensaje = 5
          AND IdPrimario = @IdTopic
          AND IdProveedor = @IdProveedor
END
