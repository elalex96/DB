-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <30/01/2020>
-- Description:	<funcion para obtener todos los pedidos realizados por el subcontratista>
-- =============================================
CREATE FUNCTION [dbo].[FN_PedidosSubContratista]
(
	-- Add the parameters for the function here
	@IdProveedor INT
)
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @CANTIDADPEDIDOSACEPTADOS INT;
	DECLARE @MESESATRAS DATETIME = DATEADD(MONTH,-5,GETDATE());
	DECLARE @REG TABLE (IDPEDIDO INT);
	-- Add the T-SQL statements to compute the return value here
	INSERT INTO @REG
	SELECT 
		P.IdPedido
	FROM dbo.MM_Pedido AS P
		INNER JOIN dbo.MM_AceptacionPedido AS AP
			ON AP.IdPedido = P.IdPedido
	WHERE P.IdSubcontratista = @IdProveedor
		AND P.CreadoEl >= @MESESATRAS  
	GROUP BY P.IdPedido;

	SELECT
		@CANTIDADPEDIDOSACEPTADOS = COUNT(IDPEDIDO)
	FROM @REG

	-- Return the result of the function
	RETURN @CANTIDADPEDIDOSACEPTADOS;

END

