CREATE PROCEDURE GenerarTipoDeCambioPorSerieBanxicoNoDolar
    @Fecha DATETIME,
    @SerieBanxico varchar(50),
    @TipoCambio MONEY
AS
BEGIN
    DECLARE @InicioMes DATETIME,
            @FinMes DATETIME,
            @IdMoneda INT

    set @InicioMes = DATEADD(DAY, 1, EOMONTH(@Fecha, -1))
    set @finMes = DATEADD(DAY, -1, EOMONTH(@Fecha))

    CREATE TABLE #DiasFaltantes (FechaFaltante datetime)
    CREATE TABLE #FechasMes (Fecha DATETIME)

    SELECT @IdMoneda = IdMoneda
    FROM PV_TipoMoneda (NOLOCK)
    WHERE SerieBanxico = @SerieBanxico
	
	;WITH FECHAS (fecha)
    AS (SELECT @InicioMes fecha
        UNION ALL
        SELECT DATEADD(DAY, 1, fecha) fecha
        FROM FECHAS
        WHERE fecha <= @finMes
       )
    INSERT INTO #FechasMes
    SELECT fecha
    FROM FECHAS
    OPTION (maxrecursion 0)


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
           #FechasMes.Fecha,
		   CASE 
		   WHEN ISNULL(@TipoCambio,0) <> 0
		   THEN
				(1/@TipoCambio)
		   ELSE
				@TipoCambio
		   END
           ,
           1,
           1,
           1
    FROM #FechasMes
        LEFT JOIN CO_TipoCambioDiario (NOLOCK)
            ON CAST(#FechasMes.Fecha AS DATE) = CAST(CO_TipoCambioDiario.Fecha AS DATE)
               AND CO_TipoCambioDiario.IdMoneda = @IdMoneda
    WHERE CO_TipoCambioDiario.IdTipoCambio IS NULL
    ORDER BY #FechasMes.Fecha



END