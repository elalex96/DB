CREATE PROCEDURE [dbo].[sp_JaActualizarEnviadoMensaje]
(
    @IdPrimario INT,
    @TipoMensaje INT,
    @IdProveedor INT
)
AS
BEGIN
    UPDATE dbo.Ja_MensajesPendientesComentarios
    SET Enviado = 1,
        FechaEnviado = GETDATE()
    WHERE IdPrimario = @IdPrimario
          AND TipoMensaje = @TipoMensaje
          AND IdProveedor = @IdProveedor

    --retorno algo a la vista
    SELECT 1
END
