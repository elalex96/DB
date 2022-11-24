CREATE TABLE [dbo].[PR_Zona] (
    [Id]          INT             IDENTITY (1, 1) NOT NULL,
    [Clave]       VARCHAR (20)    NOT NULL,
    [Nombre]      VARCHAR (200)   NOT NULL,
    [Descripcion] NVARCHAR (2000) NOT NULL,
    [Estatus]     TINYINT         NOT NULL,
    [Ramal]       INT             NOT NULL,
    CONSTRAINT [PK_PR_Zona] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Zona_Ramal] FOREIGN KEY ([Ramal]) REFERENCES [dbo].[PR_Ramal] ([Id])
);

