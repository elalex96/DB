create function [dbo].[GetTipoCambioActual] 
(@IdMoneda int,
@Fecha datetime)
returns @TABLA_TC TABLE (TipoCambio DECIMAL(12,4),Fecha datetime, IdMoneda int) 
AS 
BEGIN 
DECLARE @TIPO_CAMBIO DECIMAL 

INSERT INTO @TABLA_TC
SELECT TCD.TipoCambio, @Fecha, @IdMoneda
FROM Adinco.dbo.PV_TipoMoneda TM 
INNER JOIN Adinco.dbo.CO_TipoCambioDiario AS TCD ON TCD.IdMoneda = TM.IdMoneda 
AND DAY(TCD.Fecha) = DAY(@Fecha)
AND MONTH(TCD.Fecha) = MONTH(@Fecha)
AND YEAR(TCD.Fecha) = YEAR(@Fecha)
AND TM.IdMoneda = @IdMoneda


SET @TIPO_CAMBIO = (SELECT IDENT_CURRENT(TipoCambio)
FROM @TABLA_TC)

IF @TIPO_CAMBIO IS NULL 
BEGIN 
DELETE @TABLA_TC
INSERT INTO @TABLA_TC 
SELECT TOP 1 TCD.TipoCambio, TCD.Fecha, @IdMoneda
FROM Adinco.dbo.PV_TipoMoneda TM 
INNER JOIN Adinco.dbo.CO_TipoCambioDiario AS TCD ON TCD.IdMoneda = TM.IdMoneda 
AND TM.IdMoneda = @IdMoneda
WHERE TCD.Fecha < @Fecha AND TCD.TipoCambio IS NOT NULL
ORDER BY TCD.Fecha DESC
END 

RETURN 
END 
