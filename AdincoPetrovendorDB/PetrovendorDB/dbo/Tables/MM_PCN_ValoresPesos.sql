CREATE TABLE [dbo].[MM_PCN_ValoresPesos] (
    [IdValoresEnPesosPedidoDetalle] INT            IDENTITY (1, 1) NOT NULL,
    [IdAceptacionPedidoDetalle]     INT            NULL,
    [VNMO_SueldoNacional]           FLOAT (53)     NULL,
    [VMO_Sueldo]                    FLOAT (53)     NULL,
    [CreadoPor]                     INT            NULL,
    [CreadoEl]                      DATETIME       NULL,
    [EditadoPor]                    INT            NULL,
    [EditadoEl]                     DATETIME       NULL,
    [IdTipoMaterialServicio]        INT            NULL,
    [IdTipoNacionalidad]            INT            NULL,
    [IdTipoCriterio]                INT            NULL,
    [IdCatalogoHidrocarburos]       INT            NULL,
    [ValorFactura]                  MONEY          NULL,
    [IdClasificacionCN]             INT            NULL,
    [EditadorProveedorPor]          INT            NULL,
    [IdModificadoPorSP]             INT            NULL,
    [FraccionArancelaria]           NVARCHAR (500) NULL,
    CONSTRAINT [PK_MM_PCN_ValoresPesos] PRIMARY KEY CLUSTERED ([IdValoresEnPesosPedidoDetalle] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_PCN_ValoresPesos_MM_AceptacionPedidoDetalle] FOREIGN KEY ([IdAceptacionPedidoDetalle]) REFERENCES [dbo].[MM_AceptacionPedidoDetalle] ([IdAceptacionPedidoDetalle])
);

