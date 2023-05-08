CREATE TABLE [dbo].[WA_CFDIImpuesto] (
    [IdCFDIImpuesto] INT            IDENTITY (1, 1) NOT NULL,
    [IdFactura]      INT            NULL,
    [IdTipoImpuesto] INT            NULL,
    [Impuesto]       NVARCHAR (MAX) NOT NULL,
    [Tasa]           FLOAT (53)     NULL,
    [Importe]        MONEY          NULL,
    [CreadoPor]      INT            NULL
);

