CREATE TABLE [dbo].[MM_PCN_MaterialesUtilizados] (
    [IdMaterialServicioUtilizado]   INT            IDENTITY (1, 1) NOT NULL,
    [IdValoresEnPesosPedidoDetalle] INT            NULL,
    [IdTipoMaterial]                INT            NULL,
    [Descripcion]                   NVARCHAR (300) NULL,
    [VM_ValorFactura]               FLOAT (53)     NULL,
    [PCNM_Utilizado]                FLOAT (53)     NULL,
    [CreadoPor]                     INT            NULL,
    [CreadoEl]                      DATETIME       NULL,
    [NombreProveedor]               NVARCHAR (300) NULL,
    [RFC]                           NVARCHAR (50)  NULL,
    [Activo]                        BIT            NULL,
    [EditadoPor]                    INT            NULL,
    [EditadoEl]                     DATETIME       NULL,
    [IsEliminado]                   BIT            NULL,
    [IdPCNProveedor]                INT            NULL,
    CONSTRAINT [PK_PCN_MaterialesUtilizados] PRIMARY KEY CLUSTERED ([IdMaterialServicioUtilizado] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_PCN_MaterialesUtilizados_MM_PCN_ValoresPesos] FOREIGN KEY ([IdTipoMaterial]) REFERENCES [dbo].[MM_TipoMaterialProcura] ([IdTipoMaterialProcura]),
    CONSTRAINT [FK_MM_PCN_MaterialesUtilizados_MM_PCN_ValoresPesos1] FOREIGN KEY ([IdValoresEnPesosPedidoDetalle]) REFERENCES [dbo].[MM_PCN_ValoresPesos] ([IdValoresEnPesosPedidoDetalle])
);

