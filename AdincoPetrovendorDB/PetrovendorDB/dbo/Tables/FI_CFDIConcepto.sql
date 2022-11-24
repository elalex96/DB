CREATE TABLE [dbo].[FI_CFDIConcepto] (
    [IdFacturaConcepto] BIGINT         IDENTITY (10000, 1) NOT NULL,
    [IdFactura]         INT            NULL,
    [Descripcion]       VARCHAR (MAX)  NULL,
    [Cantidad]          FLOAT (53)     NULL,
    [Unidad]            NVARCHAR (MAX) NULL,
    [ValorUnitario]     MONEY          NULL,
    [Importe]           MONEY          NULL,
    [NoIdentificacion]  NVARCHAR (MAX) NULL,
    [CreadoPor]         INT            NULL,
    [ClaveProdServ]     NVARCHAR (50)  NULL,
    [ClaveUnidad]       NVARCHAR (50)  NULL,
    [Descuento]         MONEY          NULL,
    CONSTRAINT [PK_FacturaConcepto] PRIMARY KEY CLUSTERED ([IdFacturaConcepto] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_VU_FacturaConcepto_VU_Factura] FOREIGN KEY ([IdFactura]) REFERENCES [dbo].[FI_Factura] ([IdFactura])
);

