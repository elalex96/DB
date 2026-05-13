CREATE PROCEDURE [dbo].[SP_BitacoraError]
(
    @HResult INT,
    @Mensaje NVARCHAR(MAX),
    @StackTrace NVARCHAR(MAX),
    @IdUsuario INT,
    @IdProveedor INT,
    @IdPedidoCarso INT = 0
)
AS
BEGIN
    DECLARE @valorInsertado INT

    INSERT INTO dbo.BitacoraErrores (HResult, Mensaje, StackTrace, IdUsuario, IdProveedor, FechaRegistro)
    VALUES
    (   @HResult,    -- HResult - int
        @Mensaje,    -- Mensaje - nvarchar(max)
        @StackTrace, -- StackTrace - nvarchar(max)
        @IdUsuario,  -- IdUsuario - int
        @IdProveedor, GETDATE())
    SELECT @valorInsertado = SCOPE_IDENTITY()

    SELECT CONCAT(CONVERT(NVARCHAR(255), ABS(@HResult)), '-', IdError)
    FROM BitacoraErrores
    WHERE IdError = @valorInsertado

    IF (@IdPedidoCarso <> 0)
    BEGIN
        INSERT INTO dbo.Ax_BitacoraCarso (ErrorMotivo, Lugar, FechaRegistro, IdPedido)
        SELECT CONCAT(ISNULL(@Mensaje, ''), ' - StackTrace: ', @StackTrace),
               'Excepcion en servidor',
               GETDATE(),
               @IdPedidoCarso
    END
END




