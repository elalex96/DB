CREATE TABLE [dbo].[APP_RelacionRutaDropboxFactura] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [Ruta]          NVARCHAR (MAX) NULL,
    [IdFactura]     INT            NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEl]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEl]  DATETIME       NULL,
    CONSTRAINT [FK_APP_RelacionRutaDropboxFactura_AP_Usuario_Creado] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_APP_RelacionRutaDropboxFactura_AP_Usuario_Modificado] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_APP_RelacionRutaDropboxFactura_FI_Factura] FOREIGN KEY ([IdFactura]) REFERENCES [dbo].[FI_Factura] ([IdFactura])
);

