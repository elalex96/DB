CREATE PROCEDURE p_GeneracionTransferenciaConLigueDeComplemento
    @pIdContrato int,
    @pCreadoPor  int,
    @pIds        varchar(8000)
AS
    BEGIN

        IF OBJECT_ID('tempdb..#tmpId') IS NOT NULL
            DROP TABLE #tmpId
        IF OBJECT_ID('tempdb..#tmpTransferencias') IS NOT NULL
            DROP TABLE #tmpTransferencias

        CREATE TABLE #tmpId (Id int)
        CREATE TABLE #tmpTransferencias
            (
                IdTransferenciaImportacion int,
                RFCEmisor                  varchar(15),
                CuentaOrigen               varchar(50),
                CuentaDestino              varchar(50),
                FechaPago                  datetime,
                NumeroPoliza               INT,
                UUIDPrincipal              VARCHAR(100),
                IdFacturaPrincipal         INT,
                IdTransfer                 INT,
                IdTransferFactura          INT,
                cvTipoDocumento            INT,
                ComplementoLigado          BIT,
                IdFacturaComplemento       INT,
                LigarComplemento           BIT,
                PUE                        BIT
            )

        DECLARE
            @IdTransfer                     INT,
            @IdTransferFactura              INT,
            @IdTransferenciaImportacion     INT,
            @IdFacturaDeComplementoSinLigar INT,
            @IdFacturaDeComplementoLigada   INT,
            @MismaTransferencia             BIT,
            @IdCuentaBancariaOrigen         INT,
            @IdCuentaBancariaDestino        INT,
            @IdMoneda                       INT;

        -- SE INSERTA LOS ID SELECCIONADOS EN PANTALLA
        INSERT INTO #tmpId
            (
                Id
            )
                    SELECT
                        Id = splitdata
                    FROM
                        [dbo].[fnSplitString](@pIds, ',')

        -- SE OBTIENEN LAS LINEAS QUE SE CONVERTIRAN EN TRANSFERENCIAS DE LOS ID SELECCIONADOS ANTERIORMENTE
        INSERT INTO #tmpTransferencias
            (
                IdTransferenciaImportacion,
                RFCEmisor,
                CuentaOrigen,
                CuentaDestino,
                FechaPago,
                NumeroPoliza,
                UUIDPrincipal
            )
                    SELECT
                        IdTransferenciaImportacion,
                        RFCEmisor,
                        CuentaOrigen,
                        CuentaDestino,
                        FechaPago,
                        NumeroPoliza,
                        UUIDFactura
                    FROM
                        [FI_TransferImportacion] t1 (NOLOCK)
                        INNER JOIN
                            #tmpId               t2
                                ON t2.Id = t1.Id
                    WHERE
                        IdContrato = @pIdContrato
                        AND ISNULL(Sincronizar, 0) = 1

        -- SE COMIENZA CON LA EJECUCIÓN DE INSERTADO DE TRANSFERENCIA Y TRANSFER FACTURA APARTIR DE LA MINIMA POR INSERTAR
        SELECT
            @IdTransferenciaImportacion = MIN(IdTransferenciaImportacion)
        FROM
            #tmpTransferencias (NOLOCK)

        WHILE @IdTransferenciaImportacion IS NOT NULL
            BEGIN

                SET @IdTransferFactura = 0
                SET @IdFacturaDeComplementoSinLigar = 0
                SET @IdFacturaDeComplementoLigada = 0
                SET @MismaTransferencia = 0
                SET @IdCuentaBancariaOrigen = 0;
                SET @IdCuentaBancariaDestino = 0;
                SET @IdMoneda = 0;

                BEGIN TRY
                    BEGIN TRAN TRAN2

                    -- se verifica si la factura por buscar ya contiene transferecias relacionadas
                    UPDATE
                        #tmpTransferencias
                    SET
                        #tmpTransferencias.IdTransferFactura = FI_TransferFactura.IdTransferFactura,
                        #tmpTransferencias.IdTransfer = FI_TransferFactura.IdTransfer,
                        #tmpTransferencias.cvTipoDocumento = 1
                    FROM
                        #tmpTransferencias
                        INNER JOIN
                            FI_Factura
                                ON #tmpTransferencias.UUIDPrincipal = FI_Factura.UUID
                                   AND #tmpTransferencias.IdTransferenciaImportacion = @IdTransferenciaImportacion
                        INNER JOIN
                            FI_TransferFactura
                                ON FI_Factura.IdFactura = FI_TransferFactura.IdFactura
                                   AND FI_TransferFactura.CvTipoDocFacturacion = 1
                    WHERE
                        #tmpTransferencias.IdTransferenciaImportacion = @IdTransferenciaImportacion

                    --SE ASIGNA FACTURA COMPLEMENTO DE ACUERDO AL PPD DEL ARCHIVO
                    UPDATE
                        #tmpTransferencias
                    SET
                        ComplementoLigado = CASE
                                                WHEN FI_TransferFactura.IdTransferFactura IS NOT NULL
                                                    THEN 1
                                                ELSE
                                                    0
                                            END,
                        IdTransferFactura = FI_TransferFactura.IdTransferFactura,
                        IdTransfer = FI_TransferFactura.IdTransfer,
                        cvTipoDocumento = FI_TransferFactura.CvTipoDocFacturacion,
                        LigarComplemento = CASE
                                               WHEN FI_TransferFactura.IdTransferFactura IS NULL
                                                    AND FI_TransferFactura.CvTipoDocFacturacion IS NULL
                                                   THEN 1
                                               ELSE
                                                   0
                                           END,
                        IdFacturaComplemento = FI_ComplementoDePago.IdFactura
                    FROM
                        #tmpTransferencias
                        INNER JOIN
                            FI_CPDocRelacionado
                                ON #tmpTransferencias.UUIDPrincipal = FI_CPDocRelacionado.IdDocumento
                                   AND #tmpTransferencias.IdTransferenciaImportacion = @IdTransferenciaImportacion
                        INNER JOIN
                            FI_ComplementoDePago
                                ON FI_CPDocRelacionado.IdComplementoDePago = FI_ComplementoDePago.IdComplementoDePago
                        LEFT JOIN
                            FI_TransferFactura
                                ON FI_ComplementoDePago.IdFactura = FI_TransferFactura.IdFactura
                    WHERE
                        #tmpTransferencias.IdTransferenciaImportacion = @IdTransferenciaImportacion

                    --SE ASIGNA FACTURA PRINCIPAL (PPD)
                    UPDATE
                        #tmpTransferencias
                    SET
                        IdFacturaPrincipal = FI_Factura.IdFactura,
                        PUE = CASE
                                  WHEN FI_Factura.MetodoPago = 'PUE'
                                      THEN 1
                                  ELSE
                                      0
                              END
                    FROM
                        #tmpTransferencias
                        INNER JOIN
                            FI_Factura
                                ON #tmpTransferencias.UUIDPrincipal = FI_Factura.UUID
                                   AND #tmpTransferencias.IdTransferenciaImportacion = @IdTransferenciaImportacion
                    WHERE
                        IdTransferenciaImportacion = @IdTransferenciaImportacion


                    -- VERIFICACIÓN SI LA FACTURA YA CONTIENE TRANSFERENCIA GUARDADA ANTERIORMENTE
                    UPDATE
                        FI_TransferImportacion
                    SET
                        Error = CONCAT(
                                          '[No fue generada la transferencia ya que el documento de facturación ya contiene una transferencia relacionada en la Transferencia: ',
                                          #tmpTransferencias.IdTransfer, ', TransferFactura: ',
                                          #tmpTransferencias.IdTransferFactura, '] '
                                      ),
                        Sincronizar = 0,
                        ModificadoEl = GETDATE()
                    FROM
                        #tmpTransferencias
                        INNER JOIN
                            FI_TransferImportacion
                                ON #tmpTransferencias.IdTransferenciaImportacion = @IdTransferenciaImportacion
                                   AND #tmpTransferencias.IdTransferenciaImportacion = FI_TransferImportacion.IdTransferenciaImportacion
                                   AND #tmpTransferencias.IdTransfer IS NOT NULL;

                    ----------- VALIDACION DE DATOS GENERALES ------------
                    -- RETORNA ERROR DE QUE LA FACTURA NO ESTA REGISTRADA EN EL SISTEMA
                    UPDATE
                        FI_TransferImportacion
                    SET
                        Error = CONCAT(
                                          Error,
                                          '[No fue generada la transferencia ya que el documento de facturación con ',
                                          UUIDPrincipal, ' no fue encontrado en el sistema] '
                                      ),
                        TieneError = 1,
                        Sincronizar = 0,
                        ModificadoEl = GETDATE()
                    FROM
                        #tmpTransferencias
                        INNER JOIN
                            FI_TransferImportacion
                                ON #tmpTransferencias.IdTransferenciaImportacion = @IdTransferenciaImportacion
                                   AND #tmpTransferencias.IdTransferenciaImportacion = FI_TransferImportacion.IdTransferenciaImportacion
                                   AND #tmpTransferencias.IdFacturaPrincipal IS NULL;


                    select
                        @IdCuentaBancariaOrigen = ISNULL(PV_CuentaBancaria.DatoBancarioID, 0)
                    FROM
                        FI_TransferImportacion (NOLOCK)
                        JOIN
                            PV_CuentaBancaria (NOLOCK)
                                ON PV_CuentaBancaria.NumeroCuenta = FI_TransferImportacion.CuentaOrigen
                    WHERE
                        FI_TransferImportacion.IdContrato = @pIdContrato
                        AND FI_TransferImportacion.IdTransferenciaImportacion = @IdTransferenciaImportacion


                    select
                        @IdCuentaBancariaDestino = ISNULL(PV_CuentaBancaria.DatoBancarioID, 0)
                    FROM
                        FI_TransferImportacion (NOLOCK)
                        JOIN
                            PV_CuentaBancaria (NOLOCK)
                                ON (
                                       PV_CuentaBancaria.NumeroCuenta = FI_TransferImportacion.CuentaDestino
                                       OR PV_CuentaBancaria.CuentaClave = FI_TransferImportacion.CuentaDestino
                                   )
                    WHERE
                        FI_TransferImportacion.IdContrato = @pIdContrato
                        AND FI_TransferImportacion.IdTransferenciaImportacion = @IdTransferenciaImportacion


                    SELECT
                        @IdMoneda = ISNULL(PV_TipoMoneda.IdMoneda, 0)
                    FROM
                        FI_TransferImportacion (NOLOCK)
                        JOIN
                            PV_TipoMoneda (NOLOCK)
                                ON PV_TipoMoneda.TipoMonedaCorto = FI_TransferImportacion.MonedaPago
                    WHERE
                        FI_TransferImportacion.IdContrato = @pIdContrato
                        AND FI_TransferImportacion.IdTransferenciaImportacion = @IdTransferenciaImportacion;


                    IF (
                           ISNULL(@IdCuentaBancariaOrigen, 0) = 0
                           OR ISNULL(@IdCuentaBancariaDestino, 0) = 0
                           OR ISNULL(@IdMoneda, 0) = 0
                       )
                        BEGIN
                            update
                                FI_TransferImportacion
                            set
                                TieneError = 1,
                                Error = CASE
                                            WHEN
                                                (
                                                    ISNULL(@IdCuentaBancariaOrigen, 0) = 0
                                                    AND ISNULL(@IdCuentaBancariaDestino, 0) = 0
                                                )
                                                THEN CONCAT(Error, '[No se encontraron ambas cuentas bancarias, verifique que los formato ingresados de este dato sea como texto] ')
                                            WHEN
                                                (
                                                    ISNULL(@IdCuentaBancariaOrigen, 0) = 0
                                                    AND ISNULL(@IdCuentaBancariaDestino, 0) > 0
                                                )
                                                THEN CONCAT(Error, '[No se encontró la cuenta bancaria origen, verifique que los formato ingresados de este dato sea como texto] ')
                                            WHEN
                                                (
                                                    ISNULL(@IdCuentaBancariaOrigen, 0) > 0
                                                    AND ISNULL(@IdCuentaBancariaDestino, 0) = 0
                                                )
                                                THEN CONCAT(Error, '[No se encontró la cuenta bancaria destino, verifique que los formato ingresados de este dato sea como texto] ')
                                            ELSE
                                                Error
                                        END,
                                Sincronizar = 0,
                                ModificadoEl = GETDATE()
                            from
                                FI_TransferImportacion
                            WHERE
                                FI_TransferImportacion.IdTransferenciaImportacion = @IdTransferenciaImportacion;

                            update
                                FI_TransferImportacion
                            set
                                TieneError = 1,
                                Error = CASE
                                            WHEN (ISNULL(@IdMoneda, 0) = 0)
                                                THEN CONCAT(Error, '[No se encontró la moneda de pago establecida] ')
                                            ELSE
                                                Error
                                        END,
                                Sincronizar = 0,
                                ModificadoEl = GETDATE()
                            from
                                FI_TransferImportacion
                            WHERE
                                FI_TransferImportacion.IdTransferenciaImportacion = @IdTransferenciaImportacion
                        END


                    IF (
                           (
                               SELECT
                                   LEN(REPLACE(ISNULL(Error,''), ' ', ''))
                               FROM
                                   FI_TransferImportacion (NOLOCK)
                               WHERE
                                   IdTransferenciaImportacion = @IdTransferenciaImportacion
                           ) = 0
                       )
                        BEGIN
                            SET @IdTransfer = 0
                            --Generar transferencias de las que estan pendientes
                            INSERT INTO FI_Transfer
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
                                    ModificadoEn,
                                    HashSHA256,
                                    IdFacturaPago,
                                    AWSPDFId
                                )
                                        SELECT
                                            FI_TransferImportacion.IdContrato,
                                            null,
                                            null,
                                            null,
                                            FI_TransferImportacion.FechaPago,
                                            @IdCuentaBancariaOrigen,
                                            @IdCuentaBancariaDestino,
                                            MontoPagado,
                                            @IdMoneda,
                                            1,
                                            FI_TransferImportacion.Concepto,
                                            4,
                                            0,
                                            FI_TransferImportacion.NumeroPoliza,
                                            Interes,
                                            null,
                                            @pCreadoPor,
                                            getdate(),
                                            null,
                                            null,
                                            null,
                                            null,
                                            null
                                        FROM
                                            #tmpTransferencias
                                            INNER JOIN
                                                FI_TransferImportacion (NOLOCK)
                                                    ON FI_TransferImportacion.IdTransferenciaImportacion = @IdTransferenciaImportacion
                                                       AND #tmpTransferencias.IdTransferenciaImportacion = FI_TransferImportacion.IdTransferenciaImportacion
                                                       AND #tmpTransferencias.IdTransfer IS NULL
                                        WHERE
                                            FI_TransferImportacion.IdContrato = @pIdContrato
                                            AND FI_TransferImportacion.IdTransferenciaImportacion = @IdTransferenciaImportacion
                                            AND ISNULL(#tmpTransferencias.PUE, 0) = 0;

                            SELECT
                                @IdTransfer = SCOPE_IDENTITY();

                            IF (ISNULL(@IdTransfer, 0) > 0)
                                BEGIN
                                    IF (
                                           (
                                               SELECT
                                                   COUNT(1)
                                               from
                                                   FI_Transfer (NOLOCK)
                                               where
                                                   IdTransferencia = @IdTransfer
                                           ) > 0
                                       ) --VERIFICACIÓN SI EXISTE UNA TRANSFERENCIA CON ESE ID
                                        BEGIN
                                            UPDATE
                                                #tmpTransferencias
                                            SET
                                                IdTransfer = @IdTransfer
                                            FROM
                                                #tmpTransferencias
                                            WHERE
                                                IdTransferenciaImportacion = @IdTransferenciaImportacion
                                                AND ISNULL(#tmpTransferencias.PUE, 0) = 0

                                            INSERT INTO FI_TransferFactura
                                                (
                                                    IdTransfer,
                                                    IdFactura,
                                                    IdPedimentoComprobante,
                                                    MontoPagado,
                                                    CvTipoDocFacturacion,
                                                    CreadoPor,
                                                    CreadoEn,
                                                    ModificadoPor,
                                                    ModificadoEn
                                                )
                                                        SELECT
                                                            #tmpTransferencias.IdTransfer,
                                                            #tmpTransferencias.IdFacturaPrincipal,
                                                            null,
                                                            FI_TransferImportacion.ValorFactura,
                                                            1,
                                                            @pCreadoPor,
                                                            getdate(),
                                                            null,
                                                            null
                                                        FROM
                                                            #tmpTransferencias
                                                            INNER JOIN
                                                                FI_TransferImportacion (NOLOCK)
                                                                    ON FI_TransferImportacion.IdTransferenciaImportacion = @IdTransferenciaImportacion
                                                                       AND #tmpTransferencias.IdTransferenciaImportacion = FI_TransferImportacion.IdTransferenciaImportacion
                                                                       AND #tmpTransferencias.IdTransferFactura IS NULL
                                                        WHERE
                                                            FI_TransferImportacion.IdTransferenciaImportacion = @IdTransferenciaImportacion
                                                            AND ISNULL(#tmpTransferencias.PUE, 0) = 0

                                            SELECT
                                                @IdTransferFactura = SCOPE_IDENTITY();

                                            UPDATE
                                                #tmpTransferencias
                                            SET
                                                IdTransferFactura = @IdTransferFactura,
                                                cvTipoDocumento = CASE
                                                                      WHEN #tmpTransferencias.cvTipoDocumento IS NULL
                                                                          THEN 1
                                                                      ELSE
                                                                          #tmpTransferencias.cvTipoDocumento
                                                                  END
                                            FROM
                                                #tmpTransferencias
                                            WHERE
                                                #tmpTransferencias.IdTransferenciaImportacion = @IdTransferenciaImportacion
                                                AND ISNULL(#tmpTransferencias.PUE, 0) = 0
                                                AND #tmpTransferencias.IdTransferFactura IS NULL

                                            -----Ligar complemento de las transferencias que estan pendientes, Solo para cuando contienen complemento ligado a la ppd-----
                                            DELETE FI_TransferFactura
                                            FROM
                                                FI_TransferFactura
                                                INNER JOIN
                                                    #tmpTransferencias
                                                        ON FI_TransferFactura.IdTransferFactura = FI_TransferFactura.IdTransferFactura
                                                           AND IdTransferenciaImportacion = @IdTransferenciaImportacion
                                            WHERE
                                                FI_TransferFactura.IdTransfer = @IdTransfer
                                                AND CvTipoDocFacturacion = 1
                                                AND #tmpTransferencias.LigarComplemento = 1
                                                AND ISNULL(#tmpTransferencias.PUE, 0) = 0

                                            INSERT INTO FI_TransferFactura
                                                (
                                                    IdTransfer,
                                                    IdFactura,
                                                    IdPedimentoComprobante,
                                                    MontoPagado,
                                                    CvTipoDocFacturacion,
                                                    CreadoPor,
                                                    CreadoEn,
                                                    ModificadoPor,
                                                    ModificadoEn
                                                )
                                                        SELECT
                                                            @IdTransfer,
                                                            #tmpTransferencias.IdFacturaComplemento,
                                                            null,
                                                            0.0,
                                                            6,
                                                            @pCreadoPor,
                                                            getdate(),
                                                            null,
                                                            null
                                                        FROM
                                                            #tmpTransferencias
                                                        WHERE
                                                            #tmpTransferencias.IdTransferenciaImportacion = @IdTransferenciaImportacion
                                                            AND #tmpTransferencias.LigarComplemento = 1
                                                            AND ISNULL(#tmpTransferencias.PUE, 0) = 0
                                            ----------------

                                            UPDATE
                                                FI_TransferImportacion
                                            SET
                                                Sincronizar = 0,
                                                Procesado = 1,
                                                IdTransferFactura = #tmpTransferencias.IdTransferFactura,
                                                ModificadoEl = GETDATE()
                                            FROM
                                                FI_TransferImportacion
                                                INNER JOIN
                                                    #tmpTransferencias
                                                        ON FI_TransferImportacion.IdTransferenciaImportacion = @IdTransferenciaImportacion
                                                           AND FI_TransferImportacion.IdTransferenciaImportacion = #tmpTransferencias.IdTransferenciaImportacion
                                            WHERE
                                                FI_TransferImportacion.IdTransferenciaImportacion = @IdTransferenciaImportacion
                                        END
                                    ELSE
                                        BEGIN
                                            update
                                                FI_TransferImportacion
                                            set
                                                TieneError = 1,
                                                Error = concat(
                                                                  '[Ocurrio un error al generar la transferencia detectada en el proceso como Id: ',
                                                                  ISNULL(@IdTransfer, 0), '] '
                                                              ),
                                                Sincronizar = 0
                                            from
                                                FI_TransferImportacion
                                            WHERE
                                                FI_TransferImportacion.IdTransferenciaImportacion = @IdTransferenciaImportacion
                                        END
                                END
                            ELSE
                                BEGIN
                                    update
                                        FI_TransferImportacion
                                    set
                                        TieneError = 1,
                                        Error = '[No se encontró la factura o alguna de las cuentas bancarias no existe] ',
                                        Sincronizar = 0
                                    from
                                        FI_TransferImportacion
                                    WHERE
                                        FI_TransferImportacion.IdTransferenciaImportacion = @IdTransferenciaImportacion
                                END

                        END

                    COMMIT TRAN TRAN2
                END TRY
                BEGIN CATCH
                    ROLLBACK TRAN TRAN2
                    update
                        FI_TransferImportacion
                    set
                        TieneError = 1,
                        Error = ERROR_MESSAGE(),
                        Sincronizar = 0
                    from
                        FI_TransferImportacion
                    WHERE
                        FI_TransferImportacion.IdTransferenciaImportacion = @IdTransferenciaImportacion
                END CATCH;

                SELECT
                    @IdTransferenciaImportacion = MIN(IdTransferenciaImportacion)
                FROM
                    #tmpTransferencias (NOLOCK)
                WHERE
                    IdTransferenciaImportacion > @IdTransferenciaImportacion
            END

    END
