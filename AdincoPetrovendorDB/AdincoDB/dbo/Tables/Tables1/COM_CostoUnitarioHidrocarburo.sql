CREATE TABLE [dbo].[COM_CostoUnitarioHidrocarburo] (
    [IdContrato]                    INT      NOT NULL,
    [Mes]                           DATE     NOT NULL,
    [IdTipoHidrocarburo]            INT      NOT NULL,
    [CostoUnitarioComercializacion] MONEY    NULL,
    [CreadoPor]                     INT      NULL,
    [CreadoEl]                      DATETIME NULL,
    [ModificadoPor]                 INT      NULL,
    [ModificadoEl]                  DATETIME NULL,
    CONSTRAINT [PK_COM_COSTOUNITARIOHIDROCARBURO] PRIMARY KEY CLUSTERED ([IdContrato] ASC, [Mes] ASC, [IdTipoHidrocarburo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_COM_COSTOUNITARIOHIDROCARBURO_CO_CONTRATO] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_COM_COSTOUNITARIOHIDROCARBURO_CO_TIPOHIDROCARBURO] FOREIGN KEY ([IdTipoHidrocarburo]) REFERENCES [dbo].[CO_TipoHidrocarburo] ([IdTipoHidrocarburo])
);

