CREATE TABLE [dbo].[COM_FacturaPuntoVenta] (
    [IdFacturaPuntoVenta] INT  IDENTITY (10000, 1) NOT NULL,
    [IdFactura]           INT  NULL,
    [IdPuntoVenta]        INT  NULL,
    [Mes]                 DATE NULL,
    CONSTRAINT [PK_COM_FacturaPuntoVenta] PRIMARY KEY CLUSTERED ([IdFacturaPuntoVenta] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_COM_FacturaPuntoVenta_COM_PuntoVentaHidrocarburos] FOREIGN KEY ([IdPuntoVenta]) REFERENCES [dbo].[COM_PuntoVentaHidrocarburos] ([IdPuntoVentaHidrocarburos]),
    CONSTRAINT [FK_COM_FacturaPuntoVenta_FI_Factura] FOREIGN KEY ([IdFactura]) REFERENCES [dbo].[FI_Factura] ([IdFactura])
);

