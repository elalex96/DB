
-- =============================================
-- Author:DANIEL AC
-- alter date: 05-01-2018
-- Description: CONSULTAR FECHA DE APROBACIÓN DEL PEDIDO 
-- =============================================

CREATE FUNCTION [dbo].[FN_FechaAprobacionPedido]
(
	-- Add the parameters for the function here
	@IdOperacion INT 
)
RETURNS DATETIME
AS
BEGIN
	-- Declare the return variable here
	DECLARE @FECHA DATETIME;
	

	-- Add the T-SQL statements to compute the return value here
	--COMO NO SE TIENE REGISTRADA LA FECHA DE CUANDO SE APROBO LA APROBACION DE PEDIDO
	-- SE OBTA POR OBTNER LA FECHA CUANDO SE CAMBIA EL ESTATUS DEL ULTIMO APROBADOR QUE DESENCANDENA
	-- LA FECHA DE ENVIO DEL PEDIDO AL PROVEEDOR 
	SELECT TOP 1 @FECHA= T.FechaCambioEstatus FROM dbo.TA_Tarea T WHERE T.IdOperacion=@IdOperacion ORDER BY T.FechaCambioEstatus DESC

	
	RETURN @FECHA;

END

