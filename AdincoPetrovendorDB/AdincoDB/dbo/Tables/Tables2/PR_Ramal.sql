CREATE TABLE [dbo].[PR_Ramal] (
    [Id]          INT             IDENTITY (1, 1) NOT NULL,
    [Clave]       VARCHAR (20)    NOT NULL,
    [Nombre]      VARCHAR (200)   NOT NULL,
    [Descripcion] NVARCHAR (2000) NOT NULL,
    [Estatus]     TINYINT         NOT NULL,
    [Bloque]      INT             NOT NULL,
    CONSTRAINT [PK_PR_Ramal] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Ramal_Bloque] FOREIGN KEY ([Bloque]) REFERENCES [dbo].[PR_Bloque] ([Id])
);

