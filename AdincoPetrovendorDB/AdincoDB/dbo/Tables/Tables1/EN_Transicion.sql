CREATE TABLE [dbo].[EN_Transicion] (
    [TransicionID]         INT      IDENTITY (10000, 1) NOT NULL,
    [ActividadInicialID]   INT      NOT NULL,
    [AccionID]             INT      NOT NULL,
    [SiguienteActividadID] INT      NOT NULL,
    [IdContratoEntregable] INT      NOT NULL,
    [CreadoPor]            INT      NULL,
    [CreadoEn]             DATETIME NULL,
    [ModificadoPor]        INT      NULL,
    [ModificadoEn]         DATETIME NULL,
    [Activo]               BIT      NULL,
    CONSTRAINT [PK_EN_Transicion] PRIMARY KEY CLUSTERED ([ActividadInicialID] ASC, [AccionID] ASC, [SiguienteActividadID] ASC, [IdContratoEntregable] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EN_Transicion_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_Transicion_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_Transicion_EN_Accion] FOREIGN KEY ([AccionID]) REFERENCES [dbo].[EN_Accion] ([AccionID]),
    CONSTRAINT [FK_EN_Transicion_EN_ContratoEntregable] FOREIGN KEY ([IdContratoEntregable]) REFERENCES [dbo].[EN_ContratoEntregable] ([IdContratoEntregable])
);

