CREATE TABLE [dbo].[EN_Actividad] (
    [ActividadID]          INT      IDENTITY (10000, 1) NOT NULL,
    [EstadoID]             INT      NOT NULL,
    [idUsuario]            INT      NOT NULL,
    [IdContratoEntregable] INT      NOT NULL,
    [CreadoPor]            INT      NULL,
    [CreadoEn]             DATETIME NULL,
    [ModificadoPor]        INT      NULL,
    [ModificadoEn]         DATETIME NULL,
    [Activo]               BIT      NOT NULL,
    CONSTRAINT [PK_EN_Actividad] PRIMARY KEY CLUSTERED ([EstadoID] ASC, [idUsuario] ASC, [IdContratoEntregable] ASC, [Activo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EN_Actividad_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_Actividad_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_Actividad_AP_UsuarioResponsable] FOREIGN KEY ([idUsuario]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_Actividad_EN_ContratoEntregable] FOREIGN KEY ([IdContratoEntregable]) REFERENCES [dbo].[EN_ContratoEntregable] ([IdContratoEntregable]),
    CONSTRAINT [FK_EN_Actividad_EN_Estado] FOREIGN KEY ([EstadoID]) REFERENCES [dbo].[EN_Estado] ([EstadoID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [indiceActividadID]
    ON [dbo].[EN_Actividad]([ActividadID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [EN_Actividad_ContratoEntregable_Estado]
    ON [dbo].[EN_Actividad]([IdContratoEntregable] ASC, [EstadoID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [IX_EN_Actividad]
    ON [dbo].[EN_Actividad]([ActividadID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

