CREATE TABLE [dbo].[ME_TiposMatriz] (
    [IdTipoEvaluacion] INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]           VARCHAR (MAX) NOT NULL,
    [Ponderacion]      INT           NULL,
    CONSTRAINT [PK_ME_TiposMatriz] PRIMARY KEY CLUSTERED ([IdTipoEvaluacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

