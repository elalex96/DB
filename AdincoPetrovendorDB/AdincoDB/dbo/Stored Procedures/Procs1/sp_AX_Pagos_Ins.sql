
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE	 PROC [dbo].[sp_AX_Pagos_Ins]
(

    --@IdPago					int	output,
    @FormaPago VARCHAR(8000),
    @CuentaOrigen VARCHAR(MAX),
    @BancoOrigen VARCHAR(8000),
    @TitularOrigen VARCHAR(8000),
    @CuentaDestino VARCHAR(MAX),
    @BancoDestino VARCHAR(8000),
    @TitularDestino VARCHAR(8000),
    @ReferenciaPago VARCHAR(8000) NULL,
    @FechaPago VARCHAR(MAX) NULL,
    @MontoPagado MONEY,
    @Interes MONEY,
    @Moneda VARCHAR(MAX),
    @Concepto VARCHAR(8000),
    @NoPolizaContable VARCHAR(MAX),
    @UUIDFacturaPagada VARCHAR(8000),
    @MontoPagadoFactura MONEY,
    @ComplementoPagoUUID VARCHAR(8000),
    @idAsientoPago VARCHAR(MAX),
	@RFC VARCHAR(MAX)
)
AS
BEGIN


    /**Validar nulos**/
    /*¿Validar si existe el pago?  Confirmar con RM**/

    INSERT INTO dbo.AX_PagosLog
    (
        FormaPago,
        CuentaOrigen,
        BancoOrigen,
        TitularOrigen,
        CuentaDestino,
        BancoDestino,
        TitularDestino,
        ReferenciaPago,
        FechaPago,
        MontoPagado,
        Interes,
        Moneda,
        Concepto,
        NoPolizaContable,
        UUIDFacturaPagada,
        MontoPagadoFactura,
        ComplementoPagoUUID,
        RECID,
		RFC,
		Fecharecepcion
    )
    VALUES
    (@FormaPago, @CuentaOrigen, @BancoOrigen, @TitularOrigen, @CuentaDestino, @BancoDestino, @TitularDestino,
     @ReferenciaPago, @FechaPago, @MontoPagado, @Interes, @Moneda, @Concepto, @NoPolizaContable, @UUIDFacturaPagada,
     @MontoPagadoFactura, @ComplementoPagoUUID, @idAsientoPago, @RFC, GETDATE())

    IF (
           ISNULL(@FormaPago, '') = ''
           OR ISNULL(@CuentaOrigen, '') = ''
           OR ISNULL(@BancoOrigen, '') = ''
           OR ISNULL(@TitularOrigen, '') = ''
           OR ISNULL(@CuentaDestino, '') = ''
           OR ISNULL(@BancoDestino, '') = ''
           OR ISNULL(@TitularDestino, '') = ''
           OR ISNULL(@FechaPago, '') = ''
           OR ISNULL(@Moneda, '') = ''
           OR ISNULL(@Concepto, '') = ''
           OR ISNULL(@NoPolizaContable, '') = ''
           OR ISNULL(@UUIDFacturaPagada, '') = ''
           OR ISNULL(@idAsientoPago, '') = ''
		   OR ISNULL(@RFC, '') = ''
       )
    BEGIN
        SELECT 
               CONCAT('ERROR DE VALIDACION EN DATOS: ', 
                         ISNULL(NULLIF( @FormaPago , ''), ' Forma Pago sin dato '),
                         ISNULL(NULLIF(@CuentaOrigen, ''), ' Cuenta Origen sin dato '),
                         ISNULL(NULLIF(@BancoOrigen, ''), ' BancoOrigen sin dato '),
                         ISNULL(NULLIF(@TitularOrigen, ''), ' Titular Origen sin dato '),
                         ISNULL(NULLIF(@CuentaDestino, ''), ' Cuenta Destino sin dato '),
                         ISNULL(NULLIF(@BancoDestino, ''), ' Banco Destino sin dato '),
                         ISNULL(NULLIF(@TitularDestino, ''), 'Titular Destino sin dato'),
                         ISNULL(NULLIF(@FechaPago, ''), ' Fecha Pago sin dato '),
                         ISNULL(NULLIF(@Moneda, ''), ' Moneda sin dato '),
                         ISNULL(NULLIF(@Concepto, ''), ' Concepto sin dato '),
                         ISNULL(NULLIF(@NoPolizaContable, ''), ' Num Poliza Contable sin dato'),
                         ISNULL(NULLIF(@UUIDFacturaPagada, ''), ' UUIDFacturaPagada sin dato '),
                         ISNULL(NULLIF(@idAsientoPago, ''), ' idAsientoPago sin dato '),
						 ISNULL(NULLIF(@RFC, ''), ' RFC sin dato ')

						 -- ISNULL(NULLIF(' Forma de pago: ' + @FormaPago , ''), ' Forma Pago sin dato '),
       --                  ISNULL(NULLIF(' Cuenta O: ' +@CuentaOrigen, ''), ' Cuenta Origen sin dato '),
       --                  ISNULL(NULLIF(' Banco O: ' +@BancoOrigen, ''), ' BancoOrigen sin dato '),
       --                  ISNULL(NULLIF(' Titular O: ' +@TitularOrigen, ''), ' Titular Origen sin dato '),
       --                  ISNULL(NULLIF(' CuentaD : ' +@CuentaDestino, ''), ' Cuenta Destino sin dato '),
       --                  ISNULL(NULLIF(' Banco D :' +@BancoDestino, ''), ' Banco Destino sin dato '),
       --                  ISNULL(NULLIF(' Titular D: ' +@TitularDestino, ''), 'Titular Destino sin dato'),
       --                  ISNULL(NULLIF(' Fecha P: ' +@FechaPago, ''), ' Fecha Pago sin dato '),
       --                  ISNULL(NULLIF(' Moneda: ' +@Moneda, ''), ' Moneda sin dato '),
       --                  ISNULL(NULLIF(' Concepto: ' +@Concepto, ''), ' Concepto sin dato '),
       --                  ISNULL(NULLIF(' Poliza: ' +@NoPolizaContable, ''), ' Num Poliza Contable sin dato'),
       --                  ISNULL(NULLIF(' ' +@UUIDFacturaPagada, ''), ' UUIDFacturaPagada sin dato '),
       --                  ISNULL(NULLIF(' ' +@idAsientoPago, ''), ' idAsientoPago sin dato '),
						 --ISNULL(NULLIF(' ' +@RFC, ''), ' RFC sin dato ')
                     )
    END
    ELSE
    BEGIN
        --select	@IdPago	=	isnull(max(IdPago),0)+1 from AX_Pagos
        INSERT INTO dbo.AX_Pagos
        (
            FormaPago,
            CuentaOrigen,
            BancoOrigen,
            TitularOrigen,
            CuentaDestino,
            BancoDestino,
            TitularDestino,
            ReferenciaPago,
            FechaPago,
            MontoPagado,
            Interes,
            Moneda,
            Concepto,
            NoPolizaContable,
            UUIDFacturaPagada,
            MontoPagadoFactura,
            ComplementoPagoUUID,
            RECID,
			RFC
        )
        VALUES
        (

            --@IdPago,
            @FormaPago, @CuentaOrigen, @BancoOrigen, @TitularOrigen, @CuentaDestino, @BancoDestino, @TitularDestino,
            @ReferenciaPago, @FechaPago, @MontoPagado, @Interes, @Moneda, @Concepto, @NoPolizaContable,
            @UUIDFacturaPagada, @MontoPagadoFactura, @ComplementoPagoUUID, @idAsientoPago, @RFC)

        SELECT CONCAT('Recepcion exitosa, Diario de pago ', LTRIM(SCOPE_IDENTITY()))

		EXEC dbo.SP_GenerarTransferenciaCarso
		
    END

END

