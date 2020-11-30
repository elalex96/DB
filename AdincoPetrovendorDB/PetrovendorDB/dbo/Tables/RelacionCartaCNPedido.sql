CREATE TABLE [dbo].[RelacionCartaCNPedido] (
    [IdPedido]           INT      NOT NULL,
    [IdAceptacionPedido] INT      NOT NULL,
    [PedirCarta]         BIT      NOT NULL,
    [CreadoPor]          INT      NOT NULL,
    [FechaCreacion]      DATETIME NOT NULL,
    PRIMARY KEY CLUSTERED ([IdPedido] ASC, [IdAceptacionPedido] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_RelacionCartaCNPedido_MM_AceptacionPedido] FOREIGN KEY ([IdAceptacionPedido]) REFERENCES [dbo].[MM_AceptacionPedido] ([IdAceptacionPedido]),
    CONSTRAINT [FK_RelacionCartaCNPedido_MM_Pedido] FOREIGN KEY ([IdPedido]) REFERENCES [dbo].[MM_Pedido] ([IdPedido]),
    CONSTRAINT [FK_RelacionCartaCNPedido_S_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

