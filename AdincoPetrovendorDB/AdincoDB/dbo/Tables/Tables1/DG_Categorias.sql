CREATE TABLE [dbo].[DG_Categorias] (
    [Id_Categoria] INT           IDENTITY (1, 1) NOT NULL,
    [categorias]   VARCHAR (MAX) NULL,
    [categories]   VARCHAR (MAX) NULL,
    CONSTRAINT [PK_DG_Categorias] PRIMARY KEY CLUSTERED ([Id_Categoria] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

