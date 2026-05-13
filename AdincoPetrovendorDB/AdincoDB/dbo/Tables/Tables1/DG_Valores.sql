CREATE TABLE [dbo].[DG_Valores] (
    [IdValor]       INT        IDENTITY (1, 1) NOT NULL,
    [IdSerie]       INT        NULL,
    [Fecha]         DATE       NULL,
    [Valor]         FLOAT (53) NULL,
    [posicionSerie] INT        NULL,
    CONSTRAINT [PK_DG_Valores] PRIMARY KEY CLUSTERED ([IdValor] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

