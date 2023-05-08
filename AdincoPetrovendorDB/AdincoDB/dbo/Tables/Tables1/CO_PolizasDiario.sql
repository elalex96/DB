CREATE TABLE [dbo].[CO_PolizasDiario] (
    [IdPoliza]        INT      NOT NULL,
    [IdContrato]      INT      NOT NULL,
    [Generada]        BIT      NOT NULL,
    [FechaGeneracion] DATETIME NULL,
    [CreadoEl]        DATETIME NOT NULL,
    [CreadoPor]       INT      NOT NULL,
    CONSTRAINT [PK_CO_PolizasDiario_1] PRIMARY KEY CLUSTERED ([IdPoliza] ASC, [IdContrato] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_PolizasDiario_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_PolizasDiario_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

