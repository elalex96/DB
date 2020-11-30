-- =============================================
-- Author:		Reyna O.
-- Create date: Extrae Datos para tipoMoneda 1 
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GraficaTipoMoneda1]-- 3,10061
    @idContrato INT,
    @idUsuario INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;
	DECLARE @idContratista INT=0;
	SELECT @idContratista=
	IdContratista FROM dbo.CO_Contrato WHERE IdContrato=@idContrato;

    IF (@idContratista IN ( 10020,10024,2 ))
    BEGIN
        SELECT TOP 15
               DATENAME(DAY, Fecha) + ' ' + DATENAME(MONTH, Fecha) + ' ' + DATENAME(YEAR, Fecha) AS Fecha,
               TipoCambio,
               'line' AS type
        FROM CO_TipoCambioDiario tf
        WHERE IdMoneda = 1
        ORDER BY tf.Fecha DESC;
    END;
    ELSE
    BEGIN
        SELECT TOP 90
               DATENAME(DAY, Fecha) + ' ' + DATENAME(MONTH, Fecha) + ' ' + DATENAME(YEAR, Fecha) AS Fecha,
               TipoCambio,
               'area' AS type
        FROM CO_TipoCambioDiario tf
        WHERE IdMoneda = 1
        ORDER BY tf.Fecha DESC;
    END;

END;

