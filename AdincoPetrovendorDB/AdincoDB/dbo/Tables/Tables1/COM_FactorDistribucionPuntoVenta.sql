CREATE TABLE [dbo].[COM_FactorDistribucionPuntoVenta] (
    [IdFactorDistribucionPuntoVenta] INT        IDENTITY (10000, 1) NOT NULL,
    [Mes]                            DATE       NULL,
    [IdContrato]                     INT        NULL,
    [IdProductoHidrocarburo]         INT        NULL,
    [IdPuntoVentaHidrocarburos]      INT        NULL,
    [Factor]                         FLOAT (53) NULL,
    [FactorFinal]                    FLOAT (53) NULL,
    [CostoUnitarioComercializacion]  MONEY      NULL,
    CONSTRAINT [PK_COM_FactorDistribucionPuntoVenta] PRIMARY KEY CLUSTERED ([IdFactorDistribucionPuntoVenta] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_COM_FactorDistribucionPuntoVenta_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_COM_FactorDistribucionPuntoVenta_COM_ProductoHidrocarburo] FOREIGN KEY ([IdProductoHidrocarburo]) REFERENCES [dbo].[COM_ProductoHidrocarburo] ([IdProductoHidrocarburo]),
    CONSTRAINT [FK_COM_FactorDistribucionPuntoVenta_COM_PuntoVentaHidrocarburos] FOREIGN KEY ([IdPuntoVentaHidrocarburos]) REFERENCES [dbo].[COM_PuntoVentaHidrocarburos] ([IdPuntoVentaHidrocarburos])
);

