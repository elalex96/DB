CREATE TABLE [dbo].[MM_Plantilla_SolicitudPedidoDetalle] (
    [IdPlantillaSolicitudPedidoDetalle] INT            IDENTITY (1000, 1) NOT NULL,
    [IdPlantillaSolicitudPedido]        INT            NULL,
    [IdMaterial]                        INT            NULL,
    [Fecha]                             DATETIME       NULL,
    [Cantidad]                          FLOAT (53)     NULL,
    [Observaciones]                     NVARCHAR (MAX) NULL,
    [CreadoPor]                         INT            NULL,
    [IdUnidad]                          INT            NULL,
    [IdCentroCosto]                     INT            NULL,
    [IdDomicilioEntrega]                INT            NULL,
    [CreadoEl]                          DATETIME       NULL,
    [IdInstalacion]                     INT            NULL,
    [IdLineaPresupuesto]                INT            NULL,
    [Activo]                            BIT            NULL,
    CONSTRAINT [PK_MM_Plantilla_SolicitudPedidoDetalle] PRIMARY KEY CLUSTERED ([IdPlantillaSolicitudPedidoDetalle] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

