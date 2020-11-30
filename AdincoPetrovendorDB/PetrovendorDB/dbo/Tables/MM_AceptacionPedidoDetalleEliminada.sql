CREATE TABLE [dbo].[MM_AceptacionPedidoDetalleEliminada] (
    [IdAceptacionPedidoDetalleBitacora] INT        IDENTITY (1, 1) NOT NULL,
    [IdAceptacionPedido]                INT        NULL,
    [IdAceptacionPedidoDetalle]         INT        NULL,
    [IdPedidoDetalle]                   INT        NULL,
    [IdProveedor]                       INT        NULL,
    [CreadoPor]                         INT        NULL,
    [IdMaterial]                        INT        NULL,
    [Cantidad]                          FLOAT (53) NULL,
    [IdInstalacion]                     INT        NULL,
    [IdLineaPresupuesto]                INT        NULL,
    [CreadoEl]                          DATETIME   NULL,
    [EliminadoEl]                       DATETIME   NULL,
    [EliminadoPor]                      INT        NULL,
    CONSTRAINT [PK_MM_AceptacionPedidoDetalleEliminada] PRIMARY KEY CLUSTERED ([IdAceptacionPedidoDetalleBitacora] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

