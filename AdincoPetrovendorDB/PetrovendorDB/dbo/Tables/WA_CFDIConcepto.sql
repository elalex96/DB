CREATE TABLE [dbo].[WA_CFDIConcepto] (
    [IdFacturaConcepto] BIGINT         NULL,
    [IdFactura]         INT            NULL,
    [Descripcion]       VARCHAR (MAX)  NULL,
    [Cantidad]          FLOAT (53)     NULL,
    [Unidad]            NVARCHAR (MAX) NULL,
    [ValorUnitario]     MONEY          NULL,
    [Importe]           MONEY          NULL,
    [NoIdentificacion]  NVARCHAR (MAX) NULL,
    [CreadoPor]         INT            NULL,
    [Descuento]         MONEY          NULL,
    [ClaveUnidad]       NVARCHAR (50)  NULL,
    [ClaveProdServ]     NVARCHAR (50)  NULL
);

