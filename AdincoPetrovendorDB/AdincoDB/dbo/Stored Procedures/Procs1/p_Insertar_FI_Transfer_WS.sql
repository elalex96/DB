CREATE PROC p_Insertar_FI_Transfer_WS
@pIdContratistaSIPAC VARCHAR(10),
@pIdRegistroFiduciario VARCHAR(20),
@pPeriodoReporte DATETIME,
@pIdComprobantePago VARCHAR(20),
@pNombreArchivoAsociado VARCHAR(500),
@pReferenciaBacariaOp VARCHAR(100),
@pFechaPago DATETIME,
@pBeneficiario VARCHAR(200),
@pMontoPagado MONEY,
@pMonedaFuncional VARCHAR(10),
@pCuentaOrigen VARCHAR(20),
@pBancoOrigenNacional VARCHAR(250),
@pBancoOrigenExtranjero VARCHAR(250),
@pCuentaDestino VARCHAR(20),
@pBancoDestinoNacional VARCHAR(250),
@pBancoDestinoExtranjero VARCHAR(250),
@pMontoEquivalenteUSD MONEY,
@pTipoCambioUnidadesUSD MONEY,
@pClasificacionDocSoporte INT
AS

	INSERT INTO dbo.FI_Transfer
(
    IdContrato,
    IdComprobantePago,
    NombreExtencionArchivo,
    ReferenciaBancaria,
    FechaPago,
    IdCuentaOrigen,
    IdCuentaDestino,
    MontoPagado,
    IdMoneda,
    IdClasificacionDocumento,
    Concepto,
    IdMetodoPago,
    ProcesadoSIPAC,
    NumeroPolizaContable,
    Intereses,
    PDF,
    CreadoPor,
    CreadoEn,
    ModificadoPor,
    ModificadoEn
)
VALUES
(   0,         -- IdContrato - int
    N'',       -- IdComprobantePago - nvarchar(50)
    N'',       -- NombreExtencionArchivo - nvarchar(max)
    N'',       -- ReferenciaBancaria - nvarchar(50)
    GETDATE(), -- FechaPago - date
    0,         -- IdCuentaOrigen - int
    0,         -- IdCuentaDestino - int
    NULL,      -- MontoPagado - money
    0,         -- IdMoneda - int
    0,         -- IdClasificacionDocumento - int
    N'',       -- Concepto - nvarchar(max)
    0,         -- IdMetodoPago - int
    NULL,      -- ProcesadoSIPAC - bit
    0,         -- NumeroPolizaContable - int
    NULL,      -- Intereses - money
    N'',       -- PDF - nvarchar(max)
    0,         -- CreadoPor - int
    GETDATE(), -- CreadoEn - datetime
    0,         -- ModificadoPor - int
    GETDATE()  -- ModificadoEn - datetime
    )



