CREATE TABLE [dbo].[EN_TipoArchivo] (
    [idTipoArchivo] INT            IDENTITY (10000, 1) NOT NULL,
    [Nombrearchivo] NVARCHAR (100) NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEn]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEn]  DATETIME       NULL,
    [Activo]        BIT            NULL,
    CONSTRAINT [PK_EN_TipoArchivo] PRIMARY KEY CLUSTERED ([idTipoArchivo] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EN_TipoArchivo_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_TipoArchivo_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

