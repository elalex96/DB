CREATE TABLE [dbo].[FI_TransferFactura] (
    [IdTransferFactura]      INT IDENTITY (1, 1) NOT NULL,
    [IdTransfer]             INT NULL,
    [IdFactura]              INT NULL,
    [IdPedimentoComprobante] INT NULL,
    [CvTipoDocFacturacion]   INT NULL,
    CONSTRAINT [PK_FI_TransferFactura] PRIMARY KEY CLUSTERED ([IdTransferFactura] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

