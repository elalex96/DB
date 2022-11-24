CREATE PROCEDURE sp_JAConfirmarCancelarJunta
(
    @IdTopic INT,
    @ConfirmarCancelar INT,
    @IdUsuario INT,
    @IdEstatus INT
)
AS
BEGIN
    --primero inserto en el historico y luego actualizo el estatus
    INSERT INTO dbo.JA_EstatusHistorico
    (
        Estatus,
        IdTopic,
        IdProveedor,
        CreadoPor,
        FechaCreado
    )
    SELECT Estatus,
           IdTopic,
           IdProveedor,
           @IdUsuario,
           GETDATE()
    FROM dbo.JA_Estatus
    WHERE IdTopic = @IdTopic

    UPDATE dbo.JA_Estatus
    SET Estatus = @ConfirmarCancelar
    WHERE IdTopic = @IdTopic

END