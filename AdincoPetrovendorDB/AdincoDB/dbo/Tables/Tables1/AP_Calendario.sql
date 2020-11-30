CREATE TABLE [dbo].[AP_Calendario] (
    [IdFecha]      DATE           NOT NULL,
    [Anio]         SMALLINT       NULL,
    [Mes]          TINYINT        NULL,
    [Dia]          TINYINT        NULL,
    [DiaDeSemana]  TINYINT        NULL,
    [NombreDia]    NVARCHAR (MAX) NULL,
    [DayName]      NVARCHAR (MAX) NULL,
    [NombreMes]    NVARCHAR (MAX) NULL,
    [MonthName]    NVARCHAR (MAX) NULL,
    [DiaDeAño]     SMALLINT       NULL,
    [Cuarto]       TINYINT        NULL,
    [PrimerDiaMes] DATE           NULL,
    [UltimoDiaMes] DATE           NULL,
    [InicioDia]    DATETIME       NULL,
    [TerminoDia]   DATETIME       NULL,
    [DiaLaborable] BIT            NULL,
    [FinDeSemana]  BIT            NULL,
    [DiaFeriado]   BIT            NULL,
    [Descripcion]  NVARCHAR (MAX) NULL,
    CONSTRAINT [PK__AP_Calen__8D0F205ADE788876] PRIMARY KEY CLUSTERED ([IdFecha] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);


GO
CREATE NONCLUSTERED INDEX [idx_AnioMesDia]
    ON [dbo].[AP_Calendario]([Anio] ASC, [Mes] ASC, [Dia] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

