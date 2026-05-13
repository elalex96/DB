CREATE TYPE [dbo].[Type_UPD_SEPCNGastosPE] AS TABLE
(
    FilaExcel                   INT,
    IdPedimentoComprobante      INT           NULL,         -- NULL cuando el valor no es numérico
    IdPedimentoComprobanteRaw   NVARCHAR(100) NULL,         -- Valor original del Excel para trazabilidad
    CodigoSE                    NVARCHAR(100),
    IdContrato                  INT,
    Observaciones               NVARCHAR(MAX)
);
GO