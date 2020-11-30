CREATE TABLE [dbo].[AP_Bitacora] (
    [IdBitacora] INT      IDENTITY (1, 1) NOT NULL,
    [IdAccion]   INT      NULL,
    [IdPagina]   INT      NULL,
    [IdUsuario]  INT      NULL,
    [Fecha]      DATETIME NULL,
    CONSTRAINT [PK_AP_Bitacora] PRIMARY KEY CLUSTERED ([IdBitacora] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AP_Bitacora_AP_Pagina] FOREIGN KEY ([IdPagina]) REFERENCES [dbo].[AP_Pagina] ([IdPaginas]),
    CONSTRAINT [FK_AP_Bitacora_S_Usuario] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

