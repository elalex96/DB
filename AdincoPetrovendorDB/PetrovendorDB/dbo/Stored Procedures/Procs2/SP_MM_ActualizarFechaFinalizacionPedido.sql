CREATE PROCEDURE SP_MM_ActualizarFechaFinalizacionPedido
    @IdPedido INT,
    @NuevaFechaLimite DATETIME,
    @IdUsuario INT,
    @Motivo NVARCHAR(MAX)
AS
BEGIN
	DECLARE @HorasVigencia INT,
			@OldFechaVigencia DATETIME

	SELECT	@HorasVigencia = HorasVigencia, @OldFechaVigencia = FechaVigencia  FROM dbo.MM_HorasVigenciaPedido WHERE IdPedido =  @IdPedido

    INSERT INTO dbo.MM_HorasVigenciaPedidoHistorial
    (
        IdPedido,
        HorasVigencia,
        FechaVigencia,
        FechaCreacion,
        IdUsuarioCreador,
        Motivo
    )
    VALUES
    (   @IdPedido,         -- IdPedido - int
        @HorasVigencia,    -- HorasVigencia - int
        @OldFechaVigencia, -- FechaVigencia - datetime
        GETDATE(),         -- FechaCreacion - datetime
        @IdUsuario,        -- IdUsuarioCreador - int
        @Motivo            -- Motivo - nvarchar(max)
    )


    UPDATE MM_HorasVigenciaPedido
    SET FechaVigencia = @NuevaFechaLimite,
        HorasVigencia = DATEDIFF(HOUR, GETDATE() , @NuevaFechaLimite)
    WHERE IdPedido = @IdPedido

	SELECT 1 --retorno algo para saber que llegue hasta aqui
END
