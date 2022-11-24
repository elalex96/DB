CREATE TABLE [dbo].[SIPAC_ImportCFDI] (
    [IdBitacora] INT      NOT NULL,
    [IdFactura]  INT      NOT NULL,
    [CreadoEl]   DATETIME NOT NULL,
    CONSTRAINT [PK_SIPAC_ImportCFDI] PRIMARY KEY CLUSTERED ([IdBitacora] ASC, [IdFactura] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SIPAC_ImportCFDI_FI_Factura] FOREIGN KEY ([IdFactura]) REFERENCES [dbo].[FI_Factura] ([IdFactura]),
    CONSTRAINT [FK_SIPAC_ImportCFDI_SIPAC_ImportBitacora] FOREIGN KEY ([IdBitacora]) REFERENCES [dbo].[SIPAC_ImportBitacora] ([Id])
);

