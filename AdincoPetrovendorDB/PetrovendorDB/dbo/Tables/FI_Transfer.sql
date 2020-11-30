CREATE TABLE [dbo].[FI_Transfer] (
    [IdTransferencia]          INT            IDENTITY (1, 1) NOT NULL,
    [IdContrato]               INT            NULL,
    [IdComprobantePago]        NVARCHAR (50)  NULL,
    [NombreExtencionArchivo]   NVARCHAR (MAX) NULL,
    [ReferenciaBancaria]       NVARCHAR (50)  NULL,
    [FechaPago]                DATE           NULL,
    [IdCuentaOrigen]           INT            NULL,
    [IdCuentaDestino]          INT            NULL,
    [MontoPagado]              MONEY          NULL,
    [IdMoneda]                 INT            NULL,
    [IdClasificacionDocumento] INT            NULL,
    [Concepto]                 NVARCHAR (MAX) NULL,
    [IdMetodoPago]             INT            NULL,
    [ProcesadoSIPAC]           BIT            NULL,
    [NumeroPolizaContable]     INT            NULL,
    [Intereses]                MONEY          NULL,
    [PDF]                      NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_FI_Transfer] PRIMARY KEY CLUSTERED ([IdTransferencia] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

