CREATE TABLE [dbo].[JAGUAR201910] (
    [ID]                  FLOAT (53)     NULL,
    [FECHA_FACTURA]       DATETIME       NULL,
    [RFC_EMISOR]          NVARCHAR (255) NULL,
    [PROVEEDOR]           NVARCHAR (255) NULL,
    [UUID]                NVARCHAR (255) NULL,
    [CUENTA_CONTABLE]     NVARCHAR (255) NULL,
    [POLIZA]              FLOAT (53)     NULL,
    [GASTO_ADMIN]         FLOAT (53)     NULL,
    [IdFactura]           INT            NULL,
    [IdCatalogoCuentasSH] INT            NULL
);

