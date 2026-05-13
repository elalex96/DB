-- =============================================
-- Author:Daniel AC
-- Create date: 03/01/2020
-- Description: Realiza la conversión de dolares a pesos mexicanos segun la fecha de tipo de cambio
-- =============================================
create FUNCTION [dbo].[FN_DolaresPesosTipoCambio_SinIteracion]
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
	DECLARE @Dias INT = -1
	-- Add the T-SQL statements to compute the return value here
	SET @TipoCambioMXN = (SELECT TipoCambio FROM Adinco.dbo.CO_TipoCambioDiario WHERE Fecha = @FechaTipoCambio AND IdMoneda = 1);

	IF ISNULL(@TipoCambioMXN,0)> 0
	BEGIN
		SET @MontoMXN = (@MontoUSD * @TipoCambioMXN);
	END
	ELSE
    BEGIN 
	  SET @MontoMXN = 0
	END 		

	-- Return the result of the function
	RETURN @MontoMXN;

END