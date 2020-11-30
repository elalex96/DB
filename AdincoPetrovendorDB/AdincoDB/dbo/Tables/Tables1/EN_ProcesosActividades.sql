CREATE TABLE [dbo].[EN_ProcesosActividades] (
    [IdProceso]           INT      NOT NULL,
    [idActividad]         INT      NOT NULL,
    [IdContrato]          INT      NOT NULL,
    [Orden]               INT      NULL,
    [CreadoPor]           INT      NULL,
    [CreadoEl]            DATETIME NULL,
    [ModificadoPor]       INT      NULL,
    [ModificadoEl]        DATETIME NULL,
    [Activo]              BIT      NULL,
    [BitIniciaSigProceso] BIT      NULL,
    CONSTRAINT [PK_procesosActividad] PRIMARY KEY CLUSTERED ([IdProceso] ASC, [idActividad] ASC, [IdContrato] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ProcesosActividad_Actividad] FOREIGN KEY ([idActividad]) REFERENCES [dbo].[EN_Actividades] ([IdActividad]),
    CONSTRAINT [FK_ProcesosActividad_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_ProcesosActividad_Procesos] FOREIGN KEY ([IdProceso]) REFERENCES [dbo].[EN_Procesos] ([IdProceso]),
    CONSTRAINT [FK_ProcesosActividad_UsuarioCreado] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_ProcesosActividad_UsuarioModificado] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

