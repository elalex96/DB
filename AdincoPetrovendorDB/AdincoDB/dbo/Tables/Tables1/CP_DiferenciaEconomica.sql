CREATE TABLE [dbo].[CP_DiferenciaEconomica] (
    [IdDiferenciaEconomica] INT        IDENTITY (10000, 1) NOT NULL,
    [IdContrato]            INT        NOT NULL,
    [Mes]                   DATE       NOT NULL,
    [RegaliaBase]           FLOAT (53) NULL,
    [RegaliaAdicional]      FLOAT (53) NULL,
    [CuotaContractual]      FLOAT (53) NULL,
    [CreadoPor]             INT        NULL,
    [CreaadoEn]             DATETIME   NULL,
    [ModificadoPor]         INT        NULL,
    [ModificadoEn]          DATETIME   NULL,
    PRIMARY KEY CLUSTERED ([IdContrato] ASC, [Mes] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CP_DiferenciaEconomica_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CP_DiferenciaEconomica_AP_Usuario1] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CP_DiferenciaEconomica_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

