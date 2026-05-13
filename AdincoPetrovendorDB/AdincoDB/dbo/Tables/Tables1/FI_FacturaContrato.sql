CREATE TABLE [dbo].[FI_FacturaContrato] (
    [IdFacturaContrato] INT      IDENTITY (10000, 1) NOT NULL,
    [IdFactura]         INT      NULL,
    [IdContrato]        INT      NULL,
    [CreadoEn]          DATETIME NULL,
    [CreadoPor]         INT      NULL,
    [ModificadoEn]      DATETIME NULL,
    [ModificadoPor]     INT      NULL,
    CONSTRAINT [PK_FI_FacturaContrato] PRIMARY KEY CLUSTERED ([IdFacturaContrato] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FI_FacturaContrato_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

