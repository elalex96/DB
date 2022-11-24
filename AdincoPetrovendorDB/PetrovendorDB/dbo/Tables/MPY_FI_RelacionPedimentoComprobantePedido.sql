CREATE TABLE [dbo].[MPY_FI_RelacionPedimentoComprobantePedido] (
    [IdRelacionPedimentoComprobante] INT            IDENTITY (1, 1) NOT NULL,
    [IdPedido]                       NVARCHAR (50)  NULL,
    [NombreDoc]                      NVARCHAR (MAX) NULL,
    [Carpeta]                        VARCHAR (300)  NULL,
    [Identificador]                  VARCHAR (300)  NULL,
    [Extension]                      VARCHAR (300)  NULL,
    [Mime]                           NVARCHAR (300) NULL,
    [Activo]                         BIT            NULL,
    [CreadoPor]                      INT            NULL,
    [CreadoEl]                       DATETIME       NULL,
    [IdPedimentoComprobanteADINCO]   INT            NULL,
    [IdProveedorVenta]               NVARCHAR (50)  NULL,
    [Bucket]                         VARCHAR (200)  NULL,
    CONSTRAINT [PK_MPY_FI_RelacionPedimentoComprobantePedido] PRIMARY KEY CLUSTERED ([IdRelacionPedimentoComprobante] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

