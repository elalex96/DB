CREATE TABLE [dbo].[FI_ComplementoDePago] (
    [IdComplementoDePago] INT            IDENTITY (1, 1) NOT NULL,
    [IdFactura]           INT            NULL,
    [Version]             FLOAT (53)     NULL,
    [FechaDePago]         DATETIME       NULL,
    [MonedaP]             NVARCHAR (50)  NULL,
    [FormaDePagoP]        NVARCHAR (50)  NULL,
    [Monto]               MONEY          NULL,
    [NumOperacion]        NVARCHAR (50)  NULL,
    [RfcEmisorCtaOrd]     NVARCHAR (50)  NULL,
    [NomBancoOrdExt]      NVARCHAR (MAX) NULL,
    [CtaOrdenante]        NVARCHAR (50)  NULL,
    [RfcEmisorCtaBen]     NVARCHAR (50)  NULL,
    [CtaBeneficiario]     NVARCHAR (50)  NULL,
    [TipoDeCambio]        FLOAT (53)     NULL,
    [EliminadoEl]         DATETIME       NULL,
    [EliminadoPor]        INT            NULL,
    [IsEliminado]         BIT            NULL,
    CONSTRAINT [PK_FI_ComplementoDePago] PRIMARY KEY CLUSTERED ([IdComplementoDePago] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FI_ComplementoDePago_FI_Factura] FOREIGN KEY ([IdFactura]) REFERENCES [dbo].[FI_Factura] ([IdFactura])
);

