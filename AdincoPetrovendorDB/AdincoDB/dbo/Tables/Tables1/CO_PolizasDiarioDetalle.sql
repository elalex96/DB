CREATE TABLE [dbo].[CO_PolizasDiarioDetalle] (
    [IdGasto]    INT      NOT NULL,
    [IdPoliza]   INT      NOT NULL,
    [IdContrato] INT      NOT NULL,
    [CreadoEl]   DATETIME NULL,
    CONSTRAINT [PK_CO_PolizasDiarioDetalle] PRIMARY KEY CLUSTERED ([IdGasto] ASC, [IdPoliza] ASC, [IdContrato] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_PolizasDiarioDetalle_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_CO_PolizasDiarioDetalle_CO_Registro] FOREIGN KEY ([IdGasto]) REFERENCES [dbo].[CO_Registro] ([IdRegistro])
);

