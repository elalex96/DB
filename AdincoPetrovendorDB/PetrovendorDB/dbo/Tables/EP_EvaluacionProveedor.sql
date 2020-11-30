CREATE TABLE [dbo].[EP_EvaluacionProveedor] (
    [IdEvaluacionProveedor] INT      IDENTITY (1, 1) NOT NULL,
    [IdPedido]              INT      NULL,
    [IdUsuarioEvaluador]    INT      NULL,
    [IdProveedorEvaluador]  INT      NULL,
    [TotalDePuntos]         INT      NULL,
    [IdProveedorEvaluado]   INT      NULL,
    [FechaRegistro]         DATETIME NULL,
    [IsActivo]              BIT      NULL,
    [EstatusEvaluacion]     INT      NULL,
    [FechaContestada]       DATETIME NULL,
    [IdProveedor]           INT      NULL,
    CONSTRAINT [PK_EP_EvaluacionProveedor] PRIMARY KEY CLUSTERED ([IdEvaluacionProveedor] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EP_EvaluacionProveedor_MM_Pedido] FOREIGN KEY ([IdPedido]) REFERENCES [dbo].[MM_Pedido] ([IdPedido])
);

