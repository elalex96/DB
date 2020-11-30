CREATE TABLE [dbo].[FI_ComplementoDePago] (
    [IdComplementoDePago] INT            IDENTITY (10000, 1) NOT NULL,
    [IdFactura]           INT            NULL,
    [Version]             FLOAT (53)     NULL,
    [FechaDePago]         DATETIME       NULL,
    [MonedaP]             NVARCHAR (50)  NULL,
    [FormaDePagoP]        NVARCHAR (50)  NULL,
    [Monto]               MONEY          NULL,
    [NumOperacion]        NVARCHAR (100) NULL,
    [RfcEmisorCtaOrd]     NVARCHAR (50)  NULL,
    [NomBancoOrdExt]      NVARCHAR (MAX) NULL,
    [CtaOrdenante]        NVARCHAR (50)  NULL,
    [RfcEmisorCtaBen]     NVARCHAR (50)  NULL,
    [CtaBeneficiario]     NVARCHAR (50)  NULL,
    [TipoDeCambio]        FLOAT (53)     NULL,
    CONSTRAINT [PK_FI_ComplementoDePago] PRIMARY KEY CLUSTERED ([IdComplementoDePago] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FI_ComplementoDePago_FI_Factura] FOREIGN KEY ([IdFactura]) REFERENCES [dbo].[FI_Factura] ([IdFactura])
);

