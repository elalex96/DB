CREATE TABLE [dbo].[EN_ProcesosRondas] (
    [IdProceso]     INT      NOT NULL,
    [IdRonda]       INT      NOT NULL,
    [CreadoPor]     INT      NULL,
    [CreadoEl]      DATETIME NULL,
    [ModificadoPor] INT      NULL,
    [ModificadoEl]  DATETIME NULL,
    [Activo]        BIT      NULL,
    CONSTRAINT [PK_procesosRonda] PRIMARY KEY CLUSTERED ([IdProceso] ASC, [IdRonda] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ProcesosRonda_Procesos] FOREIGN KEY ([IdProceso]) REFERENCES [dbo].[EN_Procesos] ([IdProceso]),
    CONSTRAINT [FK_ProcesosRonda_Ronda] FOREIGN KEY ([IdRonda]) REFERENCES [dbo].[EN_Rondas] ([idRonda]),
    CONSTRAINT [FK_ProcesosRonda_UsuarioCreado] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_ProcesosRonda_UsuarioModificado] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

