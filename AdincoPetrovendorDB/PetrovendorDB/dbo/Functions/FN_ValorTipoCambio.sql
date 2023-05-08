-- =============================================
-- Author:		Alexander Gomez
-- Create date: 12/07/2018
-- Description:	Obtiene el valor del tipo de cambio de peso mexicano por dolar segun la fecha
-- =============================================
create FUNCTION [dbo].[FN_ValorTipoCambio]
(
	-- Add the parameters for the function here
	@FechaTipoCambio DATE
)
RETURNS FLOAT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ValorTipoCambio FLOAT;

	-- Add the T-SQL statements to compute the return value here
	SET @ValorTipoCambio = (SELECT TipoCambio FROM Adinco.dbo.CO_TipoCambioDiario WHERE Fecha = @FechaTipoCambio AND IdMoneda = 1)

	-- Return the result of the function
	RETURN @ValorTipoCambio

END
