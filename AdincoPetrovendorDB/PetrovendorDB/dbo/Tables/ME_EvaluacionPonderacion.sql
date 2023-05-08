CREATE TABLE [dbo].[ME_EvaluacionPonderacion] (
    [IdEvaluacionPonderacion] INT        IDENTITY (1, 1) NOT NULL,
    [IdMatrizEvaluacion]      INT        NOT NULL,
    [Ponderacion]             FLOAT (53) NOT NULL
);

