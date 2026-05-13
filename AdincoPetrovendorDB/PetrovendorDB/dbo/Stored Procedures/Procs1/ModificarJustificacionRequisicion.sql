CREATE PROCEDURE ModificarJustificacionRequisicion
@IdSolicitudPedido INT,
@IdProveedor INT,
@MotivoUrgencia NVARCHAR(MAX),
@IdUsuario INT
AS
BEGIN	
	INSERT INTO dbo.HistorialObjetoDelPedido (IdSolicitudPedido, IdUsuarioModifico, MotivoAnterior, FechaModificado)
	SELECT @IdSolicitudPedido, @IdUsuario , @MotivoUrgencia, GETDATE()

	UPDATE dbo.MM_SolicitudPedido
	SET MotivoUrgencia = @MotivoUrgencia
	WHERE IdSolicitudPedido = @IdSolicitudPedido
	AND IdProveedor = @IdProveedor
END;


