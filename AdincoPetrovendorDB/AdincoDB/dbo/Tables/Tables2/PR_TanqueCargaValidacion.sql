CREATE TABLE [dbo].[PR_TanqueCargaValidacion] (
    [IdTanque]      INT      NOT NULL,
    [IdContrato]    INT      NOT NULL,
    [ValidadoPor]   INT      NULL,
    [ValidadoEl]    DATETIME NULL,
    [ModificadoPor] INT      NULL,
    [ModificadoEl]  DATETIME NULL,
    CONSTRAINT [PK_PR_TanqueCargaValidacion] PRIMARY KEY CLUSTERED ([IdTanque] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PR_TanqueCargaValidacion_AP_Usuario] FOREIGN KEY ([ValidadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_PR_TanqueCargaValidacion_AP_Usuario1] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_PR_TanqueCargaValidacion_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_PR_TanqueCargaValidacion_PR_Tanque] FOREIGN KEY ([IdTanque]) REFERENCES [dbo].[PR_Tanque] ([Id])
);

