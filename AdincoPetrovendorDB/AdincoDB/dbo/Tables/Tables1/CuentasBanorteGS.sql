CREATE TABLE [dbo].[CuentasBanorteGS] (
    [ID]                 NVARCHAR (255) NULL,
    [Nombre]             NVARCHAR (255) NULL,
    [RFC]                NVARCHAR (255) NULL,
    [Contacto]           NVARCHAR (255) NULL,
    [Correo Electrónico] NVARCHAR (255) NULL,
    [Teléfono]           FLOAT (53)     NULL,
    [Cuenta / Clabe]     FLOAT (53)     NULL,
    [Titular]            NVARCHAR (255) NULL,
    [TipoCuenta]         NVARCHAR (255) NULL,
    [Banco]              NVARCHAR (255) NULL,
    [Moneda]             NVARCHAR (255) NULL,
    [BancoInternacional] NVARCHAR (255) NULL,
    [ABASwift]           NVARCHAR (255) NULL,
    [PlazaDestino]       NVARCHAR (255) NULL,
    [Descripcion]        NVARCHAR (255) NULL,
    [Confirmación]       NVARCHAR (255) NULL,
    [Capturó]            FLOAT (53)     NULL,
    [Fecha de Captura]   DATETIME       NULL,
    [Ejecutó]            FLOAT (53)     NULL,
    [Fecha de Ejecución] DATETIME       NULL,
    [IdEmpresa]          FLOAT (53)     NULL
);

