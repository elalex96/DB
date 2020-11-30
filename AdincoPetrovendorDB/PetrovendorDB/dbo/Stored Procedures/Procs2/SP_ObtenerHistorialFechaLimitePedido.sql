CREATE PROCEDURE SP_ObtenerHistorialFechaLimitePedido
    @IdPedido INT,
    @IdProveedor INT
AS
BEGIN
    DECLARE @FechaActual DATETIME

    SELECT @FechaActual = FechaVigencia
    FROM MM_HorasVigenciaPedido
    WHERE IdPedido = @IdPedido

    SELECT historial.IdHorasVigencia AS Id_Historial,
           Nombre,
           historial.FechaCreacion AS FechaEdicion,
           'De: ' + CAST(historial.FechaVigencia AS NVARCHAR(200)) + ' A: ' + CAST(@FechaActual AS VARCHAR(200)) AS Cambio,
           historial.Motivo
    FROM dbo.MM_HorasVigenciaPedidoHistorial historial
        LEFT JOIN dbo.S_Usuario usuario
            ON usuario.IdUsuario = historial.IdUsuarioCreador
    WHERE historial.IdPedido = @IdPedido
END