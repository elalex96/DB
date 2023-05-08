CREATE PROCEDURE ObtenerFechasFaltantesProduccion
AS
BEGIN
    CREATE TABLE #Fechas (Fecha DATETIME)

    DECLARE @Inicio DateTime,
            @Fin DateTime

    SELECT @Fin = DATEADD(DAY, -1, GETDATE())

    SELECT TOP 1
        @Inicio = Fecha
    FROM PR_FechaInicioCargaProduccion

    ;WITH FECHAS (fecha)
    AS (SELECT @Inicio fecha
        UNION ALL
        SELECT DATEADD(DAY, 1, fecha) fecha
        FROM FECHAS
        WHERE fecha <= @Fin
       )
    INSERT INTO #Fechas
    SELECT fecha
    FROM FECHAS
    OPTION (maxrecursion 0)


    SELECT CAST(#Fechas.Fecha AS DATE) Fecha
    FROM #Fechas
        LEFT JOIN PR_ProdDiaria_Previo	(NOLOCK)
            ON CAST(#Fechas.Fecha AS DATE) = CAST(PR_ProdDiaria_Previo.Fecha AS DATE)
    WHERE PR_ProdDiaria_Previo.Fecha IS NULL
	ORDER BY #Fechas.Fecha

END






