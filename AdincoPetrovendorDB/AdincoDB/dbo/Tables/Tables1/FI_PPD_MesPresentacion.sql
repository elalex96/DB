CREATE TABLE [dbo].[FI_PPD_MesPresentacion] (
    [idPPDMesPresentacion]   INT      IDENTITY (10000, 1) NOT NULL,
    [idFactura]              INT      NOT NULL,
    [MesPresentacionFactura] DATE     NOT NULL,
    [CreadoPor]              INT      NULL,
    [CreadoEn]               DATETIME NULL,
    [ModificadoPor]          INT      NULL,
    [ModificadoEn]           DATETIME NULL,
    [Activo]                 BIT      NULL,
    CONSTRAINT [PK_FI_PPD_MesPresentacion] PRIMARY KEY CLUSTERED ([idFactura] ASC, [MesPresentacionFactura] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FI_PPD_MesPresentacion_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_FI_PPD_MesPresentacion_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_FI_PPD_MesPresentacion_FI_Factura] FOREIGN KEY ([idFactura]) REFERENCES [dbo].[FI_Factura] ([IdFactura])
);

