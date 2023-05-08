CREATE TABLE [dbo].[PR_FI_CFDIConcepto] (
    [IdFacturaConcepto] BIGINT         NOT NULL,
    [IdFactura]         INT            NULL,
    [ClaveProdServ]     NVARCHAR (50)  NULL,
    [Cantidad]          FLOAT (53)     NULL,
    [ClaveUnidad]       NVARCHAR (50)  NULL,
    [Unidad]            NVARCHAR (MAX) NULL,
    [Descripcion]       NVARCHAR (MAX) NULL,
    [ValorUnitario]     MONEY          NULL,
    [Importe]           MONEY          NULL,
    [NoIdentificacion]  NVARCHAR (MAX) NULL,
    [IdEliminacion]     INT            NULL,
    [IdReciclaje]       INT            IDENTITY (1, 1) NOT NULL
);

