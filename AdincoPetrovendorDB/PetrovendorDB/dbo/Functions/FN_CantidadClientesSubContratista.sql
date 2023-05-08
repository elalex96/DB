-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <30/01/2020>
-- Description:	<Consultar la cantidad de operadores que le han hecho un pedido al subcontratista>
-- =============================================
CREATE FUNCTION FN_CantidadClientesSubContratista
(
	-- Add the parameters for the function here
	@IdProveedor INT
)
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @CANTIDADCLIENTES INT;

	-- Add the T-SQL statements to compute the return value here
	DECLARE @reb TABLE (IDCLIENTE INT);

	INSERT INTO @reb
	SELECT 
		P.IdProveedorCompras
	FROM dbo.MM_Pedido AS P
		INNER JOIN dbo.MM_AceptacionPedido AS AP
			ON AP.IdPedido = P.IdPedido
	WHERE P.IdSubcontratista = @IdProveedor
	GROUP BY P.IdProveedorCompras;

	SELECT
		@CANTIDADCLIENTES = COUNT(IDCLIENTE)
	FROM @reb

	-- Return the result of the function
	RETURN @CANTIDADCLIENTES;

END

