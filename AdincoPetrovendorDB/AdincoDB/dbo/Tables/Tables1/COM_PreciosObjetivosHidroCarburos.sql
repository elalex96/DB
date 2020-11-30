CREATE TABLE [dbo].[COM_PreciosObjetivosHidroCarburos] (
    [IdContrato]         INT        NOT NULL,
    [Mes]                DATE       NOT NULL,
    [IdTipoHidrocarburo] INT        NOT NULL,
    [PrecioUnitario]     FLOAT (53) NULL,
    [CreadoPor]          INT        NULL,
    [CreadoEl]           DATETIME   NULL,
    [ModificadoPor]      INT        NULL,
    [ModificadoEl]       DATETIME   NULL,
    CONSTRAINT [PK_COM_PreciosObjetivosHidroCarburos] PRIMARY KEY CLUSTERED ([IdContrato] ASC, [Mes] ASC, [IdTipoHidrocarburo] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_COM_PreciosObjetivosHidroCarburos_CO_CONTRATO] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_COM_PreciosObjetivosHidroCarburos_CO_TIPOHIDROCARBURO] FOREIGN KEY ([IdTipoHidrocarburo]) REFERENCES [dbo].[CO_TipoHidrocarburo] ([IdTipoHidrocarburo])
);

