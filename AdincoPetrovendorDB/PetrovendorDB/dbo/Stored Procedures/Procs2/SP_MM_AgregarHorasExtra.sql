
CREATE PROCEDURE [dbo].[SP_MM_AgregarHorasExtra]
	@HorasExtra INT,
	@IdPedido int
AS
BEGIN

	DECLARE @fechaVigencia smalldatetime = (select FechaVigencia FROM dbo.MM_HorasVigenciaPedido where IdPedido = @IdPedido)

	if(@fechaVigencia = NULL)
	begin
		UPDATE dbo.MM_HorasVigenciaPedido
			SET HorasVigencia = HorasVigencia + @HorasExtra
			WHERE IdPedido = @IdPedido
	END
    ELSE
    BEGIN
		UPDATE dbo.MM_HorasVigenciaPedido
			SET HorasVigencia = HorasVigencia + @HorasExtra,
				FechaVigencia = DATEADD(HOUR, @HorasExtra, @fechaVigencia)
			WHERE IdPedido = @IdPedido
    END
    
END
