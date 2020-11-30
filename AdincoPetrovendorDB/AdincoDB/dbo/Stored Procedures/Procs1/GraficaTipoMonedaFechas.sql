-- =============================================
--Select * from co_contrato
-- Author:		Reyna O.
-- Create date: Extrae Datos para tipoMoneda 1 
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GraficaTipoMonedaFechas]-- 3,10061
    @idContrato INT,
    @idUsuario INT = NULL,
	@FechaInicial DATE,
	@FechaFinal DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;
	DECLARE @idContratista INT=0,@FechaInicialSP DATE, @FechaFinalSP DATE;
	SELECT @idContratista= IdContratista FROM dbo.CO_Contrato WHERE IdContrato=@idContrato;
	IF(@FechaFinal<@FechaInicial)
	BEGIN
	SET @FechaInicialSP=@FechaFinal;
	SET @FechaFinalSP=@FechaInicial;
    END
	ELSE
    BEGIN
	SET @FechaInicialSP=@FechaInicial;
	SET @FechaFinalSP=@FechaFinal;
    END

    IF (@idContratista IN ( 10020,10024,2 ,10061))
    BEGIN
        SELECT
               DATENAME(DAY, Fecha) + ' ' + DATENAME(MONTH, Fecha) + ' ' + DATENAME(YEAR, Fecha) AS Fecha,
               TipoCambio,
               'line' AS type
        FROM CO_TipoCambioDiario tf
        WHERE IdMoneda = 1
		AND tf.Fecha BETWEEN @FechaInicialSP AND @FechaFinalSP
        ORDER BY tf.Fecha DESC;
    END;
    ELSE
    BEGIN
        SELECT 
               DATENAME(DAY, Fecha) + ' ' + DATENAME(MONTH, Fecha) + ' ' + DATENAME(YEAR, Fecha) AS Fecha,
               TipoCambio,
               'area' AS type
        FROM CO_TipoCambioDiario tf
        WHERE IdMoneda = 1
		AND tf.Fecha BETWEEN @FechaInicialSP AND @FechaFinalSP
        ORDER BY tf.Fecha DESC;
    END;

END;
