create PROCEDURE [dbo].[SP_SC_ConsultaFechasEnvio_ControlObra]
@idcontrato int
AS
BEGIN
	SELECT DISTINCT
		--FechaEnvioPedido ,
		CONVERT(nvarchar(MAX), FechaEnvioPedido, 1) AS 'actual',
		CONVERT(nvarchar(MAX), FechaEnvioPedido, 107) AS 'Fecha'
		FROM Petrovendor.dbo.MM_Pedido AS P
		WHERE P.FechaEnvioPedido IS NOT NULL
		AND P.IdContrato = @idcontrato 
		ORDER BY actual asc
		
END