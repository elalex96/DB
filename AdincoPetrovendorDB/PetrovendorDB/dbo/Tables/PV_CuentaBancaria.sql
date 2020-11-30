CREATE TABLE [dbo].[PV_CuentaBancaria] (
    [DatoBancarioID]          INT           IDENTITY (1, 1) NOT NULL,
    [BancoID]                 INT           NULL,
    [Titular]                 VARCHAR (MAX) NULL,
    [Sucursal]                VARCHAR (MAX) NULL,
    [NumeroCuenta]            VARCHAR (MAX) NULL,
    [CuentaClabe]             VARCHAR (MAX) NULL,
    [TipoMonedaID]            INT           NULL,
    [IdProveedor]             INT           NULL,
    [Predeterminado]          BIT           NULL,
    [TipoCuentaInterbancaria] INT           NULL,
    [EstadoCuentaDelBanco]    INT           NULL,
    [IsEliminado]             BIT           NULL,
    CONSTRAINT [PK_S_CuentaBancaria] PRIMARY KEY CLUSTERED ([DatoBancarioID] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PV_CuentaBancaria_PV_TipoCuentaInterbancaria] FOREIGN KEY ([TipoCuentaInterbancaria]) REFERENCES [dbo].[PV_TipoCuentaInterbancaria] ([IdTipoCuentaInterbancaria]),
    CONSTRAINT [FK_S_CuentaBancaria_PV_Banco] FOREIGN KEY ([BancoID]) REFERENCES [dbo].[PV_Banco] ([BancoID]),
    CONSTRAINT [FK_S_CuentaBancaria_PV_TipoMoneda] FOREIGN KEY ([TipoMonedaID]) REFERENCES [dbo].[PV_TipoMoneda] ([IdMoneda]),
    CONSTRAINT [FK_S_CuentaBancaria_S_Proveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);

