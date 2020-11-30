CREATE TABLE [dbo].[MM_HistorialCorreccionCantidadAP] (
    [IdHistorialCorreccionCantidadAP] INT            IDENTITY (1, 1) NOT NULL,
    [IdAceptacionPedido]              INT            NOT NULL,
    [IdAeptacionPedidoDetalle]        INT            NOT NULL,
    [CantidadAnterior]                FLOAT (53)     NOT NULL,
    [CantidadNueva]                   FLOAT (53)     NOT NULL,
    [Motivo]                          VARCHAR (1500) NOT NULL,
    [ModificadoPor]                   INT            NOT NULL,
    [ModificadoEl]                    SMALLDATETIME  NOT NULL,
    CONSTRAINT [PK_MM_HistorialCorreccionCantidadAP] PRIMARY KEY CLUSTERED ([IdHistorialCorreccionCantidadAP] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_HistorialCorreccionCantidadAP_MM_AceptacionPedido1] FOREIGN KEY ([IdAceptacionPedido]) REFERENCES [dbo].[MM_AceptacionPedido] ([IdAceptacionPedido]),
    CONSTRAINT [FK_MM_HistorialCorreccionCantidadAP_MM_AceptacionPedidoDetalle1] FOREIGN KEY ([IdAeptacionPedidoDetalle]) REFERENCES [dbo].[MM_AceptacionPedidoDetalle] ([IdAceptacionPedidoDetalle]),
    CONSTRAINT [FK_MM_HistorialCorreccionCantidadAP_S_Usuario1] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

