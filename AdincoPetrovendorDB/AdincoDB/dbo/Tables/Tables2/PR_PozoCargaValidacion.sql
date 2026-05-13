CREATE TABLE [dbo].[PR_PozoCargaValidacion] (
    [IdPozo]        INT      NOT NULL,
    [IdContrato]    INT      NOT NULL,
    [ValidadoPor]   INT      NULL,
    [ValidadoEl]    DATETIME NULL,
    [ModificadoPor] INT      NULL,
    [ModificadoEl]  DATETIME NULL,
    CONSTRAINT [PK_PR_PozoCargaValidacion] PRIMARY KEY CLUSTERED ([IdPozo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PR_PozoCargaValidacion_AP_Usuario] FOREIGN KEY ([ValidadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_PR_PozoCargaValidacion_AP_Usuario1] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_PR_PozoCargaValidacion_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_PR_PozoCargaValidacion_PR_Pozo] FOREIGN KEY ([IdPozo]) REFERENCES [dbo].[PR_Pozo] ([Id])
);

