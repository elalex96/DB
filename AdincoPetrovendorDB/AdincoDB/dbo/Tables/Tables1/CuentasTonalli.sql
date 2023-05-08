CREATE TABLE [dbo].[CuentasTonalli] (
    [BancoID]         INT            NULL,
    [Banco]           NVARCHAR (255) NULL,
    [NumeroCuenta]    FLOAT (53)     NULL,
    [Titular]         NVARCHAR (255) NULL,
    [Sucursal]        NVARCHAR (255) NULL,
    [CLABE]           NVARCHAR (50)  NULL,
    [NumeroTarjeta]   NVARCHAR (255) NULL,
    [TipoMonedaID]    INT            NULL,
    [Moneda]          NVARCHAR (255) NULL,
    [IdProveedor]     INT            NULL,
    [ProveedorPropia] NVARCHAR (255) NULL,
    [Predeterminada]  BIT            NULL,
    [TipoTarjeta]     INT            NULL,
    [IdContratista]   INT            NULL,
    [Activa]          BIT            NULL
);

