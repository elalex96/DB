CREATE TABLE [dbo].[CO_ComprobanteGastos] (
    [IdComprobanteGasto] INT           NOT NULL,
    [IdBeneficiario]     INT           NOT NULL,
    [IdContrato]         INT           NOT NULL,
    [IdFacturaGasto]     INT           NOT NULL,
    [Referencia]         VARCHAR (50)  NOT NULL,
    [Comentarios]        VARCHAR (250) NOT NULL,
    [CreadoEl]           DATETIME      NOT NULL,
    [CreadoPor]          INT           NOT NULL,
    CONSTRAINT [PK_CO_ComprobanteGastos_1] PRIMARY KEY CLUSTERED ([IdBeneficiario] ASC, [IdContrato] ASC, [IdFacturaGasto] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ComprobanteGastos_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_CO_ComprobanteGastos_FI_Factura] FOREIGN KEY ([IdFacturaGasto]) REFERENCES [dbo].[FI_Factura] ([IdFactura]),
    CONSTRAINT [FK_CO_ComprobanteGastos_PV_Subcontratista] FOREIGN KEY ([IdBeneficiario]) REFERENCES [dbo].[PV_Subcontratista] ([IdSubcontratista])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CO_ComprobanteGastos]
    ON [dbo].[CO_ComprobanteGastos]([IdComprobanteGasto] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

