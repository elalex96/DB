CREATE TABLE [dbo].[MM_CriterioEvaluacionTecnica] (
    [IdCriterioEvaluacion] INT            IDENTITY (10000, 1) NOT NULL,
    [Criterio]             NVARCHAR (MAX) NULL,
    [Descripcion]          NVARCHAR (MAX) NULL,
    [Criterion]            NVARCHAR (MAX) NULL,
    [Description]          NVARCHAR (MAX) NULL,
    [Activo]               BIT            NULL,
    CONSTRAINT [PK_MM_CriteriosEvaluacionTecnica] PRIMARY KEY CLUSTERED ([IdCriterioEvaluacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

