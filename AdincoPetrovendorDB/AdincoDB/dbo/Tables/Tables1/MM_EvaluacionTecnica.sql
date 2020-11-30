CREATE TABLE [dbo].[MM_EvaluacionTecnica] (
    [IdEvaluacionTecnica] INT IDENTITY (1, 1) NOT NULL,
    [IdOferta]            INT NOT NULL,
    CONSTRAINT [PK_MM_EvaluacionTecnica] PRIMARY KEY CLUSTERED ([IdEvaluacionTecnica] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_EvaluacionTecnica_MM_Oferta] FOREIGN KEY ([IdOferta]) REFERENCES [dbo].[MM_Oferta] ([IdOferta])
);

