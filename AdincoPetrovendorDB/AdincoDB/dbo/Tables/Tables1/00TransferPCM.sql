CREATE TABLE [dbo].[00TransferPCM] (
    [ID]                   FLOAT (53)     NULL,
    [FECHA FACTURA]        DATETIME       NULL,
    [RFC EMISOR]           NVARCHAR (255) NULL,
    [NOMBRE DEL PROVEEDOR] NVARCHAR (255) NULL,
    [FORMA DE PAGO]        NVARCHAR (255) NULL,
    [BANCO ORIGEN]         NVARCHAR (255) NULL,
    [CUENTA ORIGEN]        NVARCHAR (255) NULL,
    [BANCO DESTINO]        NVARCHAR (255) NULL,
    [CUENTA DESTINO]       NVARCHAR (255) NULL,
    [FECHA DE PAGO]        DATETIME       NULL,
    [MONTO PAGADO]         FLOAT (53)     NULL,
    [INTERES]              FLOAT (53)     NULL,
    [MONEDA PAGO]          NVARCHAR (255) NULL,
    [CONCEPTO]             NVARCHAR (255) NULL,
    [NO# DE POLIZA]        FLOAT (53)     NULL,
    [UUID]                 VARCHAR (500)  NULL,
    [VALOR FACTURA]        FLOAT (53)     NULL,
    [MONEDA FACTURA]       NVARCHAR (255) NULL,
    [IdTransfer]           INT            NULL
);

