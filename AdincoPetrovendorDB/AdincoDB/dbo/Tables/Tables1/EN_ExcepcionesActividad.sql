CREATE TABLE [dbo].[EN_ExcepcionesActividad] (
    [ActividadIDExcepcion]    INT      NULL,
    [EstadoID]                INT      NOT NULL,
    [idUsuario]               INT      NOT NULL,
    [IdInstanciasEntregables] INT      NOT NULL,
    [CreadoPor]               INT      NULL,
    [CreadoEn]                DATETIME NULL,
    [ModificadoPor]           INT      NULL,
    [ModificadoEn]            DATETIME NULL,
    [Activo]                  BIT      NULL,
    CONSTRAINT [PK_EN_ExcepcionesActividadInstancias] PRIMARY KEY CLUSTERED ([EstadoID] ASC, [idUsuario] ASC, [IdInstanciasEntregables] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ActividadIDExcepcion] FOREIGN KEY ([ActividadIDExcepcion]) REFERENCES [dbo].[EN_Actividad] ([ActividadID]),
    CONSTRAINT [FK_EN_ExcepcionesActividadInstancias_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_ExcepcionesActividadInstancias_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_ExcepcionesActividadInstancias_AP_UsuarioResponsable] FOREIGN KEY ([idUsuario]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_ExcepcionesActividadInstancias_EN_Estado] FOREIGN KEY ([EstadoID]) REFERENCES [dbo].[EN_Estado] ([EstadoID]),
    CONSTRAINT [FK_EN_ExcepcionesActividadInstancias_EN_instaciasEntregable] FOREIGN KEY ([IdInstanciasEntregables]) REFERENCES [dbo].[EN_InstanciasEntregable] ([idInstanciaEntregable])
);

