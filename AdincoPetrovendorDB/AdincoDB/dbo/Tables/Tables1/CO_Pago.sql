CREATE TABLE [dbo].[CO_Pago] (
    [IdPago]                      INT            IDENTITY (1, 1) NOT NULL,
    [IdContratista]               INT            NOT NULL,
    [IdTipoPago]                  INT            NOT NULL,
    [PagoFactura]                 BIT            NULL,
    [IdFacturaVU]                 INT            NULL,
    [IdEmpresaPP]                 INT            NOT NULL,
    [ReferenciaBancariaOperacion] NVARCHAR (50)  NULL,
    [FechaPago]                   DATE           NOT NULL,
    [Beneficiario]                NVARCHAR (100) NULL,
    [MontoPagado]                 MONEY          NULL,
    [IdMonedaFuncional]           INT            NULL,
    [IdBancoOrigen]               INT            NULL,
    [IdCuentaOrigen]              INT            NULL,
    [IdBancoDestino]              INT            NULL,
    [IdCuentaDestino]             INT            NULL,
    [NumeroCheque]                NVARCHAR (30)  NULL,
    [FolioBancarioTCDS]           NVARCHAR (30)  NULL,
    [NumeroTCD]                   NVARCHAR (16)  NULL,
    [CreadoPor]                   INT            NULL,
    CONSTRAINT [PK_Pagos] PRIMARY KEY CLUSTERED ([IdPago] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

