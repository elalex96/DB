CREATE TABLE [dbo].[RPTFLUJOFACTURAS] (
    [NCompra]           INT            NULL,
    [RazonSocial]       NVARCHAR (MAX) NULL,
    [NPedido]           INT            NULL,
    [FechaCreacion]     DATETIME       NULL,
    [CentroCosto]       NVARCHAR (MAX) NULL,
    [CuentaContable]    NVARCHAR (MAX) NULL,
    [CuentaSectorHid]   NVARCHAR (MAX) NULL,
    [MontoFactura]      FLOAT (53)     NULL,
    [MontoTotalPagar]   FLOAT (53)     NULL,
    [MontoEjercido]     FLOAT (53)     NULL,
    [InicioEjecucion]   DATETIME       NULL,
    [FinEjecucion]      DATETIME       NULL,
    [NombreInstalacion] NVARCHAR (MAX) NULL,
    [Moneda]            NVARCHAR (MAX) NULL,
    [TipoOperacion]     NVARCHAR (MAX) NULL,
    [EstatusCompra]     NVARCHAR (MAX) NULL
);

