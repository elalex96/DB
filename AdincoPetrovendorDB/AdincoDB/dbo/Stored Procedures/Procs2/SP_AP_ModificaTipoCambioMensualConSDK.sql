
GO
-- =============================================
-- Author:	Reyna Olvera
--  date: 17/08/2022
-- Description:	modifica  meses con los nuevos tipos de cambio promedio verificado por SDK banxico
-- =============================================
CREATE PROCEDURE [dbo].SP_AP_ModificaTipoCambioMensualConSDK
	@IdUsuario  INT,
	@IdMoneda INT,
	@Fecha DATE,
	@DatoBanxico FLOAT,
	@DatoCalculado FLOAT
AS
BEGIN	
		DECLARE	@IdTipoCambioMensual INT;
		SELECT @IdTipoCambioMensual = IdTipoCambioMensual FROM CO_TipoCambioMensual WHERE IdMoneda = @IdMoneda AND IdMes = MONTH(@Fecha) AND Anio = YEAR(@Fecha);
		
		IF(ISNULL(@IdTipoCambioMensual, 0) = 0)
		BEGIN
			INSERT INTO CO_TipoCambioMensual(IdMoneda, Anio, IdMes, TipoCambio,TipoCambioBanxico, ObtenidoSDK,IdUsuario, FecMovto, Activo, CreadoPor)
			SELECT @IdMoneda, YEAR(@Fecha), MONTH(@Fecha),@DatoCalculado, @DatoBanxico,1, @IdUsuario, 1, 1, @IdUsuario;
		END
		ELSE
		BEGIN
			UPDATE CO_TipoCambioMensual SET 
			Activo = 1, 
			TipoCambio = @DatoCalculado,
			TipoCambioBanxico = @DatoBanxico,
			ObtenidoSDK = 1
			WHERE IdMoneda = @IdMoneda AND IdMes = MONTH(@Fecha) AND Anio = YEAR(@Fecha)
		END
END 