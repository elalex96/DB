CREATE TABLE [dbo].[MM_AceptacionCartaPCN] (
    [IdAceptacionCartaPCN] INT            IDENTITY (1, 1) NOT NULL,
    [IdAceptacionPedido]   INT            NULL,
    [IdDocumento]          INT            NULL,
    [CreadoPor]            INT            NULL,
    [CreadoEl]             DATETIME       NULL,
    [IdEstatus]            INT            NULL,
    [Activo]               BIT            NULL,
    [IdUsuarioEvaluador]   INT            NULL,
    [ComentarioEvaluador]  NVARCHAR (MAX) NULL,
    [FechaEvaluacion]      DATETIME       NULL,
    [ComentarioProveedor]  NVARCHAR (MAX) NULL,
    [Verificable]          BIT            NULL,
    [IdEstatusEliminado]   INT            NULL,
    [IdEliminado]          INT            NULL,
    [Editado]              BIT            NULL,
    [IdProceso]            INT            NULL,
    CONSTRAINT [PK_MM_AceptacionCartaPCN] PRIMARY KEY CLUSTERED ([IdAceptacionCartaPCN] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_AceptacionCartaPCN_MM_AceptacionPedido] FOREIGN KEY ([IdAceptacionPedido]) REFERENCES [dbo].[MM_AceptacionPedido] ([IdAceptacionPedido]),
    CONSTRAINT [FK_MM_AceptacionCartaPCN_S_TipoValidacionDoc] FOREIGN KEY ([IdEstatus]) REFERENCES [dbo].[S_TipoValidacionDoc] ([IdTipoValidacionDoc]),
    CONSTRAINT [FK_MM_AceptacionCartaPCN_S_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);


GO
CREATE NONCLUSTERED INDEX [idxIdAceptacionPedido_MM_AceptacionCartaPCN]
    ON [dbo].[MM_AceptacionCartaPCN]([IdAceptacionPedido] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

