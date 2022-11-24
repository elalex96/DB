CREATE TABLE [dbo].[EN_MacroProcesosRelacion] (
    [idMacroProcesoRelacion] INT      IDENTITY (10000, 1) NOT NULL,
    [idMacroProceso]         INT      NOT NULL,
    [idProcesoHijo]          INT      NOT NULL,
    [CreadoPor]              INT      NULL,
    [CreadoEn]               DATETIME NULL,
    [ModificadoPor]          INT      NULL,
    [ModificadoEn]           DATETIME NULL,
    [Activo]                 BIT      NULL,
    [Orden]                  INT      NULL,
    [IdprocesoOriginal]      INT      NULL,
    CONSTRAINT [PK_EN_MacroProcesosRelacion] PRIMARY KEY CLUSTERED ([idMacroProceso] ASC, [idProcesoHijo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EN_MacroProcesosRelacion_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_MacroProcesosRelacion_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_MacroProcesosRelacion_EN_MacroProceso] FOREIGN KEY ([idMacroProceso]) REFERENCES [dbo].[EN_Procesos] ([IdProceso]),
    CONSTRAINT [FK_EN_MacroProcesosRelacion_EN_procesos] FOREIGN KEY ([idProcesoHijo]) REFERENCES [dbo].[EN_Procesos] ([IdProceso]),
    CONSTRAINT [FK_IdprocesoOriginal_EN_Procesos] FOREIGN KEY ([IdprocesoOriginal]) REFERENCES [dbo].[EN_Procesos] ([IdProceso])
);

