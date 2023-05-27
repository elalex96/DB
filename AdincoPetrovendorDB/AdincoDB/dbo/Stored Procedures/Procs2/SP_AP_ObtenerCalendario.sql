CREATE PROCEDURE [dbo].[SP_AP_ObtenerCalendario]
    @ContratoId INT = 0,
    @UsuarioId INT = 0
AS
BEGIN
    DECLARE @HOY DATE = GETDATE();

    CREATE TABLE #AP_Calendario
    (
        [IdFecha] DATE NOT NULL,
        [Anio] INT NULL,
        [Mes] INT NULL,
        [Dia] INT NULL,
        [DiaDeSemana] INT NULL,
        [NombreDia] VARCHAR(100) NULL,
        [DayName] VARCHAR(100) NULL,
        [NombreMes] VARCHAR(100) NULL,
        [MonthName] VARCHAR(100) NULL,
        [DiaDeAño] INT NULL,
        [Cuarto] INT NULL,
        [PrimerDiaMes] DATE NULL,
        [UltimoDiaMes] DATE NULL,
        [InicioDia] DATETIME NULL,
        [TerminoDia] DATETIME NULL,
        [DiaLaborable] BIT NULL,
        [FinDeSemana] BIT NULL,
        [DiaFeriado] BIT NULL,
        [Descripcion] VARCHAR(1500) NULL,
        [AgregadoEn] DATETIME NULL
    );

    INSERT INTO #AP_Calendario
    (
        [IdFecha],
        [Anio],
        [Mes],
        [Dia],
        [DiaDeSemana],
        [NombreDia],
        [DayName],
        [NombreMes],
        [MonthName],
        [DiaDeAño],
        [Cuarto],
        [PrimerDiaMes],
        [UltimoDiaMes],
        [InicioDia],
        [TerminoDia],
        [DiaLaborable],
        [FinDeSemana],
        [DiaFeriado],
        [Descripcion],
        [AgregadoEn]
    )
    SELECT [IdFecha],
           [Anio],
           [Mes],
           [Dia],
           [DiaDeSemana],
           [NombreDia],
           [DayName],
           [NombreMes],
           [MonthName],
           [DiaDeAño],
           [Cuarto],
           [PrimerDiaMes],
           [UltimoDiaMes],
           [InicioDia],
           [TerminoDia],
           ISNULL([DiaLaborable], 0) AS [DiaLaborable],
           ISNULL([FinDeSemana], 0) AS [FinDeSemana],
           ISNULL([DiaFeriado], 0) AS [DiaFeriado],
           [Descripcion],
           GETDATE()
    FROM [Adinco].[dbo].[AP_Calendario] (NOLOCK)
    WHERE MONTH([IdFecha]) = MONTH(@HOY)
          AND YEAR([IdFecha]) = YEAR(@HOY)
    ORDER BY [IdFecha] ASC

    INSERT INTO #AP_Calendario
    (
        [IdFecha],
        [Anio],
        [Mes],
        [Dia],
        [DiaDeSemana],
        [NombreDia],
        [DayName],
        [NombreMes],
        [MonthName],
        [DiaDeAño],
        [Cuarto],
        [PrimerDiaMes],
        [UltimoDiaMes],
        [InicioDia],
        [TerminoDia],
        [DiaLaborable],
        [FinDeSemana],
        [DiaFeriado],
        [Descripcion],
        [AgregadoEn]
    )
    SELECT [AP_Calendario].[IdFecha],
           [AP_Calendario].[Anio],
           [AP_Calendario].[Mes],
           [AP_Calendario].[Dia],
           [AP_Calendario].[DiaDeSemana],
           [AP_Calendario].[NombreDia],
           [AP_Calendario].[DayName],
           [AP_Calendario].[NombreMes],
           [AP_Calendario].[MonthName],
           [AP_Calendario].[DiaDeAño],
           [AP_Calendario].[Cuarto],
           [AP_Calendario].[PrimerDiaMes],
           [AP_Calendario].[UltimoDiaMes],
           [AP_Calendario].[InicioDia],
           [AP_Calendario].[TerminoDia],
           ISNULL([AP_Calendario].[DiaLaborable], 0) AS [DiaLaborable],
           ISNULL([AP_Calendario].[FinDeSemana], 0) AS [FinDeSemana],
           ISNULL([AP_Calendario].[DiaFeriado], 0) AS [DiaFeriado],
           [AP_Calendario].[Descripcion],
           GETDATE()
    FROM [Adinco].[dbo].[AP_Calendario] (NOLOCK)
        LEFT JOIN #AP_Calendario
            ON [AP_Calendario].[IdFecha] = #AP_Calendario.IdFecha
    WHERE [AP_Calendario].IdFecha < '20500101'
          AND #AP_Calendario.[IdFecha] IS NULL
    GROUP BY [AP_Calendario].[IdFecha],
             [AP_Calendario].[Anio],
             [AP_Calendario].[Mes],
             [AP_Calendario].[Dia],
             [AP_Calendario].[DiaDeSemana],
             [AP_Calendario].[NombreDia],
             [AP_Calendario].[DayName],
             [AP_Calendario].[NombreMes],
             [AP_Calendario].[MonthName],
             [AP_Calendario].[DiaDeAño],
             [AP_Calendario].[Cuarto],
             [AP_Calendario].[PrimerDiaMes],
             [AP_Calendario].[UltimoDiaMes],
             [AP_Calendario].[InicioDia],
             [AP_Calendario].[TerminoDia],
             ISNULL([AP_Calendario].[DiaLaborable], 0),
             ISNULL([AP_Calendario].[FinDeSemana], 0),
             ISNULL([AP_Calendario].[DiaFeriado], 0),
             [AP_Calendario].[Descripcion]
    ORDER BY IdFecha ASC

    SELECT [IdFecha],
           [Anio],
           [Mes],
           [Dia],
           [DiaDeSemana],
           [NombreDia],
           [DayName],
           [NombreMes],
           [MonthName],
           [DiaDeAño],
           [Cuarto],
           [PrimerDiaMes],
           [UltimoDiaMes],
           [InicioDia],
           [TerminoDia],
           [DiaLaborable],
           [FinDeSemana],
           [DiaFeriado],
           [Descripcion]
    FROM #AP_Calendario
    ORDER BY AgregadoEn ASC,
             IdFecha ASC
END