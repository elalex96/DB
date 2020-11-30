CREATE TABLE [dbo].[MM_SolicitudPedidoDetalle] (
    [IdSolicitudPedidoDetalle]         INT            IDENTITY (1, 1) NOT NULL,
    [IdSolicitudPedido]                INT            NULL,
    [Fecha]                            DATETIME       NULL,
    [IdMaterial]                       INT            NULL,
    [Cantidad]                         FLOAT (53)     NULL,
    [observaciones]                    NVARCHAR (MAX) NULL,
    [descripcion]                      NVARCHAR (MAX) NULL,
    [proveedor]                        INT            NULL,
    [IdUnidad]                         INT            NULL,
    [IdCentroCosto]                    INT            NULL,
    [IdDomicilioEntrega]               INT            NULL,
    [CreadoPor]                        INT            NULL,
    [unidad]                           NVARCHAR (MAX) NULL,
    [MatrizEvaluacionTecnicaRequerida] BIT            NULL,
    [SeguroRequerido]                  BIT            NULL,
    [capitulo]                         NVARCHAR (300) NULL,
    [puesto]                           NVARCHAR (50)  NULL,
    [area]                             NVARCHAR (300) NULL,
    [depto]                            NVARCHAR (300) NULL,
    [prioridad]                        NVARCHAR (300) NULL,
    [numero]                           INT            NULL,
    [valor_aprox]                      FLOAT (53)     NULL,
    [cert_calidad]                     NVARCHAR (MAX) NULL,
    [cargo_a]                          NVARCHAR (MAX) NULL,
    [cargo_en]                         NVARCHAR (MAX) NULL,
    [aprobacion]                       BIT            NULL,
    [desc_gral]                        NVARCHAR (MAX) NULL,
    [fecha_aprob]                      DATETIME       NULL,
    [fechacomp]                        DATETIME       NULL,
    [desaprobado]                      INT            NULL,
    [impreso]                          INT            NULL,
    [fechaimpreso]                     DATETIME       NULL,
    [concepto]                         NVARCHAR (MAX) NULL,
    [partida]                          INT            NULL,
    [max_cantidad]                     NUMERIC (18)   NULL,
    [orden_trbjo]                      NCHAR (50)     NULL,
    [mon_nacnl]                        INT            NULL,
    [mon_extranjera]                   INT            NULL,
    [localizacion]                     NVARCHAR (MAX) NULL,
    [impreso_por]                      NVARCHAR (MAX) NULL,
    [editado]                          BIT            NULL,
    [no_edicion]                       INT            NULL,
    [id_producto]                      INT            NULL,
    [fecha_req_user]                   DATETIME       NULL,
    [cargo_mult]                       NVARCHAR (50)  NULL,
    [equipo_perf]                      NVARCHAR (50)  NULL,
    [cap_info]                         NVARCHAR (MAX) NULL,
    [id_]                              INT            NULL,
    [NoSecuencia]                      INT            NULL,
    [IdEstatusEliminado]               INT            NULL,
    [IdDinamicsAx]                     INT            NULL,
    [FechaModificado]                  DATETIME       NULL,
    CONSTRAINT [PK_MM_SolicitudPedidoDetalle] PRIMARY KEY CLUSTERED ([IdSolicitudPedidoDetalle] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);


GO
CREATE NONCLUSTERED INDEX [<MM_SPDIdSolicitud, sysname,>]
    ON [dbo].[MM_SolicitudPedidoDetalle]([IdSolicitudPedido] ASC) WITH (STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [idxIdMaterial_MM_SolicitudPedidoDetalle]
    ON [dbo].[MM_SolicitudPedidoDetalle]([IdMaterial] ASC) WITH (STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [idxIdDomicilioEntrega_MM_SolicitudPedidoDetalle]
    ON [dbo].[MM_SolicitudPedidoDetalle]([IdDomicilioEntrega] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

