CREATE TABLE [dbo].[FI_RelacionPedimento] (
    [IdRelacionFacturaPedimento] INT      IDENTITY (1, 1) NOT NULL,
    [IdFacturaPadre]             INT      NOT NULL,
    [IdPedimentoHijo]            INT      NOT NULL,
    [CreadoPor]                  INT      NOT NULL,
    [CreadoEl]                   DATETIME NOT NULL,
    CONSTRAINT [PK_FI_RelacionPedimento] PRIMARY KEY CLUSTERED ([IdRelacionFacturaPedimento] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FI_RelacionPedimento_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_FI_RelacionPedimento_FI_Factura] FOREIGN KEY ([IdFacturaPadre]) REFERENCES [dbo].[FI_Factura] ([IdFactura]),
    CONSTRAINT [FK_FI_RelacionPedimento_FI_PedimentoComprobante] FOREIGN KEY ([IdPedimentoHijo]) REFERENCES [dbo].[FI_PedimentoComprobante] ([IdPedimentoComprobante])
);

