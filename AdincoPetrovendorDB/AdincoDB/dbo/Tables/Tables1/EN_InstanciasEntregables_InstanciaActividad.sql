CREATE TABLE [dbo].[EN_InstanciasEntregables_InstanciaActividad] (
    [idInstanciaEntregable] INT      NOT NULL,
    [idInstanciaActividad]  INT      NOT NULL,
    [CreadoPor]             INT      NULL,
    [CreadoEl]              DATETIME NULL,
    [ModificadoPor]         INT      NULL,
    [ModificadoEl]          DATETIME NULL,
    [Activo]                BIT      NULL,
    CONSTRAINT [PK_EN_InstanciasEntregables_InstanciaActividad] PRIMARY KEY CLUSTERED ([idInstanciaEntregable] ASC, [idInstanciaActividad] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EN_InstanciasEntregables_InstanciaActividad_InstanciasActividades] FOREIGN KEY ([idInstanciaActividad]) REFERENCES [dbo].[EN_InstanciasActividades] ([idInstanciaActividad]),
    CONSTRAINT [FK_EN_InstanciasEntregables_InstanciaActividad_InstanciasEntregables] FOREIGN KEY ([idInstanciaEntregable]) REFERENCES [dbo].[EN_InstanciasEntregable] ([idInstanciaEntregable]),
    CONSTRAINT [FK_EN_InstanciasEntregables_InstanciaActividad_UsuarioCreado] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_InstanciasEntregables_InstanciaActividad_UsuarioModificado] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

go

create index IX_EN_InstanciasEntregables_InstanciaActividad	on	EN_InstanciasEntregables_InstanciaActividad(idInstanciaEntregable)
