CREATE TABLE [dbo].[FI_TransferFactura] (
    [IdTransferFactura]      INT             IDENTITY (1, 1) NOT NULL,
    [IdTransfer]             INT             NULL,
    [IdFactura]              INT             NULL,
    [IdPedimentoComprobante] INT             NULL,
    [MontoPagado]            DECIMAL (18, 6) NULL,
    [CvTipoDocFacturacion]   INT             NULL,
    [CreadoPor]              INT             NULL,
    [CreadoEn]               DATETIME        NULL,
    [ModificadoPor]          INT             NULL,
    [ModificadoEn]           DATETIME        NULL,
    CONSTRAINT [PK_FI_TransferFactura] PRIMARY KEY CLUSTERED ([IdTransferFactura] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FI_TransferFactura_FI_Factura] FOREIGN KEY ([IdFactura]) REFERENCES [dbo].[FI_Factura] ([IdFactura]),
    CONSTRAINT [FK_FI_TransferFactura_FI_PedimentoComprobante] FOREIGN KEY ([IdPedimentoComprobante]) REFERENCES [dbo].[FI_PedimentoComprobante] ([IdPedimentoComprobante]),
    CONSTRAINT [FK_FI_TransferFactura_FI_Transfer] FOREIGN KEY ([IdTransfer]) REFERENCES [dbo].[FI_Transfer] ([IdTransferencia])
);


GO
CREATE NONCLUSTERED INDEX [idxidFacturaTransfer]
    ON [dbo].[FI_TransferFactura]([IdFactura] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

