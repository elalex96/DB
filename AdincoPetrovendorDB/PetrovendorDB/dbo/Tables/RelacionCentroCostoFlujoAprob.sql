CREATE TABLE [dbo].[RelacionCentroCostoFlujoAprob] (
    [IdCentroCosto]      INT NOT NULL,
    [IdFlujo]            INT NULL,
    [Activo]             BIT DEFAULT ((0)) NULL,
    [IdFlujoFactura]     INT NULL,
    [IdFlujoComprobante] INT NULL
);

