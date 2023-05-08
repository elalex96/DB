CREATE TABLE [dbo].[TMP_Jaguar_UUID] (
    [NumeroContrato]       NVARCHAR (255) NULL,
    [IdTransferencia]      FLOAT (53)     NULL,
    [Cuenta Origen]        FLOAT (53)     NULL,
    [Cuenta Destino]       FLOAT (53)     NULL,
    [RazonSocial]          NVARCHAR (255) NULL,
    [RFC]                  NVARCHAR (255) NULL,
    [ReferenciaBancaria]   FLOAT (53)     NULL,
    [FechaPago]            DATETIME       NULL,
    [MontoPagado]          MONEY          NULL,
    [Intereses]            FLOAT (53)     NULL,
    [MetodoPago]           NVARCHAR (255) NULL,
    [TipoMoneda]           NVARCHAR (255) NULL,
    [Concepto]             NVARCHAR (255) NULL,
    [NumeroPolizaContable] FLOAT (53)     NULL,
    [Comprobante de Pago]  NVARCHAR (255) NULL,
    [CreadoPor]            NVARCHAR (255) NULL,
    [Fecha Registro]       DATETIME       NULL,
    [UUID]                 NVARCHAR (255) NULL
);

