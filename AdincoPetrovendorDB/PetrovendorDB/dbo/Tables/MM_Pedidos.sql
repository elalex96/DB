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
    ON [dbo].[MM_Pedidos]([IdPedido] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

