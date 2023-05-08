
-- =============================================
-- Author:		Daniel AC
-- Create date: 03/01/2020
-- Description: Realiza la conversión de pesos mexicanos a dolares según la fecha de tipo de cambio
-- =============================================

CREATE  FUNCTION [dbo].[FN_PesosDolaresTipoCambio_SinIteracion]
(
	-- Add the parameters for the function here
	@MontoMXN FLOAT,
	@FechaTipoCambio DATE
)
RETURNS FLOAT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @MontoUSD FLOAT;
	DECLARE @TipoCambioMXN FLOAT;
	DECLARE @Dias INT = -1;

	-- Add the T-SQL statements to compute the return value here
	SET @TipoCambioMXN = (SELECT TipoCambio FROM Adinco.dbo.CO_TipoCambioDiario WHERE Fecha = @FechaTipoCambio AND IdMoneda = 1)

	IF  ISNULL(@TipoCambioMXN,0)>0
	BEGIN
		SET @MontoUSD = (@MontoMXN / @TipoCambioMXN);
	END
	ELSE 
	BEGIN 
		SET @MontoUSD =0
	END 

	

	-- Return the result of the function
	RETURN @MontoUSD;

END
