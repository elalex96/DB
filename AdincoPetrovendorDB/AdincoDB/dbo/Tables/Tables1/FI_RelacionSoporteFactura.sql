CREATE TABLE [dbo].[FI_RelacionSoporteFactura] (
    [RelacionSoporteFacturaId] INT      IDENTITY (1, 1) NOT NULL,
    [DocumentoSoporteId]       INT      NOT NULL,
    [IdFactura]                INT      NULL,
    [IdPedimentoComprobante]   INT      NULL,
    [CreadoPor]                INT      NULL,
    [CreadoEl]                 DATETIME NULL,
    [ModificadoPor]            INT      NULL,
    [ModificadoEl]             DATETIME NULL,
    [Activo]                   BIT      NULL,
    CONSTRAINT [PK__FI_Relac__FEAF8B547A581DD4] PRIMARY KEY CLUSTERED ([RelacionSoporteFacturaId] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__FI_Relaci__Activ__637CD475] FOREIGN KEY ([DocumentoSoporteId]) REFERENCES [dbo].[FI_DocumentoSoporte] ([DocumentoSoporteId]),
    CONSTRAINT [FK__FI_Relaci__IdFac__6470F8AE] FOREIGN KEY ([IdFactura]) REFERENCES [dbo].[FI_Factura] ([IdFactura]),
    CONSTRAINT [FK__FI_Relaci__IdPed__65651CE7] FOREIGN KEY ([IdPedimentoComprobante]) REFERENCES [dbo].[FI_PedimentoComprobante] ([IdPedimentoComprobante])
);

