CREATE TABLE [dbo].[FI_FacturaPPD] (
    [IdFacturaPPD]    INT          IDENTITY (10000, 1) NOT NULL,
    [IdFactura]       INT          NULL,
    [IdContrato]      INT          NULL,
    [MetodoPago]      VARCHAR (50) NULL,
    [MesPresentacion] DATE         NULL,
    [Presupuesto]     INT          NULL,
    [FechaPago]       DATE         NULL,
    CONSTRAINT [PK_FI_FacturaPPD] PRIMARY KEY CLUSTERED ([IdFacturaPPD] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

