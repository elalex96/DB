-- =============================================
-- Author:		Alexander Gomez
-- Create date: 12/07/2018
-- Description: Realiza la convercion de dolares a pesos mexicanos segun la fecha de tipo de cambio
-- =============================================
CREATE FUNCTION [dbo].[FN_DolaresPesosTipoCambio]
(
	-- Add the parameters for the function here
	@MontoUSD FLOAT,
	@FechaTipoCambio DATE
)
RETURNS FLOAT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @MontoMXN FLOAT;
	DECLARE @TipoCambioMXN FLOAT;

	-- Add the T-SQL statements to compute the return value here
	SET @TipoCambioMXN = (SELECT TipoCambio FROM Adinco.dbo.CO_TipoCambioDiario WHERE Fecha = @FechaTipoCambio AND IdMoneda = 1);

	SET @MontoMXN = (@MontoUSD * @TipoCambioMXN);

	-- Return the result of the function
	RETURN isnull(@MontoMXN,0);

END

