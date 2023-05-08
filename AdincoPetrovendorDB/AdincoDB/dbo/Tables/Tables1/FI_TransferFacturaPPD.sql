CREATE TABLE [dbo].[FI_TransferFacturaPPD] (
    [IdTransferFacturaPPD] INT        IDENTITY (10000, 1) NOT NULL,
    [IdTransfer]           INT        NULL,
    [IdFactura]            INT        NULL,
    [MontoPagado]          FLOAT (53) NULL,
    [CvTipoDocFacturacion] INT        NULL,
    [CreadoPor]            INT        NULL,
    [CreadoEn]             DATETIME   NULL,
    [ModificadoPor]        INT        NULL,
    [ModificadoEn]         DATETIME   NULL,
    CONSTRAINT [PK_FI_TransferFacturaPPD] PRIMARY KEY CLUSTERED ([IdTransferFacturaPPD] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

