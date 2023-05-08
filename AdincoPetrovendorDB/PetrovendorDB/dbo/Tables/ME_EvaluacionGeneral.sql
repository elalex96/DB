CREATE TABLE [dbo].[ME_EvaluacionGeneral] (
    [Activo]              BIT           NOT NULL,
    [IdEvaluacionGeneral] INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]              VARCHAR (MAX) NOT NULL,
    [PonderacionGeneral]  INT           NOT NULL
);

