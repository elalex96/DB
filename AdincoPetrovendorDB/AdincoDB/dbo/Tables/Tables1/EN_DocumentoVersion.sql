CREATE TABLE [dbo].[EN_DocumentoVersion] (
    [idHistorial]           INT      IDENTITY (10000, 1) NOT NULL,
    [DocumentoEntregableId] INT      NULL,
    [idInstanciaEntregable] INT      NULL,
    [N_version]             INT      NULL,
    [CreadoPor]             INT      NULL,
    [CreadoEl]              DATETIME NULL,
    [ModificadoPor]         INT      NULL,
    [ModificadoEl]          DATETIME NULL,
    [Activo]                BIT      NULL,
    PRIMARY KEY CLUSTERED ([idHistorial] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EN_DocumentoVersion_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_DocumentoVersion_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_DocumentoVersion_EN_EntregableDocumento] FOREIGN KEY ([DocumentoEntregableId]) REFERENCES [dbo].[EN_EntregableDocumento] ([DocumentoEntregableId]),
    CONSTRAINT [FK_EN_DocumentoVersion_EN_InstanciasEntregable] FOREIGN KEY ([idInstanciaEntregable]) REFERENCES [dbo].[EN_InstanciasEntregable] ([idInstanciaEntregable])
);

