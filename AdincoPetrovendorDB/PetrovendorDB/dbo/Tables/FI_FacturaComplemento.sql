CREATE TABLE [dbo].[FI_FacturaComplemento] (
    [IdFacturaComplemento] INT      IDENTITY (1, 1) NOT NULL,
    [IdComplemento]        INT      NULL,
    [IdFactura]            INT      NULL,
    [IdDocRelacionado]     INT      NULL,
    [MontoPagado]          MONEY    NULL,
    [EliminadoEl]          DATETIME NULL,
    [EliminadoPor]         INT      NULL,
    [IsEliminado]          BIT      NULL,
    CONSTRAINT [PK_FI_FacturaComplemento] PRIMARY KEY CLUSTERED ([IdFacturaComplemento] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FI_FacturaComplemento_FI_CPDocRelacionado] FOREIGN KEY ([IdDocRelacionado]) REFERENCES [dbo].[FI_CPDocRelacionado] ([IdDocRelacionado]),
    CONSTRAINT [FK_FI_FacturaComplemento_FI_Factura] FOREIGN KEY ([IdComplemento]) REFERENCES [dbo].[FI_Factura] ([IdFactura]),
    CONSTRAINT [FK_FI_FacturaComplemento_FI_Factura1] FOREIGN KEY ([IdFactura]) REFERENCES [dbo].[FI_Factura] ([IdFactura])
);

