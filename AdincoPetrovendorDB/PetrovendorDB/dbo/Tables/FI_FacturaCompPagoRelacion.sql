CREATE TABLE [dbo].[FI_FacturaCompPagoRelacion] (
    [IdFacturaCompPagoRelacion] INT IDENTITY (1, 1) NOT NULL,
    [IdFacturaCompPago]         INT NOT NULL,
    [IdFactura]                 INT NOT NULL,
    CONSTRAINT [PK_FI_FacturaCompPagoRelacion] PRIMARY KEY CLUSTERED ([IdFacturaCompPagoRelacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FI_FacturaCompPagoRelacion_FI_Factura1] FOREIGN KEY ([IdFacturaCompPago]) REFERENCES [dbo].[FI_Factura] ([IdFactura]),
    CONSTRAINT [FK_FI_FacturaCompPagoRelacion_FI_Factura2] FOREIGN KEY ([IdFactura]) REFERENCES [dbo].[FI_Factura] ([IdFactura])
);

