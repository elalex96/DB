CREATE TABLE [dbo].[PR_Existencia] (
    [Id]               INT             IDENTITY (1, 1) NOT NULL,
    [Fecha]            DATETIME        NOT NULL,
    [Estacion]         INT             NOT NULL,
    [Tanque]           INT             NOT NULL,
    [Medida]           DECIMAL (24, 8) NOT NULL,
    [Existencia]       DECIMAL (24, 8) NOT NULL,
    [Modificado]       DATETIME        NULL,
    [ModificadoPor]    VARCHAR (200)   NULL,
    [ModificadoServer] DATETIME        NULL,
    CONSTRAINT [PK_PR_Existencia] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Existencia_Estacion] FOREIGN KEY ([Estacion]) REFERENCES [dbo].[PR_Estacion] ([Id]),
    CONSTRAINT [FK_Existencia_Tanque] FOREIGN KEY ([Tanque]) REFERENCES [dbo].[PR_Tanque] ([Id])
);

