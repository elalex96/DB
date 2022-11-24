CREATE TABLE [dbo].[CO_ProductoNominacionBloque] (
    [idProductoNominacionBloque] INT IDENTITY (1000, 1) NOT NULL,
    [ProductoNominacionID]       INT NULL,
    [idAreaContractual]          INT NULL,
    [idDirector]                 INT NULL,
    CONSTRAINT [PK__CO_Produ__AC802E2A6BE30904] PRIMARY KEY CLUSTERED ([idProductoNominacionBloque] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__CO_Produc__idAre__061B39E5] FOREIGN KEY ([idAreaContractual]) REFERENCES [dbo].[CO_AreaContractual] ([IdAreaContractual]),
    CONSTRAINT [FK__CO_Produc__idDir__544ED427] FOREIGN KEY ([idDirector]) REFERENCES [dbo].[CO_DirectorOperaciones] ([idDirector]),
    CONSTRAINT [FK__CO_Produc__Produ__0E267001] FOREIGN KEY ([ProductoNominacionID]) REFERENCES [dbo].[CO_ClasificacionProductoNominacion] ([ProductoNominacionID])
);

