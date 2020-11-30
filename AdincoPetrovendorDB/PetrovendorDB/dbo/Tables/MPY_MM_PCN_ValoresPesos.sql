CREATE TABLE [dbo].[MPY_MM_PCN_ValoresPesos] (
    [IdValoresEnPesosPedidoDetalle] INT            IDENTITY (1, 1) NOT NULL,
    [IdAceptacionPedidoDetalle]     INT            NULL,
    [VNMO_SueldoNacional]           FLOAT (53)     NULL,
    [VMO_Sueldo]                    FLOAT (53)     NULL,
    [CreadoPor]                     INT            NULL,
    [CreadoEl]                      DATETIME       NULL,
    [EditadoPor]                    INT            NULL,
    [EditadoEl]                     DATETIME       NULL,
    [IdTipoNacionalidad]            INT            NULL,
    [IdTipoCriterio]                INT            NULL,
    [IdCatalogoHidrocarburos]       INT            NULL,
    [IdTipoMaterialServicio]        INT            NULL,
    [FraccionArancelaria]           NVARCHAR (500) NULL,
    [IdModificadoPorSP]             INT            NULL,
    [ValorFactura]                  MONEY          NULL,
    [IdClasificacionCN]             INT            NULL,
    [EditadorProveedorPor]          INT            NULL,
    CONSTRAINT [PK_MPY_MM_PCN_ValoresPesos] PRIMARY KEY CLUSTERED ([IdValoresEnPesosPedidoDetalle] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MPY_MM_PCN_ValoresPesos_MPY_MM_AceptacionPedidoDetalle] FOREIGN KEY ([IdAceptacionPedidoDetalle]) REFERENCES [dbo].[MPY_MM_AceptacionPedidoDetalle] ([IdAceptacionPedidoDetalle])
);

