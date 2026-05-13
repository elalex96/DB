CREATE TABLE [dbo].[ME_Seccion] (
    [IdSeccion]          INT           IDENTITY (1, 1) NOT NULL,
    [IdMatrizEvaluacion] INT           NOT NULL,
    [Ponderacion]        INT           NOT NULL,
    [Nombre]             VARCHAR (MAX) NULL,
    [Activo]             BIT           NULL,
    CONSTRAINT [PK_ME_Seccion] PRIMARY KEY CLUSTERED ([IdSeccion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ME_Seccion_ME_MatrizEvaluacion2] FOREIGN KEY ([IdMatrizEvaluacion]) REFERENCES [dbo].[ME_MatrizEvaluacion] ([IdMatrizEvaluacion])
);

