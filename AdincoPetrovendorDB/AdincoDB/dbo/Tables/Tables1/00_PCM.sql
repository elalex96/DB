CREATE TABLE [dbo].[00_PCM] (
    [FECHA FACTURA]                                DATETIME       NULL,
    [RFC EMISOR]                                   NVARCHAR (255) NULL,
    [NOMBRE DEL PROVEEDOR]                         NVARCHAR (255) NULL,
    [UUID]                                         NVARCHAR (255) NULL,
    [CUENTA CONTABLE  (S-H)]                       NVARCHAR (255) NULL,
    [NO# POLIZA]                                   FLOAT (53)     NULL,
    [GASTO ADMINISTRATIVO (1) GASTO OPERATIVO (2)] FLOAT (53)     NULL
);

