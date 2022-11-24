CREATE TABLE [dbo].[PV_CuentaBancariaSubContratista] (
    [IdCtaBancariaProveedor] INT IDENTITY (1, 1) NOT NULL,
    [IdCuentaBancaria]       INT NULL,
    [IdSubcontratista]       INT NULL,
    [IsActivo]               BIT NULL,
    CONSTRAINT [PK_PV_CuentaBancariaSubContratista] PRIMARY KEY CLUSTERED ([IdCtaBancariaProveedor] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PV_CuentaBancariaSubContratista_PV_CuentaBancaria] FOREIGN KEY ([IdCuentaBancaria]) REFERENCES [dbo].[PV_CuentaBancaria] ([DatoBancarioID]),
    CONSTRAINT [FK_PV_CuentaBancariaSubContratista_S_Proveedor] FOREIGN KEY ([IdSubcontratista]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);

