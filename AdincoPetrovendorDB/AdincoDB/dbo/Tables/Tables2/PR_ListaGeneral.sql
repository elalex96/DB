CREATE TABLE [dbo].[PR_ListaGeneral] (
    [Id]      INT           IDENTITY (1, 1) NOT NULL,
    [Grupo]   INT           NOT NULL,
    [Clave]   VARCHAR (20)  NOT NULL,
    [Nombre]  VARCHAR (200) NOT NULL,
    [Estatus] TINYINT       NOT NULL,
    [Rubro]   INT           NULL,
    CONSTRAINT [PK_PR_ListaGeneral] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ListaGeneral_Grupo] FOREIGN KEY ([Grupo]) REFERENCES [dbo].[PR_Grupo] ([Id])
);

