CREATE TABLE [dbo].[EN_ActividadesEntregables] (
    [IdActividad]   INT      NOT NULL,
    [IdEntregable]  INT      NOT NULL,
    [CreadoPor]     INT      NULL,
    [CreadoEl]      DATETIME NULL,
    [ModificadoPor] INT      NULL,
    [ModificadoEl]  DATETIME NULL,
    [Activo]        BIT      NULL,
    CONSTRAINT [PK_EN_ActividadesEntregables] PRIMARY KEY CLUSTERED ([IdActividad] ASC, [IdEntregable] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EN_Actividades_ActividadesEntregables_UsuarioCreado] FOREIGN KEY ([IdActividad]) REFERENCES [dbo].[EN_Actividades] ([IdActividad]),
    CONSTRAINT [FK_EN_ActividadesEntregables_Entregables] FOREIGN KEY ([IdEntregable]) REFERENCES [dbo].[EN_Entregable] ([IdEntregable]),
    CONSTRAINT [FK_EN_ActividadesEntregables_UsuarioCreado] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_ActividadesEntregables_UsuarioModificado] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

