CREATE TABLE [dbo].[S_SituacionContribuyente] (
    [IdSituacion] INT          IDENTITY (1, 1) NOT NULL,
    [Situacion]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_S_SituacionContribuyente] PRIMARY KEY CLUSTERED ([IdSituacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

