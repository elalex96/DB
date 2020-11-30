CREATE TABLE [dbo].[EN_ResponsablesEntregableContrato] (
    [idResponsableEntregableContrato] INT IDENTITY (10000, 1) NOT NULL,
    [idContratoEntregable]            INT NULL,
    [UsuarioId]                       INT NULL,
    [idTipoResponsable]               INT NULL,
    PRIMARY KEY CLUSTERED ([idResponsableEntregableContrato] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([idContratoEntregable]) REFERENCES [dbo].[EN_ContratoEntregable] ([IdContratoEntregable]),
    FOREIGN KEY ([idTipoResponsable]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    FOREIGN KEY ([UsuarioId]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

