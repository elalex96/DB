CREATE TABLE [dbo].[MM_Pedidos] (
    [IdRegistro]         INT            IDENTITY (1, 1) NOT NULL,
    [IdPedido]           INT            NULL,
    [IdTipoPedido]       INT            NULL,
    [IdIdentificador]    INT            NULL,
    [IdCreadoPor]        INT            NULL,
    [CreadorEl]          DATETIME       NULL,
    [IdProveedorCliente] INT            NULL,
    [CuentaBancaria]     NVARCHAR (500) NULL,
    [DiasCredito]        INT            NULL,
    CONSTRAINT [FK_MM_Pedidos_MM_TipoPedido_PedidosGenerales] FOREIGN KEY ([IdTipoPedido]) REFERENCES [dbo].[MM_TipoPedido] ([IdTipoPedido])
);


GO
CREATE NONCLUSTERED INDEX [<MM_PedidosIdPedido, sysname,>]
    ON [dbo].[MM_Pedidos]([IdPedido] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [IdPedidoTipoPedido]
    ON [dbo].[MM_Pedidos]([IdIdentificador] ASC, [IdProveedorCliente] ASC)
    INCLUDE([IdPedido], [IdTipoPedido]) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

