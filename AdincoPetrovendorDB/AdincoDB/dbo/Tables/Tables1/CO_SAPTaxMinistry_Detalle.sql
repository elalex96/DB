CREATE TABLE [dbo].[CO_SAPTaxMinistry_Detalle] (
    [SAPPayType]         VARCHAR (2) NOT NULL,
    [IdTaxMinistry]      TINYINT     NOT NULL,
    [IdContrato]         INT         NOT NULL,
    [IdMetodoPagoAdinco] INT         NOT NULL,
    [CreadoEl]           DATETIME    NOT NULL,
    CONSTRAINT [PK_CO_SAP_TaxMinistry_Detalle] PRIMARY KEY CLUSTERED ([SAPPayType] ASC, [IdTaxMinistry] ASC, [IdContrato] ASC, [IdMetodoPagoAdinco] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_SAPTaxMinistry_Detalle_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_CO_SAPTaxMinistry_Detalle_CO_SAPTaxMinistry] FOREIGN KEY ([IdTaxMinistry]) REFERENCES [dbo].[CO_SAPTaxMinistry] ([IdSAPTaxMinistry]),
    CONSTRAINT [FK_CO_SAPTaxMinistry_Detalle_PV_MetodoPago] FOREIGN KEY ([IdMetodoPagoAdinco]) REFERENCES [dbo].[PV_MetodoPago] ([idMetodoPago])
);

