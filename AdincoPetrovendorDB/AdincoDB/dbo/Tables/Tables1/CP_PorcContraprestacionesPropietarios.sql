CREATE TABLE [dbo].[CP_PorcContraprestacionesPropietarios] (
    [IdFechaIni]       DATETIME   NOT NULL,
    [FechaFin]         DATETIME   NULL,
    [MayorA]           INT        NOT NULL,
    [MenorIgualA]      INT        NULL,
    [Porcentaje]       FLOAT (53) NULL,
    [BitGasNoAsociado] BIT        NOT NULL,
    CONSTRAINT [PK_CP_PorcContraprestacionesPropietarios] PRIMARY KEY CLUSTERED ([IdFechaIni] ASC, [MayorA] ASC, [BitGasNoAsociado] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

