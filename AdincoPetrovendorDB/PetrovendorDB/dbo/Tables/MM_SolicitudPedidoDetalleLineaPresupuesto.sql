CREATE TABLE [dbo].[MM_SolicitudPedidoDetalleLineaPresupuesto] (
    [IdSolicitudPedidoDetalleLineaPresupuesto] INT IDENTITY (1, 1) NOT NULL,
    [IdSolicitudPedidoDetalle]                 INT NOT NULL,
    [IdCentroCosto]                            INT NOT NULL,
    [IdInstalacion]                            INT NOT NULL,
    [IdLineaPresupuesto]                       INT NOT NULL,
    CONSTRAINT [PK_MM_SolicitudPedidoDetalleLineaPresupuesto] PRIMARY KEY CLUSTERED ([IdSolicitudPedidoDetalleLineaPresupuesto] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);


GO
CREATE NONCLUSTERED INDEX [<MM_SPDLPM_IdSPD, sysname,>]
    ON [dbo].[MM_SolicitudPedidoDetalleLineaPresupuesto]([IdSolicitudPedidoDetalle] ASC)
    INCLUDE([IdInstalacion]) WITH (STATISTICS_NORECOMPUTE = ON);

