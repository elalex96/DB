CREATE TABLE [dbo].[CO_PrecioMarcadorMensual] (
    [IdPrecioMarcadorMensual] INT      IDENTITY (10000, 1) NOT NULL,
    [IdMarcador]              INT      NOT NULL,
    [IdContrato]              INT      NOT NULL,
    [Mes]                     DATE     NOT NULL,
    [Precio]                  MONEY    NULL,
    [CreadoPor]               INT      NULL,
    [CreadoEn]                DATETIME NULL,
    [ModificadoPor]           INT      NULL,
    [ModificadoEl]            DATETIME NULL,
    CONSTRAINT [PK_CO_PrecioMarcadorMensual] PRIMARY KEY CLUSTERED ([IdMarcador] ASC, [IdContrato] ASC, [Mes] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_PrecioMarcadorMensual_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_CO_PrecioMarcadorMensual_CO_Marcador] FOREIGN KEY ([IdMarcador]) REFERENCES [dbo].[CO_Marcador] ([IdMarcador])
);

