-- =============================================
-- Author:	DANIEL AC
-- Create date:05-01-2019
-- Description:	Obtiene el valor del tipo de cambio de peso mexicano por dolar segun la fecha
-- =============================================
CREATE FUNCTION FN_ValorTipoCambioIterativo
(
	-- Add the parameters for the function here
	@FechaTipoCambio DATE
)
RETURNS FLOAT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ValorTipoCambio FLOAT;
	DECLARE @Dias INT = -1;

	-- Add the T-SQL statements to compute the return value here
	SET @ValorTipoCambio = (SELECT TipoCambio FROM Adinco.dbo.CO_TipoCambioDiario WHERE Fecha = @FechaTipoCambio AND IdMoneda = 1)

    WHILE @ValorTipoCambio IS NULL
	BEGIN
		SET @ValorTipoCambio = (SELECT TipoCambio FROM Adinco.dbo.CO_TipoCambioDiario WHERE Fecha = DATEADD(DAY, @Dias, @FechaTipoCambio) AND IdMoneda = 1)
		SET @Dias = @Dias - 1
	END

	-- Return the result of the function
	RETURN @ValorTipoCambio

END

