CREATE TABLE [dbo].[VU_FacturaDocumento] (
    [IdFacturaDocumento] INT      IDENTITY (1, 1) NOT NULL,
    [IdFactura]          INT      NULL,
    [IdDocumento]        INT      NULL,
    [Fecha]              DATETIME NULL,
    [IdUsuario]          INT      NULL,
    CONSTRAINT [PK_FacturaDocumento] PRIMARY KEY CLUSTERED ([IdFacturaDocumento] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FacturaDocumento_Facturas] FOREIGN KEY ([IdDocumento]) REFERENCES [dbo].[FI_EstudioPreciosTransfer] ([IdEstudioPrecioTransfer])
);

