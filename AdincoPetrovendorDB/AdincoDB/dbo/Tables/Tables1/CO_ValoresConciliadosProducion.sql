CREATE TABLE [dbo].[CO_ValoresConciliadosProducion] (
    [IdValoresConciliadosProducion]	INT	IDENTITY (10000, 1)	NOT NULL,
    [PuntoEntregaID]				INT						NOT NULL,
	[Mes]							DATE					NOT NULL,
	[Aceite]						FLOAT					NOT NULL,
	[Gas]							FLOAT					NOT NULL,
	[Agua]							FLOAT					NOT NULL,
    [IdContrato]					INT						NOT NULL,
    [CreadoPor]						INT						NOT NULL,
    [CreadoEl]						DATETIME				NOT NULL,
    [ModificadoPor]					INT						NULL,
    [ModificadoEl]					DATETIME				NULL,
    [Activo]						BIT						NOT NULL,
    PRIMARY KEY CLUSTERED ([IdValoresConciliadosProducion] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([PuntoEntregaID]) REFERENCES [dbo].[CO_PuntosdeEntrega] ([PuntoEntregaID]),
	FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
	FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
	FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);