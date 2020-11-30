-- Stored Procedure


CREATE PROC [dbo].[p_Insertar_WS_Transferencia]
@pUsuarioAdinco VARCHAR(100),
@pPasswordAdinco VARCHAR(100),
@pIdWSTransfer	INT out,
@pIdContratistaSIPAC	varchar(20),
@pIdFiduciarioContrato	varchar(100),
@pPeriodoReporte	datetime,
@pIdComprobantePago	varchar(50),
@pNombreArchivoAsociado	varchar(250),
@pReferenciaBancariaOp	varchar(50),
@pFechaPago	datetime,
@pBeneficiario	varchar(250),
@pMontoPagado	money,
@pMonedaNacional	varchar(10),
@pCuentaOrigen	varchar(20),
@pBancoOrigenNacional	varchar(50),
@pBancoOrigenExtranjero	varchar(50),
@pCuentaDestino	varchar(20),
@pBancoDestinoNacional	varchar(50),
@pBancoDestinoExtranjero	varchar(50),
@pMontoEquivalenteUSD	money,
@pTipoCambioUSD	money,
@pIdClasificacionDocumento	int,
@pChequeNumero	varchar(10),
@pMontoPagadoLetra	varchar(250),
@pWSError	varchar(250) out
AS

	DECLARE @IdCuentaOrigen INT,
			@IdCuentaDestino INT,
			@IdMoneda INT,
			@IdUsuario int
            

	/*********Validar que el usuario y contraseña sean correctos********/
	IF NOT EXISTS (
		SELECT 1
		FROM dbo.AP_Usuario 
		WHERE Usuario = @pUsuarioAdinco AND
        Contraseña = @pPasswordAdinco
	)
	BEGIN 
		SET @pWSError = 'El usuario no es válido'
		return
	end



	SELECT @pIdWSTransfer = ISNULL(MAX(IdWSTransfer),0)
	FROM WS_Transferencia

	

	INSERT INTO dbo.WS_Transferencia
	(
	    IdWSTransfer,
	    IdContratistaSIPAC,
	    IdFiduciarioContrato,
	    PeriodoReporte,
	    IdComprobantePago,
	    NombreArchivoAsociado,
	    ReferenciaBancariaOp,
	    FechaPago,
	    Beneficiario,
	    MontoPagado,
	    MonedaNacional,
	    CuentaOrigen,
	    BancoOrigenNacional,
	    BancoOrigenExtranjero,
	    CuentaDestino,
	    BancoDestinoNacional,
	    BancoDestinoExtranjero,
	    MontoEquivalenteUSD,
	    TipoCambioUSD,
	    IdClasificacionDocumento,
	    ChequeNumero,
	    MontoPagadoLetra,
	    WSFechaRegistro,
	    WSError,
	    TransferenciaAplicada
	)
	VALUES
	(   @pIdWSTransfer,
	    @pIdContratistaSIPAC,
	    @pIdFiduciarioContrato,
	    @pPeriodoReporte,
	    @pIdComprobantePago,
	    @pNombreArchivoAsociado,
	    @pReferenciaBancariaOp,
	    @pFechaPago,
	    @pBeneficiario,
	    @pMontoPagado,
	    @pMonedaNacional,
	    @pCuentaOrigen,
	    @pBancoOrigenNacional,
	    @pBancoOrigenExtranjero,
	    @pCuentaDestino,
	    @pBancoDestinoNacional,
	    @pBancoDestinoExtranjero,
	    @pMontoEquivalenteUSD,
	    @pTipoCambioUSD,
	    @pIdClasificacionDocumento,
	    @pChequeNumero,
	    @pMontoPagadoLetra,
	    GETDATE(),
	    @pWSError,
	    0 -- TransferenciaAplicada - bit
	    )


	IF @@error <> 0
	BEGIN
		SET @pIdWSTransfer = 0
		ROLLBACK TRAN
		GOTO fin
    END

	/*******************************Aplicar la transacción***************************************/
	

	SELECT @IdCuentaOrigen = DatoBancarioID		
	FROM dbo.PV_CuentaBancaria
	WHERE CuentaClave = @pCuentaOrigen


	SELECT @IdCuentaDestino = DatoBancarioID		
	FROM dbo.PV_CuentaBancaria
	WHERE CuentaClave = @pCuentaDestino

	SELECT @IdMoneda = IdMoneda
	FROM dbo.PV_TipoMoneda
	WHERE TipoMonedaCorto = @pMonedaNacional

	SELECT @IdUsuario  =UsuarioID
	FROM dbo.AP_Usuario
	WHERE Usuario = @pUsuarioAdinco


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
	    @pIdComprobantePago,       -- IdComprobantePago - nvarchar(50)
	    @pNombreArchivoAsociado,       -- NombreExtencionArchivo - nvarchar(max)
	    @pReferenciaBancariaOp,       -- ReferenciaBancaria - nvarchar(50)
	    @pFechaPago, -- FechaPago - date
	    @IdCuentaOrigen,         -- IdCuentaOrigen - int
	    @IdCuentaDestino,         -- IdCuentaDestino - int
	    @pMontoPagado,      -- MontoPagado - money
	    @IdMoneda,         -- IdMoneda - int
	    @pIdClasificacionDocumento,         -- IdClasificacionDocumento - int
	    N'',       -- Concepto - nvarchar(max)
	    CASE WHEN ISNULL(@pChequeNumero,'') <> '' THEN 1 ELSE 7 end,         -- IdMetodoPago - int
	    NULL,      -- ProcesadoSIPAC - bit
	    0,         -- NumeroPolizaContable - int
	    NULL,      -- Intereses - money
	    N'',       -- PDF - nvarchar(max)
	    @IdUsuario,         -- CreadoPor - int
	    GETDATE(), -- CreadoEn - datetime
	    NULL,         -- ModificadoPor - int
	    NULL  -- ModificadoEn - datetime
	    )
    
	IF @@error <> 0
	BEGIN
		SET @pIdWSTransfer = 0
		ROLLBACK TRAN
		GOTO fin
    END


	UPDATE WS_Transferencia
	SET TransferenciaAplicada = 1
	WHERE IdWSTransfer = @pIdWSTransfer

	IF @@error <> 0
	BEGIN
		SET @pIdWSTransfer = 0
		ROLLBACK TRAN
		GOTO fin
    END


	COMMIT TRAN

	fin:
