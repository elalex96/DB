-- =============================================
-- Author:	Reyna Olvera
-- ALTER date: 17/08/2022
-- Description:	Se modifica para que no planche tipos de cambios obtenidos de SDK (Solo se agrego un where)
-- =============================================
CREATE PROCEDURE [dbo].GenerarPromedioMensualTipoDeCambio
AS
BEGIN
    --Revisar es el dia ultimo del mes 
	--Si es asi entonces genera el promedio e insertalo o actualiza
	--En caso de que no sea el dia ultimo revisar si existe el mes anterior con el promedio, si no es asi promediar y generarlo o actualizarlo
	DECLARE @UltimoDiaMes DATETIME,
			@IdTipoCambioMensual INT,
			@PromedioTipoCambio DECIMAL(12, 4),
			@Error nvarchar(500),
			@FechaActual DATETIME
	
	SELECT @FechaActual = GETDATE()

	SELECT @UltimoDiaMes = EOMONTH( @FechaActual )
	

	SELECT @PromedioTipoCambio = AVG(TipoCambio) FROM CO_TipoCambioDiario WHERE IdMoneda = 1 AND MONTH(Fecha) = MONTH(@FechaActual) AND YEAR(Fecha) = YEAR(@FechaActual)

	IF(@PromedioTipoCambio IS NULL)
	BEGIN
		SELECT @Error = CONCAT('No existe informacion en CO_TipoCambioDiario para promediar en el mes ', MONTH(@FechaActual), ' del año ',  YEAR(@FechaActual))
		RAISERROR (@Error, 16, 1);
		RETURN -1
	END

	--Si es el dia ultimo del mes
	IF(CONVERT(VARCHAR,@UltimoDiaMes, 112) = CONVERT(VARCHAR,@FechaActual, 112))
	BEGIN
		SELECT @IdTipoCambioMensual = IdTipoCambioMensual FROM CO_TipoCambioMensual WHERE IdMoneda = 1 AND IdMes = MONTH(@FechaActual) AND Anio = YEAR(@FechaActual)
		
		IF(ISNULL(@IdTipoCambioMensual, 0) = 0)
		BEGIN
			INSERT INTO CO_TipoCambioMensual(IdMoneda, Anio, IdMes, TipoCambio, IdUsuario, FecMovto, Activo, CreadoPor)
			SELECT 1, YEAR(@FechaActual), MONTH(@FechaActual), @PromedioTipoCambio, 1, 1, 1, 1
		END
		ELSE
		BEGIN
			UPDATE CO_TipoCambioMensual SET Activo = 1, TipoCambio = @PromedioTipoCambio
			WHERE IdMoneda = 1 AND IdMes = MONTH(@FechaActual) AND Anio = YEAR(@FechaActual) AND ObtenidoSDK = 0
		END
	END
	ELSE
	BEGIN
		--si no es el dia ultimo revisar el mes anterior si ya esta insertado
		DECLARE @IdTipoCambioMensualAnterior INT,
				@FechaMesAnterior DATETIME,
				@PromedioTipoCambioAnterior DECIMAL(12, 4)

		SELECT @FechaMesAnterior = DATEADD(MONTH, -1, @FechaActual)

		SELECT @PromedioTipoCambioAnterior = AVG(TipoCambio) FROM CO_TipoCambioDiario WHERE IdMoneda = 1 AND MONTH(Fecha) = MONTH(@FechaMesAnterior) AND YEAR(Fecha) = YEAR(@FechaMesAnterior)

		IF(@PromedioTipoCambioAnterior IS NULL)
		BEGIN
			SELECT @Error = CONCAT('No existe informacion en CO_TipoCambioDiario para promediar en el mes ', MONTH(@FechaMesAnterior), ' del año ',  YEAR(@FechaMesAnterior))
			RAISERROR (@Error, 16, 1);
			RETURN -1
		END

		SELECT @IdTipoCambioMensualAnterior = IdTipoCambioMensual FROM CO_TipoCambioMensual WHERE IdMoneda = 1 AND IdMes = MONTH(@FechaMesAnterior) AND Anio = YEAR(@FechaMesAnterior)
		
		IF(ISNULL(@IdTipoCambioMensualAnterior, 0) = 0)
		BEGIN
			INSERT INTO CO_TipoCambioMensual(IdMoneda, Anio, IdMes, TipoCambio, IdUsuario, FecMovto, Activo, CreadoPor)
			SELECT 1, YEAR(@FechaMesAnterior), MONTH(@FechaMesAnterior), @PromedioTipoCambioAnterior, 1, 1, 1, 1
		END
		ELSE
		BEGIN
			UPDATE CO_TipoCambioMensual SET Activo = 1, TipoCambio = @PromedioTipoCambioAnterior
			WHERE IdMoneda = 1 AND IdMes = MONTH(@FechaMesAnterior) AND Anio = YEAR(@FechaMesAnterior)  AND ObtenidoSDK = 0
		END
	END
END