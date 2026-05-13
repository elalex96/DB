CREATE TABLE [dbo].[FI_CFDIImpuesto] (
    [IdCFDIImpuesto] INT            IDENTITY (1, 1) NOT NULL,
    [IdFactura]      INT            NULL,
    [IdTipoImpuesto] INT            NULL,
    [NombreImpuesto] NVARCHAR (50)  NULL,
    [Impuesto]       NVARCHAR (MAX) NULL,
    [TipoFactor]     NVARCHAR (50)  NULL,
    [Tasa]           FLOAT (53)     NULL,
    [Importe]        MONEY          NULL,
    [Bit_Retencion]  BIT            CONSTRAINT [DF__FI_CFDIIm__Bit_R__4D37C244] DEFAULT ((0)) NULL,
    [Base]           MONEY          NULL,
    CONSTRAINT [PK_FI_CFDIImpuesto] PRIMARY KEY CLUSTERED ([IdCFDIImpuesto] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

