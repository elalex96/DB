CREATE TABLE [dbo].[FI_FacturaPuntoEntrega] (
    [idfacturaPuntoEntrega] INT      IDENTITY (10000, 1) NOT NULL,
    [idFactura]             INT      NULL,
    [PuntoEntregaId]        INT      NULL,
    [ProductoId]            INT      NULL,
    [MesReporte]            DATE     NULL,
    [CreadoPor]             INT      NULL,
    [CreadoEl]              DATETIME NULL,
    [ModificadoPor]         INT      NULL,
    [ModificadoEl]          DATETIME NULL,
    [Activo]                BIT      NULL,
    CONSTRAINT [PK__FI_Factu__669C2E09F2FF73A9] PRIMARY KEY CLUSTERED ([idfacturaPuntoEntrega] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([MesReporte]) REFERENCES [dbo].[AP_Calendario] ([IdFecha]),
    FOREIGN KEY ([ProductoId]) REFERENCES [dbo].[CO_ClasificacionProductoNominacion] ([ProductoNominacionID]),
    CONSTRAINT [FK__FI_Factur__Punto__29F972FF] FOREIGN KEY ([idFactura]) REFERENCES [dbo].[FI_Factura] ([IdFactura]),
    CONSTRAINT [FK__FI_Factur__Punto__2AED9738] FOREIGN KEY ([PuntoEntregaId]) REFERENCES [dbo].[CO_PuntosdeEntrega] ([PuntoEntregaID])
);

