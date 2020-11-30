CREATE TABLE [dbo].[tmp_AmatitlanAuditoria] (
    [Tipo de Servicio]        NVARCHAR (255) NULL,
    [Actividad]               NVARCHAR (255) NULL,
    [Servicio]                NVARCHAR (255) NULL,
    [NombreProveedor]         NVARCHAR (255) NULL,
    [Numero Factura]          NVARCHAR (MAX) NULL,
    [Fecha Factura]           DATETIME       NULL,
    [Moneda]                  NVARCHAR (255) NULL,
    [Mes del Informe]         NVARCHAR (255) NULL,
    [Mes de Certificado]      NVARCHAR (255) NULL,
    [Monto Factura]           FLOAT (53)     NULL,
    [Monto de Factura en USD] FLOAT (53)     NULL,
    [Periodo]                 NVARCHAR (255) NULL
);

