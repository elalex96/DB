-- =============================================
-- Author:	DANIEL AC
-- Create date:05-01-2019
-- Description:	Obtiene el valor del tipo de cambio de peso mexicano por dolar segun la fecha
-- =============================================
CREATE FUNCTION FN_FechaTipoCambioIterativo
(
	-- Add the parameters for the function here
	@FechaTipoCambio DATE
)
RETURNS DATE
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ValorTipoCambio FLOAT;
	DECLARE @Dias INT = -1;
	DECLARE @FECHA_TIPOCAMBIO DATE

	-- Add the T-SQL statements to compute the return value here
	SET @ValorTipoCambio = (SELECT TipoCambio FROM Adinco.dbo.CO_TipoCambioDiario WHERE Fecha = @FechaTipoCambio AND IdMoneda = 1)

	IF @ValorTipoCambio IS NOT NULL
		SET @FECHA_TIPOCAMBIO=@FechaTipoCambio



    WHILE @ValorTipoCambio IS NULL
	BEGIN
		SET @ValorTipoCambio = (SELECT TipoCambio FROM Adinco.dbo.CO_TipoCambioDiario WHERE Fecha = DATEADD(DAY, @Dias, @FechaTipoCambio) AND IdMoneda = 1)
		SET @FECHA_TIPOCAMBIO= DATEADD(DAY, @Dias, @FechaTipoCambio) 
		SET @Dias = @Dias - 1
	END

	-- Return the result of the function
	RETURN @FECHA_TIPOCAMBIO

END

