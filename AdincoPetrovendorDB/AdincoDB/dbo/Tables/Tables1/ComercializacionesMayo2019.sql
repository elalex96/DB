CREATE TABLE [dbo].[ComercializacionesMayo2019] (
    [FechaTransaccion]              DATE          NULL,
    [NumComercializacion]           INT           NULL,
    [TipoHidrocarburo]              INT           NULL,
    [VolumenVendido]                FLOAT (53)    NULL,
    [PrecioVentaUnitario]           MONEY         NULL,
    [CostoUnitarioComercializacion] MONEY         NULL,
    [PrecioPuntoMedicion]           MONEY         NULL,
    [UUID]                          VARCHAR (150) NULL,
    [NumeroFolioPedimento]          NVARCHAR (30) NULL,
    [IdContrato]                    INT           NULL,
    [MesReporte]                    DATE          NULL,
    [IdTipoHidrocarburo]            INT           NULL,
    [IdFactura]                     INT           NULL
);

