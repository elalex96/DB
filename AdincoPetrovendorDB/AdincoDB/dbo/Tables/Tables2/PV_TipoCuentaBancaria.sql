CREATE TABLE [dbo].[PV_TipoCuentaBancaria] (
    [IdTipoCuenta] INT            IDENTITY (1, 1) NOT NULL,
    [TipoCuenta]   NVARCHAR (250) NOT NULL,
    [Activo]       BIT            NULL,
    CONSTRAINT [PK_PV_TipoCuentaBancaria] PRIMARY KEY CLUSTERED ([IdTipoCuenta] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

