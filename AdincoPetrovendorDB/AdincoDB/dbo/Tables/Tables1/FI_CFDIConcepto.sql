CREATE TABLE [dbo].[FI_CFDIConcepto] (
    [IdFacturaConcepto] BIGINT         IDENTITY (10000, 1) NOT NULL,
    [IdFactura]         INT            NULL,
    [ClaveProdServ]     NVARCHAR (50)  NULL,
    [Cantidad]          FLOAT (53)     NULL,
    [ClaveUnidad]       NVARCHAR (50)  NULL,
    [Unidad]            NVARCHAR (MAX) NULL,
    [Descripcion]       NVARCHAR (MAX) NULL,
    [ValorUnitario]     MONEY          NULL,
    [Importe]           MONEY          NULL,
    [NoIdentificacion]  NVARCHAR (MAX) NULL,
    [Descuento]         MONEY          DEFAULT ((0)) NULL,
    CONSTRAINT [PK_FacturaConcepto] PRIMARY KEY CLUSTERED ([IdFacturaConcepto] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_VU_FacturaConcepto_VU_Factura] FOREIGN KEY ([IdFactura]) REFERENCES [dbo].[FI_Factura] ([IdFactura])
);


GO
CREATE NONCLUSTERED INDEX [idx_IdFactura]
    ON [dbo].[FI_CFDIConcepto]([IdFactura] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

