
use Petrovendor
go
DROP FUNCTION IF EXISTS FN_PesosDolaresTipoCambio
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 12/07/2018
-- Description: Realiza la convercion de pesos mexicanos a dolares segun la fecha de tipo de cambio
-- =============================================
-- Author:		Jose Roman
-- Create date: 24-10-2018
-- Description: Se agrega un while por si ese dia no se guardo el tipo de cambio, tome el de un dia anterior
-- =============================================
-- Author:		Luis David
-- Create date: 01/09/2022
-- Description: Se agrega el top 1 al tipo de cambio
-- =============================================
CREATE FUNCTION FN_PesosDolaresTipoCambio
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
	SET @TipoCambioMXN = (SELECT top 1 TipoCambio FROM Adinco.dbo.CO_TipoCambioDiario WHERE Fecha = @FechaTipoCambio AND IdMoneda = 1)

	WHILE @TipoCambioMXN IS NULL
	BEGIN
		SET @TipoCambioMXN = (SELECT top 1 TipoCambio FROM Adinco.dbo.CO_TipoCambioDiario WHERE Fecha = DATEADD(DAY, @Dias, @FechaTipoCambio) AND IdMoneda = 1)
		SET @Dias = @Dias - 1
	END

	SET @MontoUSD = (@MontoMXN / @TipoCambioMXN);

	-- Return the result of the function
	RETURN @MontoUSD;

END
