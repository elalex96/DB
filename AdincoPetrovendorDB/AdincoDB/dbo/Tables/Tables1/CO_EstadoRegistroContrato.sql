CREATE TABLE [dbo].[CO_EstadoRegistroContrato] (
    [IdEstadoRegistro] INT NOT NULL,
    [IdContrato]       INT NOT NULL,
    [SoloLectura]      BIT NOT NULL,
    CONSTRAINT [PK_CO_EstadoRegistroContrato] PRIMARY KEY CLUSTERED ([IdEstadoRegistro] ASC, [IdContrato] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_EstadoRegistroContrato_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_CO_EstadoRegistroContrato_CO_EstadoRegistro] FOREIGN KEY ([IdEstadoRegistro]) REFERENCES [dbo].[CO_EstadoRegistro] ([IdEstadoRegistro])
);

