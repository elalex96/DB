CREATE TABLE [dbo].[CO_ProgramaImplementaFrecuencia] (
    [Id]     INT          NOT NULL,
    [Nombre] VARCHAR (50) NOT NULL,
    [Activo] BIT          NOT NULL,
    CONSTRAINT [PK_CO_ProgramaImplementaFrecuencia] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

