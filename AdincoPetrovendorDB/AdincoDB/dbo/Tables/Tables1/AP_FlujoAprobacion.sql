CREATE TABLE [dbo].[AP_FlujoAprobacion] (
    [FlujoAprobacionId]     INT          NOT NULL,
    [IdContratista]         INT          NOT NULL,
    [Descripcion]           VARCHAR (50) NOT NULL,
    [TipoFlujoAprobacionId] SMALLINT     NOT NULL,
    [Activo]                BIT          NOT NULL,
    [CreadoEl]              DATETIME     NOT NULL,
    [CreadoPor]             INT          NOT NULL,
    CONSTRAINT [PK_AP_FlujosTrabajo] PRIMARY KEY CLUSTERED ([FlujoAprobacionId] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AP_FlujoAprobacion_AP_FlujoAprobacionTipos] FOREIGN KEY ([TipoFlujoAprobacionId]) REFERENCES [dbo].[AP_FlujoAprobacionTipos] ([TipoFlujoAprobacionId]),
    CONSTRAINT [FK_AP_FlujoAprobacion_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_AP_FlujoAprobacion_CO_Contratista] FOREIGN KEY ([IdContratista]) REFERENCES [dbo].[CO_Contratista] ([IdContratista])
);

