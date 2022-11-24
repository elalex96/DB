CREATE TABLE [dbo].[CN_CompraDirecta] (
    [IdCDCN]                     INT            IDENTITY (1000, 1) NOT NULL,
    [IdContrato]                 INT            NULL,
    [IdProveedor]                INT            NULL,
    [IdFactura]                  INT            NULL,
    [IdPedido]                   INT            NULL,
    [DescripcionBienesServicios] NVARCHAR (MAX) NULL,
    [ValorFactura]               FLOAT (53)     NULL,
    [PCN]                        FLOAT (53)     NULL,
    [IdActividadBS]              INT            NULL,
    [ClasificacionSH]            INT            NULL,
    [Activo]                     BIT            NULL,
    [ModificadoPor]              INT            NULL,
    [ModificadoEl]               DATETIME       NULL,
    [ElimiadoPor]                INT            NULL,
    [EliminadoEl]                DATETIME       NULL,
    [CreadoPor]                  INT            NULL,
    [CreadoEl]                   DATETIME       NULL,
    [IdPedimentoComprobante]     INT            NULL,
    PRIMARY KEY CLUSTERED ([IdCDCN] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

