CREATE TABLE [dbo].[EN_InstanciasActividades] (
    [idInstanciaActividad] INT      IDENTITY (10000, 1) NOT NULL,
    [IdInstanciasProcesos] INT      NULL,
    [IdActividad]          INT      NULL,
    [FechaActividad]       DATE     NULL,
    [CreadoPor]            INT      NULL,
    [CreadoEl]             DATETIME NULL,
    [ModificadoPor]        INT      NULL,
    [ModificadoEl]         DATETIME NULL,
    [Activo]               BIT      NULL,
    [FechaRealActividad]   DATE     NULL,
    [FechaInicioActividad] DATE     NULL,
    CONSTRAINT [PK_InstanciasActividades] PRIMARY KEY CLUSTERED ([idInstanciaActividad] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_InstanciasActividades_Actividades] FOREIGN KEY ([IdActividad]) REFERENCES [dbo].[EN_Actividades] ([IdActividad]),
    CONSTRAINT [FK_InstanciasActividades_EN_InstanciasProcesos] FOREIGN KEY ([IdInstanciasProcesos]) REFERENCES [dbo].[EN_InstanciasProcesosFecha] ([IdInstanciasProcesos]),
    CONSTRAINT [FK_InstanciasActividades_UsuarioCreado] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_InstanciasActividades_UsuarioModificado] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [indiceInstProcesoActividadFecha]
    ON [dbo].[EN_InstanciasActividades]([IdInstanciasProcesos] ASC, [IdActividad] ASC, [FechaActividad] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

