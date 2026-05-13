CREATE TABLE [dbo].[CO_CuentaOperativaFinal_2018] (
    [TipoServicio]     NVARCHAR (MAX) NULL,
    [IdTipoServicio]   INT            NULL,
    [Actividad]        NVARCHAR (MAX) NULL,
    [IdActividad]      INT            NULL,
    [Servicio]         NVARCHAR (MAX) NULL,
    [NombreProveedor]  NVARCHAR (MAX) NULL,
    [IdSubcontratista] INT            NULL,
    [NumeroFactura]    NVARCHAR (MAX) NULL,
    [FechaFactura]     DATETIME       NULL,
    [Moneda]           NVARCHAR (MAX) NULL,
    [MesInforme]       NVARCHAR (MAX) NULL,
    [MesCertificado]   NVARCHAR (MAX) NULL,
    [MontoFactura]     FLOAT (53)     NULL,
    [MontoFacturaUSD]  FLOAT (53)     NULL,
    [Periodo]          NVARCHAR (MAX) NULL
);

