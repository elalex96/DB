CREATE PROCEDURE [dbo].[SP_CO_GenerarTipoDeCambioPorSerieBanxicoMXN] @FilasTB TY_ListaCambioDiario READONLY
AS
BEGIN
    DECLARE @IdMoneda INT;

    SELECT @IdMoneda = IdMoneda
    FROM PV_TipoMoneda (NOLOCK)
    WHERE TipoMonedaCorto = 'MXN';

    CREATE TABLE #TBListaCambioDiario
    (
        [Fecha] DATE NULL,
        [TipoCambio] DECIMAL(18, 5) NULL
    );

    INSERT INTO #TBListaCambioDiario
    (
        Fecha,
        TipoCambio
    )
    SELECT Fecha,
           TipoCambio
    FROM @FilasTB

    INSERT INTO CO_TipoCambioDiario
    (
        IdMoneda,
        Fecha,
        TipoCambio,
        IdUsuario,
        Activo,
        CreadoPor
    )
    SELECT @IdMoneda,
           #TBListaCambioDiario.Fecha,
           #TBListaCambioDiario.TipoCambio,
           1,
           1,
           1
    FROM #TBListaCambioDiario
        LEFT JOIN CO_TipoCambioDiario (NOLOCK)
            ON CAST(#TBListaCambioDiario.Fecha AS DATE) = CAST(CO_TipoCambioDiario.Fecha AS DATE)
               AND CO_TipoCambioDiario.IdMoneda = @IdMoneda
    WHERE CO_TipoCambioDiario.IdTipoCambio IS NULL
    ORDER BY #TBListaCambioDiario.Fecha

	SELECT 'Correcto'
END
