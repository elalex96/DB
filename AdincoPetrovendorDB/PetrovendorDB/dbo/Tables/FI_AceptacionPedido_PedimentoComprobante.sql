CREATE TABLE [dbo].[FI_AceptacionPedido_PedimentoComprobante] (
    [IdAceptacionPedidoPedimentoComprobante] INT      IDENTITY (1, 1) NOT NULL,
    [IdAceptacionPedido]                     INT      NULL,
    [IdPedimentoComprobante]                 INT      NULL,
    [NoVersion]                              INT      NULL,
    [IdPedido]                               INT      NULL,
    [CreadoEl]                               DATETIME NULL,
    [CreadoPor]                              INT      NULL,
    [EditadoEl]                              DATETIME NULL,
    [EditadoPor]                             INT      NULL,
    [Activo]                                 BIT      NULL,
    [IdProveedor]                            INT      NULL
);

