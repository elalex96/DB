CREATE TABLE [dbo].[FI_RelacionComprobanteAdinco] (
    [IdRelacionComprobante]    INT      IDENTITY (1, 1) NOT NULL,
    [IdComprobantePetrovendor] INT      NULL,
    [IdComprobanteAdinco]      INT      NULL,
    [FechaEnvio]               DATETIME NULL,
    CONSTRAINT [PK_FI_RelacionComprobanteAdinco] PRIMARY KEY CLUSTERED ([IdRelacionComprobante] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FI_RelacionComprobanteAdinco_FI_PedimentoComprobante1] FOREIGN KEY ([IdComprobantePetrovendor]) REFERENCES [dbo].[FI_PedimentoComprobante] ([IdPedimentoComprobante])
);

