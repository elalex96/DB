CREATE TABLE [dbo].[FI_CFDIImpuesto] (
    [IdCFDIImpuesto] INT            IDENTITY (1, 1) NOT NULL,
    [IdFactura]      INT            NULL,
    [IdTipoImpuesto] INT            NULL,
    [Impuesto]       NVARCHAR (MAX) NOT NULL,
    [Tasa]           FLOAT (53)     NULL,
    [Importe]        MONEY          NULL,
    [CreadoPor]      INT            NULL,
    CONSTRAINT [PK_FI_CFDIImpuesto] PRIMARY KEY CLUSTERED ([IdCFDIImpuesto] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

