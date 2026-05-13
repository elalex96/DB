---------------------------------------------------------------------------------------------------------  
-- Tratamiento en SP_GenerarTransferenciaCarso  
-- Caso 1   
-- Una transferencia que pertence a varias facturas  

-- Caso 2  
-- Una factura que pertenece a varias transferencias  

--Caso 3  
-- Una factura una transferencia  
--------------------------------------------------------------------------------------------------------  
CREATE PROC [dbo].[sp_AX_Pagos_Ins]
(

    --@IdPago     int output,  
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

    -- esta seccion se agrego debido a que carso esta enviando la cuenta destino en lugar de banco destino  
    SELECT @BancoDestino = CASE
                               WHEN LEN(LTRIM(RTRIM(@BancoDestino))) > 3 THEN
                                   SUBSTRING(@BancoDestino, 1, 3)
                               WHEN LEN(LTRIM(RTRIM(@BancoDestino))) = 3 THEN
                                   @BancoDestino
                               ELSE
                                   @BancoDestino
                           END

    DECLARE @IdPagoInsert INT,
            @MotivoError NVARCHAR(MAX) = N'',
            @IdBitacoraCarso INT

    DECLARE @TablaRetorno TABLE
    (
        IdPago INT,
        UUID NVARCHAR(MAX),
        RecId NVARCHAR(MAX),
        Motivo NVARCHAR(MAX)
    )
    DECLARE @RetornoError NVARCHAR(MAX),
            @InsertaroActualizar NVARCHAR(MAX)

    IF (LEN(@ReferenciaPago) > 50)
    BEGIN
        SELECT 'Error: El campo referencia de pago solo acepta 50 caracteres'
    END
    ELSE
    BEGIN
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
        (@FormaPago, @CuentaOrigen, @BancoOrigen, @TitularOrigen, @CuentaDestino, @BancoDestino,
         @TitularDestino, @ReferenciaPago, @FechaPago, @MontoPagado, @Interes, @Moneda, @Concepto,
         @NoPolizaContable, @UUIDFacturaPagada, @MontoPagadoFactura, @ComplementoPagoUUID,
         @idAsientoPago, @RFC, GETDATE());

        SELECT @RetornoError
            = CONCAT(
              CASE
                  WHEN LTRIM(RTRIM(@FormaPago)) = '' THEN
                      ' Forma Pago sin dato, '
                  ELSE
                      ''
              END,
              CASE
                  WHEN LTRIM(RTRIM(@CuentaOrigen)) = '' THEN
                      ' Cuenta Origen sin dato, '
                  ELSE
                      ''
              END,
              CASE
                  WHEN LTRIM(RTRIM(@BancoOrigen)) = '' THEN
                      ' Banco Origen sin dato,  '
                  ELSE
                      ''
              END,
              CASE
                  WHEN LTRIM(RTRIM(@TitularOrigen)) = '' THEN
                      ' Titular Origen sin dato, '
                  ELSE
                      ''
              END,
              CASE
                  WHEN LTRIM(RTRIM(@CuentaDestino)) = '' THEN
                      ' Cuenta Destino sin dato, '
                  ELSE
                      ''
              END,
              CASE
                  WHEN LTRIM(RTRIM(@BancoDestino)) = '' THEN
                      ' Banco Destino sin dato, '
                  ELSE
                      ''
              END,
              CASE
                  WHEN LTRIM(RTRIM(@TitularDestino)) = '' THEN
                      ' Titular Destino sin dato, '
                  ELSE
                      ''
              END,
              CASE
                  WHEN LTRIM(RTRIM(@FechaPago)) = '' THEN
                      ' Fecha Pago sin dato, '
                  ELSE
                      ''
              END,
              CASE
                  WHEN LTRIM(RTRIM(@Moneda)) = '' THEN
                      ' Moneda sin dato, '
                  ELSE
                      ''
              END,
              CASE
                  WHEN LTRIM(RTRIM(@NoPolizaContable)) = '' THEN
                      '  Num Poliza Contable sin dato, '
                  ELSE
                      ''
              END,
              CASE
                  WHEN LTRIM(RTRIM(@UUIDFacturaPagada)) = '' THEN
                      '  UUIDFacturaPagada sin dato, '
                  ELSE
                      ''
              END,
              CASE
                  WHEN LTRIM(RTRIM(@idAsientoPago)) = '' THEN
                      ' IdAsientoPago sin dato, '
                  ELSE
                      ''
              END,
              CASE
                  WHEN LTRIM(RTRIM(@RFC)) = '' THEN
                      ' RFC sin dato, '
                  ELSE
                      ''
              END,
              CASE
                  WHEN ISNULL(@MontoPagado, 0) = 0 THEN
                      ' Monto Pagado sin dato, '
                  ELSE
                      ''
              END,
              CASE
                  WHEN ISNULL(@MontoPagadoFactura, 0) = 0 THEN
                      ' Monto Pagado Factura sin dato '
                  ELSE
                      ''
              END)


        IF (LTRIM(RTRIM(@RetornoError)) <> '')
        BEGIN
            INSERT INTO dbo.Ax_BitacoraCarso
            (
                ErrorMotivo,
                Lugar,
                FechaRegistro,
                UUID_Principal,
                UUID_Complemento,
                IdAsientoPago
            )
            SELECT @RetornoError,
                   'sp_AX_Pagos_Ins',
                   GETDATE(),
                   @UUIDFacturaPagada,
                   @ComplementoPagoUUID,
                   @idAsientoPago

            SELECT CONCAT('ERROR: ', @RetornoError, ' IDBitacoraCarso: ', LTRIM(SCOPE_IDENTITY()))
        END;
        ELSE
        BEGIN
            BEGIN TRAN tran1
            BEGIN TRY

                --Valida si existe el RECID para saber si se registra o se actualiza  
                IF NOT EXISTS (SELECT 1 FROM dbo.AX_Pagos WHERE RECID = @idAsientoPago)
                BEGIN
                    SELECT @InsertaroActualizar = N'Recepcion '

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
                    (@FormaPago, @CuentaOrigen, @BancoOrigen, @TitularOrigen, @CuentaDestino,
                     @BancoDestino, @TitularDestino, @ReferenciaPago, @FechaPago, @MontoPagado,
                     @Interes, @Moneda, @Concepto, @NoPolizaContable, @UUIDFacturaPagada,
                     @MontoPagadoFactura, @ComplementoPagoUUID, @idAsientoPago, @RFC);

                    SELECT @IdPagoInsert = SCOPE_IDENTITY()

                END -- fin de insert  
                ELSE
                BEGIN
                    SELECT @InsertaroActualizar = N'Actualizacion '

                    -- si este asiento ya contiene una transferencia no permitir el actualizado  
                    IF NOT EXISTS
                    (   SELECT 1
                        FROM dbo.AX_Pagos
                        WHERE RECID = @idAsientoPago
                              AND ISNULL(IdTransferencia, 0) > 0)
                    BEGIN

                        UPDATE dbo.AX_Pagos
                        SET Editado = 1,
                            FormaPago = @FormaPago,
                            CuentaOrigen = @CuentaOrigen,
                            BancoOrigen = @BancoOrigen,
                            TitularOrigen = @TitularOrigen,
                            CuentaDestino = @CuentaDestino,
                            BancoDestino = @BancoDestino,
                            TitularDestino = @TitularDestino,
                            ReferenciaPago = @ReferenciaPago,
                            FechaPago = @FechaPago,
                            MontoPagado = @MontoPagado,
                            Interes = @Interes,
                            Moneda = @Moneda,
                            Concepto = @Concepto,
                            NoPolizaContable = @NoPolizaContable,
                            UUIDFacturaPagada = @UUIDFacturaPagada,
                            MontoPagadoFactura = @MontoPagadoFactura,
                            ComplementoPagoUUID = @ComplementoPagoUUID,
                            RFC = @RFC
                        WHERE RECID = @idAsientoPago

                        SELECT @IdPagoInsert = IdPago
                        FROM dbo.AX_Pagos
                        WHERE RECID = @idAsientoPago
                    END
                    ELSE
                    BEGIN
                        SELECT @InsertaroActualizar = N'TransferenciaExiste'
                        SELECT @MotivoError
                            = N' La factura que se intenta actualizar ya tiene una transferencia'
                    END
                END

                INSERT INTO @TablaRetorno (IdPago, UUID, RecId, Motivo)
                EXEC dbo.SP_GenerarTransferenciaCarso @IdPagoInsert

                SELECT @MotivoError += CASE
                                           WHEN Motivo = '' THEN
                                               Motivo
                                           ELSE
                                               ' - ' + Motivo
                                       END
                FROM @TablaRetorno
                WHERE RecId = @idAsientoPago



                COMMIT TRAN tran1
            END TRY
            BEGIN CATCH
                SELECT @MotivoError += CONCAT(' Excepcion en ', ERROR_MESSAGE())

                ROLLBACK TRAN tran1
            END CATCH


            IF (ISNULL(@MotivoError, '') <> '')
            BEGIN
                INSERT INTO dbo.Ax_BitacoraCarso
                (
                    ErrorMotivo,
                    Lugar,
                    Accion,
                    FechaRegistro,
                    UUID_Principal,
                    UUID_Complemento,
                    IdAsientoPago
                )
                SELECT @MotivoError,
                       'sp_AX_Pagos_Ins',
                       @InsertaroActualizar,
                       GETDATE(),
                       @UUIDFacturaPagada,
                       @ComplementoPagoUUID,
                       @idAsientoPago

                SELECT @IdBitacoraCarso = SCOPE_IDENTITY()
            END

            DECLARE @MensajeBitacora NVARCHAR(MAX),
                    @IdTransferencia INT


            SELECT @MensajeBitacora = CASE
                                          WHEN ISNULL(@IdBitacoraCarso, 0) > 0 THEN
                                              ' IdBitacoraCarso: ' + LTRIM(@IdBitacoraCarso)
                                          ELSE
                                              ''
                                      END

            SELECT @IdTransferencia = IdTransferencia
            FROM dbo.AX_Pagos
            WHERE RECID = @idAsientoPago

            DECLARE @IdPagoAct INT

            SELECT @IdPagoAct = IdPago
            FROM dbo.AX_Pagos
            WHERE RECID = @idAsientoPago

            IF EXISTS (SELECT 1 FROM Adinco.dbo.FI_Factura WHERE UUID = @UUIDFacturaPagada)
            BEGIN
                IF (ISNULL(@IdTransferencia, 0) > 0)
                   AND ISNULL(@InsertaroActualizar, '') <> 'TransferenciaExiste' -- si no tiene transferencia  
                BEGIN
                    SELECT CONCAT(
                           @InsertaroActualizar,
                           'exitosa, Diario de pago ',
                           LTRIM(@IdPagoInsert),
                           ' - ',
                           LTRIM(@IdPagoAct));
                END
                ELSE
                BEGIN
                    SELECT CONCAT(
                           'ERROR: ',
                           @MotivoError,
                           ' - ',
                           LTRIM(@IdPagoInsert),
                           ' - ',
                           @MensajeBitacora,
                           ' (-1-) ');
                END
            END
            ELSE
            BEGIN
                SELECT @MotivoError += N' ** No existe la factura con ese UUID en Adinco Finanzas no es posible generar la transferencia'

                INSERT INTO dbo.Ax_BitacoraCarso
                (
                    ErrorMotivo,
                    Lugar,
                    Accion,
                    FechaRegistro,
                    UUID_Principal,
                    UUID_Complemento,
                    IdAsientoPago
                )
                SELECT @MotivoError,
                       'sp_AX_Pagos_Ins',
                       @InsertaroActualizar,
                       GETDATE(),
                       @UUIDFacturaPagada,
                       @ComplementoPagoUUID,
                       @idAsientoPago

                SELECT @IdBitacoraCarso = SCOPE_IDENTITY()
                SELECT CONCAT(
                       'ERROR: ',
                       @MotivoError,
                       ' IdBitacoraCarso: ',
                       LTRIM(@IdBitacoraCarso),
                       '(-2-)')

            END

            IF (ISNULL(@ComplementoPagoUUID, '') <> '')
            BEGIN
                IF EXISTS (SELECT 1 FROM Adinco.dbo.FI_Factura WHERE UUID = @ComplementoPagoUUID)
                BEGIN
                    IF (ISNULL(@IdTransferencia, 0) > 0)
                       AND ISNULL(@InsertaroActualizar, '') <> 'TransferenciaExiste' -- si no tiene transferencia  
                    BEGIN
                        SELECT CONCAT(
                               @InsertaroActualizar,
                               'exitosa, Diario de pago ',
                               LTRIM(@IdPagoInsert),
                               ' - ',
                               LTRIM(@IdPagoAct));
                    END
                    ELSE
                    BEGIN
                        SELECT CONCAT(
                               'ERROR: ',
                               @MotivoError,
                               ' - ',
                               LTRIM(@IdPagoInsert),
                               ' ',
                               @MensajeBitacora,
                               ' -(2)- ');
                    END
                END
                ELSE
                BEGIN
                    SELECT @MotivoError += N' ** No existe la factura complemento con ese UUID en Adinco Finanzas no es posible generar la transferencia'

                    INSERT INTO dbo.Ax_BitacoraCarso
                    (
                        ErrorMotivo,
                        Lugar,
                        Accion,
                        FechaRegistro,
                        UUID_Principal,
                        UUID_Complemento,
                        IdAsientoPago
                    )
                    SELECT @MotivoError,
                           'sp_AX_Pagos_Ins',
                           @InsertaroActualizar,
                           GETDATE(),
                           @UUIDFacturaPagada,
                           @ComplementoPagoUUID,
                           @idAsientoPago

                    SELECT @IdBitacoraCarso = SCOPE_IDENTITY()
                    SELECT CONCAT(
                           'ERROR: ', @MotivoError, 'IdBitacoraCarso: ', LTRIM(@IdBitacoraCarso))

                END
            END
        END
    END
END