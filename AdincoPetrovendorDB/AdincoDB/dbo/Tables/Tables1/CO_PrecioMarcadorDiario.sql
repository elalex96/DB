CREATE TABLE [dbo].[CO_PrecioMarcadorDiario] (
    [IdPrecioMarcadorDiario] INT             IDENTITY (10000, 1) NOT NULL,
    [IdMarcador]             INT             NOT NULL,
    [IdContrato]             INT             NOT NULL,
    [Mes]                    DATE            NOT NULL,
    [Precio]                 DECIMAL (18, 6) NULL,
    CONSTRAINT [PK_CO_PrecioMarcadorDiario] PRIMARY KEY CLUSTERED ([IdMarcador] ASC, [IdContrato] ASC, [Mes] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_PrecioMarcadorDiario_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_CO_PrecioMarcadorDiario_CO_Marcador] FOREIGN KEY ([IdMarcador]) REFERENCES [dbo].[CO_Marcador] ([IdMarcador])
);

