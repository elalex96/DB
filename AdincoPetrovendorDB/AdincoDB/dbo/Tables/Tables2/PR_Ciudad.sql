CREATE TABLE [dbo].[PR_Ciudad] (
    [Id]               INT             IDENTITY (1, 1) NOT NULL,
    [Clave]            VARCHAR (20)    NOT NULL,
    [Nombre]           VARCHAR (200)   NOT NULL,
    [Descripcion]      NVARCHAR (2000) NULL,
    [Estatus]          TINYINT         NOT NULL,
    [Estado]           INT             NOT NULL,
    [IdCiudadApiClima] INT             NULL,
    CONSTRAINT [PK_PR_Ciudad] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Ciudad_Ciudad] FOREIGN KEY ([Id]) REFERENCES [dbo].[PR_Ciudad] ([Id]),
    CONSTRAINT [FK_Ciudad_Estado] FOREIGN KEY ([Estado]) REFERENCES [dbo].[PR_Estado] ([Id])
);

