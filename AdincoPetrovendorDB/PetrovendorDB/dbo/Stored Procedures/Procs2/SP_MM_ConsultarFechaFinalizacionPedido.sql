CREATE PROCEDURE SP_MM_ConsultarFechaFinalizacionPedido
	@IdPedido INT
AS
BEGIN

SELECT IdPedido, DATEDIFF(HOUR, GETDATE(), FechaVigencia) ,FechaVigencia, HorasVigencia  FROM MM_HorasVigenciaPedido WHERE IdPedido = @IdPedido
    
END

