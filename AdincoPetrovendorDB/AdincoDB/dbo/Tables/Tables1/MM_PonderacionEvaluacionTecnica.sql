CREATE TABLE [dbo].[MM_PonderacionEvaluacionTecnica] (
    [IdPonderacionEvaluacionTecnica] INT            IDENTITY (10000, 1) NOT NULL,
    [Ponderacion]                    NVARCHAR (MAX) NULL,
    [Activo]                         BIT            NULL,
    CONSTRAINT [PK_MM_PonderacionEvaluacionTecnica] PRIMARY KEY CLUSTERED ([IdPonderacionEvaluacionTecnica] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

