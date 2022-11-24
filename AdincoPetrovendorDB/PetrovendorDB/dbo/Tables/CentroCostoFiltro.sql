CREATE TABLE [dbo].[CentroCostoFiltro] (
    [IdCentroCosto] INT      NOT NULL,
    [IdUsuario]     INT      NOT NULL,
    [IdProveedor]   INT      NOT NULL,
    [Activo]        BIT      NULL,
    [CreadoEl]      DATETIME NULL,
    [ModificadoEl]  DATETIME NULL,
    CONSTRAINT [PK_CentroCostoFiltro] PRIMARY KEY CLUSTERED ([IdCentroCosto] ASC, [IdUsuario] ASC, [IdProveedor] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CentroCosto_CentroCostoFiltro] FOREIGN KEY ([IdCentroCosto]) REFERENCES [dbo].[CC_CentroCosto] ([IdCentroCosto]),
    CONSTRAINT [FK_S_Proveedor_CentroCostoFiltro] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_S_Usuario_CentroCostoFiltro] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

