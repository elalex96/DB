CREATE function [dbo].[GetTipoCambioActualScalar]   
(@IdMoneda int,
@Fecha datetime)
returns DECIMAL(12,4)
AS   
BEGIN 	
	DECLARE @TIPO_CAMBIO DECIMAL(12,4) 
	 
	SET @TIPO_CAMBIO =(
	SELECT TCD.TipoCambio
	FROM Adinco.dbo.PV_TipoMoneda TM 
	INNER JOIN Adinco.dbo.CO_TipoCambioDiario  AS TCD ON TCD.IdMoneda = TM.IdMoneda 
	AND DAY(TCD.Fecha) = DAY(@Fecha)
	AND MONTH(TCD.Fecha) = MONTH(@Fecha)
	AND YEAR(TCD.Fecha) = YEAR(@Fecha)
	AND TM.IdMoneda  = @IdMoneda)

	 
	IF @TIPO_CAMBIO IS NULL 
	BEGIN 

		SET @TIPO_CAMBIO = (
	   	SELECT TOP 1 TCD.TipoCambio
		FROM Adinco.dbo.PV_TipoMoneda TM 
		INNER JOIN Adinco.dbo.CO_TipoCambioDiario  AS TCD ON TCD.IdMoneda = TM.IdMoneda 
		AND TM.IdMoneda  = @IdMoneda
		WHERE TCD.Fecha < @Fecha  AND TCD.TipoCambio IS NOT NULL
		ORDER BY TCD.Fecha DESC)
	END 	
		
	RETURN @TIPO_CAMBIO   	  
 END 






