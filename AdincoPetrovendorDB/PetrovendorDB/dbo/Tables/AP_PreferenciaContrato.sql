CREATE TABLE [dbo].[AP_PreferenciaContrato] (
    [Id]            INT    IDENTITY (1, 1) NOT NULL,
    [ContratoId]     INT   NOT NULL,
    [PreferenciaId] INT    NOT NULL,
    [Valor]         VARCHAR (MAX) NULL,
    [Activo]        BIT     NOT NULL,
	[CreadoEl]      DATETIME  NOT NULL,
	[CreadoPor]     INT NULL,
	[ModificadoPor]  INT NULL,
	[ModificadoEl]   DATETIME  NULL,
    CONSTRAINT [FK_AP_Preferencias_AP_PreferenciaContrato] FOREIGN KEY ([PreferenciaId]) REFERENCES [dbo].[AP_Preferencias] ([Id])
);