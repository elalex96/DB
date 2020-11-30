CREATE TABLE [dbo].[Titulos] (
    [IdTitulo]        INT            IDENTITY (1, 1) NOT NULL,
    [NombreTitulo]    NVARCHAR (MAX) NULL,
    [NombreSubtitulo] NVARCHAR (MAX) NULL,
    [FechaRegistro]   DATETIME       NULL,
    [IsActivo]        BIT            NULL,
    [ModificadoEl]    DATETIME       NULL,
    [IdIdioma]        INT            NULL,
    CONSTRAINT [PK_Titulos] PRIMARY KEY CLUSTERED ([IdTitulo] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

