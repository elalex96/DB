CREATE TABLE [dbo].[CO_Formulas_Detalle] (
    [IdFormula]          INT           NOT NULL,
    [IdTipoHidrocarburo] INT           NOT NULL,
    [API_RangoIni]       FLOAT (53)    NOT NULL,
    [API_RangoFIn]       FLOAT (53)    NULL,
    [Constante]          FLOAT (53)    NULL,
    [Constante_LLS]      FLOAT (53)    NULL,
    [Constante_Brent]    FLOAT (53)    NULL,
    [Constante_S]        FLOAT (53)    NULL,
    [Constante1_API]     FLOAT (53)    NULL,
    [Constante2_API]     FLOAT (53)    NULL,
    [Elevacion_API]      INT           NULL,
    [FormulaCompleta]    VARCHAR (500) NULL,
    CONSTRAINT [PK_CO_Formulas_Detalle] PRIMARY KEY CLUSTERED ([IdFormula] ASC, [IdTipoHidrocarburo] ASC, [API_RangoIni] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_Formulas_CO_Formulas_Detalle] FOREIGN KEY ([IdFormula]) REFERENCES [dbo].[CO_Formulas] ([IdFormula])
);

