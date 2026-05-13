CREATE TABLE [dbo].[CO_Formulas] (
    [IdFormula]    INT      NOT NULL,
    [FechaInicial] DATE     NULL,
    [FechaFinal]   DATETIME NULL,
    [Activo]       BIT      NULL,
    CONSTRAINT [PK_CO_FormulasPetroleo] PRIMARY KEY CLUSTERED ([IdFormula] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

