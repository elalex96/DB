CREATE TABLE [dbo].[COM_OperacionComercializacion_BAAC] (
    [IdOperacionComercializacion]   INT           IDENTITY (10000, 1) NOT NULL,
    [IdContrato]                    INT           NULL,
    [MesReporte]                    DATE          NULL,
    [FechaTransaccion]              DATE          NULL,
    [IdTipoHidrocarburo]            INT           NULL,
    [VolumenVendido]                FLOAT (53)    NULL,
    [PrecioVentaUnitario]           MONEY         NULL,
    [CostoUnitarioComercializacion] MONEY         NULL,
    [PrecioPuntoMedicion]           MONEY         NULL,
    [IdFactura]                     INT           NULL,
    [NumeroFolioPedimento]          NVARCHAR (15) NULL,
    [EPT]                           BIT           NULL,
    [OperacionBajoReglasMercado]    BIT           NULL,
    [ClasificacionDocumentoSoporte] INT           NULL,
    [CreadoPor]                     INT           NULL,
    [CreadoEl]                      DATETIME      NULL,
    [ModificadoPor]                 INT           NULL,
    [ModificadoEl]                  DATETIME      NULL,
    [Activo]                        BIT           NULL
);

