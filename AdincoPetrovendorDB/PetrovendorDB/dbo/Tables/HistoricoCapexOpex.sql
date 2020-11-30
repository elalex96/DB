CREATE TABLE [dbo].[HistoricoCapexOpex] (
    [Id]                INT      IDENTITY (1, 1) NOT NULL,
    [IdSolicitudPedido] INT      NULL,
    [IdUsuarioModifico] INT      NULL,
    [CapexOpex]         INT      NULL,
    [FechaModificado]   DATETIME NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_HistoricoCapexOpexMM_TipoGastos] FOREIGN KEY ([CapexOpex]) REFERENCES [dbo].[MM_TipoGastos] ([IdTipoGasto]),
    CONSTRAINT [FK_HistoricoCapexOpexSolped] FOREIGN KEY ([IdSolicitudPedido]) REFERENCES [dbo].[MM_SolicitudPedido] ([IdSolicitudPedido]),
    CONSTRAINT [FK_HistoricoCapexOpexUsuario] FOREIGN KEY ([IdUsuarioModifico]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

