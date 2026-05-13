CREATE TABLE [dbo].[PR_FI_CFDIImpuesto] (
    [IdCFDIImpuesto] INT            NOT NULL,
    [IdFactura]      INT            NULL,
    [IdTipoImpuesto] INT            NULL,
    [Base]           MONEY          NULL,
    [Impuesto]       NVARCHAR (MAX) NOT NULL,
    [TipoFactor]     NVARCHAR (50)  NULL,
    [Tasa]           FLOAT (53)     NULL,
    [Importe]        MONEY          NULL,
    [IdEliminacion]  INT            NULL,
    [IdReciclaje]    INT            IDENTITY (1, 1) NOT NULL
);

