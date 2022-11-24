CREATE PROCEDURE [dbo].[FI_SP_RegistroComplementoPagoComprobante]
	@IdFactura INT,
	@Version FLOAT,
	@FechaDePago DATETIME,
	@MonedaP NVARCHAR(50),
	@FormaDePagoP NVARCHAR(50),
	@Monto MONEY,
	@NumOperacion NVARCHAR(50),
	@RfcEmisorCtaOrd NVARCHAR(50),
	@NomBancoOrdExt NVARCHAR(max),
	@CtaOrdenante NVARCHAR(50),
	@RfcEmisorCtaBen NVARCHAR(50),
	@CtaBeneficiario NVARCHAR(50),
	@TipoDeCambio FLOAT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null,
	/*-------------------------------------------------------------*/
	@documentoRelacionado varchar(max) 
AS
BEGIN
	
	DECLARE @IdComplementoPetrovendor INT, @IdDocumentoRelacionado INT;
			
	--Registro en petrovendor
	INSERT INTO dbo.FI_ComplementoDePago
	(
	    IdFactura,
	    Version,
	    FechaDePago,
	    MonedaP,
	    FormaDePagoP,
	    Monto,
	    NumOperacion,
	    RfcEmisorCtaOrd,
	    NomBancoOrdExt,
	    CtaOrdenante,
	    RfcEmisorCtaBen,
	    CtaBeneficiario,
	    TipoDeCambio
	)
	VALUES
	(   @IdFactura,
		@Version,
		@FechaDePago,
		@MonedaP,
		@FormaDePagoP,
		@Monto,
		@NumOperacion,
		@RfcEmisorCtaOrd,
		@NomBancoOrdExt,
		@CtaOrdenante,
		@RfcEmisorCtaBen,
		@CtaBeneficiario,
		@TipoDeCambio
	)

	SET @IdComplementoPetrovendor = SCOPE_IDENTITY()
	SELECT @IdComplementoPetrovendor,0 AS IdComplementoAdinco  --@IdComplementoAdinco 
	IF @documentoRelacionado IS NOT NULL
	BEGIN 
		--SE ACTUALIZA LA FECHA DE CO_REGISTRO
		set @IdDocumentoRelacionado = (select top 1 IdFactura from Adinco..fi_factura where UUID = @documentoRelacionado)
		if	@IdDocumentoRelacionado > 0
		BEGIN
			UPDATE Adinco..CO_Registro
			set MesPresentacion = DATEFROMPARTS(YEAR(@FechaDePago),MONTH(@FechaDePago),1),
			ModificadoEn = GETDATE()
			WHERE IdFactura = @IdDocumentoRelacionado
		END
	END
END