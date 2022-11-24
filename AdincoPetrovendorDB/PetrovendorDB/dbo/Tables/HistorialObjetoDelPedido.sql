CREATE TABLE [dbo].[HistorialObjetoDelPedido] (
    [Id]                INT            IDENTITY (1, 1) NOT NULL,
    [IdSolicitudPedido] INT            NULL,
    [IdUsuarioModifico] INT            NULL,
    [MotivoAnterior]    NVARCHAR (MAX) NULL,
    [FechaModificado]   DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [Fk_HistorialObjetoDelPedidoSolped] FOREIGN KEY ([IdSolicitudPedido]) REFERENCES [dbo].[MM_SolicitudPedido] ([IdSolicitudPedido]),
    CONSTRAINT [FK_HistorialObjetoDelPedidoUsuario] FOREIGN KEY ([IdUsuarioModifico]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

