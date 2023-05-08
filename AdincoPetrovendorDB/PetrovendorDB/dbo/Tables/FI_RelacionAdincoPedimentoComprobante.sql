CREATE TABLE [dbo].[FI_RelacionAdincoPedimentoComprobante] (
    [IdRelacionPedimentoComprobante]    INT      IDENTITY (1, 1) NOT NULL,
    [IdPedimentoComprobantePetrovendor] INT      NULL,
    [IdPedimentoComprobanteAdinco]      INT      NULL,
    [CreadoEl]                          DATETIME NULL,
    CONSTRAINT [PK_FI_RelacionAdincoPedimentoComprobante] PRIMARY KEY CLUSTERED ([IdRelacionPedimentoComprobante] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

