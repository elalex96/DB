CREATE TABLE [dbo].[EN_ProcesosContrato] (
    [idProcesoContrato] INT      IDENTITY (10000, 1) NOT NULL,
    [idContrato]        INT      NOT NULL,
    [idProceso]         INT      NOT NULL,
    [CreadoPor]         INT      NULL,
    [CreadoEn]          DATETIME NULL,
    [ModificadoPor]     INT      NULL,
    [ModificadoEn]      DATETIME NULL,
    [Activo]            BIT      NULL,
    CONSTRAINT [PK_EN_ProcesoContrato] PRIMARY KEY CLUSTERED ([idContrato] ASC, [idProceso] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EN_ProcesoContrato_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_ProcesoContrato_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_ProcesoContrato_CO_Contrato] FOREIGN KEY ([idContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_EN_ProcesoContrato_EN_Procesos] FOREIGN KEY ([idProceso]) REFERENCES [dbo].[EN_Procesos] ([IdProceso])
);

