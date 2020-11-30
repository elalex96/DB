CREATE TABLE [dbo].[MPY_MM_PCN_MaterialesUtilizados] (
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
    [EditadoPor]                    INT            NULL,
    [EditadoEl]                     DATETIME       NULL,
    [IsEliminado]                   BIT            NULL,
    [IdPCNProveedor]                INT            NULL,
    CONSTRAINT [PK_MPY_PCN_MaterialesUtilizados] PRIMARY KEY CLUSTERED ([IdMaterialServicioUtilizado] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MPY_MM_PCN_MaterialesUtilizados_MPY_MM_PCN_ValoresPesos] FOREIGN KEY ([IdTipoMaterial]) REFERENCES [dbo].[MM_TipoMaterialProcura] ([IdTipoMaterialProcura])
);

