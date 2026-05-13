CREATE TABLE [dbo].[TituloModulo] (
    [IdTitulosModulo] INT      IDENTITY (1, 1) NOT NULL,
    [IdTitulo]        INT      NULL,
    [IdModulo]        INT      NULL,
    [FechaRegistro]   DATETIME NULL,
    [IsActivo]        BIT      NULL,
    CONSTRAINT [PK_TituloModulo] PRIMARY KEY CLUSTERED ([IdTitulosModulo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TituloModulo_Modulo] FOREIGN KEY ([IdModulo]) REFERENCES [dbo].[Modulo] ([IdModulo]),
    CONSTRAINT [FK_TituloModulo_Titulos] FOREIGN KEY ([IdTitulo]) REFERENCES [dbo].[Titulos] ([IdTitulo])
);

