CREATE PROCEDURE [dbo].[p_FI_TransferImportacion_Generacion]
    @pIdContrato int,
    @pCreadoPor int,
    @pIds varchar(8000)
as
BEGIN
    IF OBJECT_ID('tempdb..#tmpId') IS NOT NULL
        DROP TABLE #tmpId
    IF OBJECT_ID('tempdb..#tmpImportacion') IS NOT NULL
        DROP TABLE #tmpImportacion

    CREATE TABLE #tmpId (Id int)
    CREATE TABLE #tmpImportacion
    (
        IdTransferenciaImportacion int,
        RFCEmisor varchar(15),
        CuentaOrigen varchar(50),
        CuentaDestino varchar(50),
        FechaPago datetime,
        NumeroPoliza INT,
		UUIDFactura  VARCHAR(100)
    )
    DECLARE @IdCuentaBancariaOrigen INT,
            @IdCuentaBancariaDestino INT,
            @IdMoneda INT;
    -- Para que solo aplique para los que no son WDEA
    IF (@pIdContrato NOT IN ( 10038, 10044, 10045, 10046, 10145 ))
    BEGIN

        DECLARE @idTransferImport int = 0;
        INSERT INTO #tmpId
        (
            Id
        )
        SELECT Id = splitdata
        from [dbo].[fnSplitString](@pIds, ',');

        INSERT INTO #tmpImportacion
        (
            IdTransferenciaImportacion,
            RFCEmisor,
            CuentaOrigen,
            CuentaDestino,
            FechaPago,
            NumeroPoliza,
			UUIDFactura
        )
        SELECT IdTransferenciaImportacion = min(IdTransferenciaImportacion),
               RFCEmisor,
               CuentaOrigen,
               CuentaDestino,
               FechaPago,
               NumeroPoliza,
			   UUIDFactura
        FROM [FI_TransferImportacion] t1 (NOLOCK)
            INNER JOIN #tmpId t2
                on t2.Id = t1.Id
        WHERE IdContrato = @pIdContrato
              AND ISNULL(Sincronizar, 0) = 1
        GROUP BY RFCEmisor,
                 CuentaOrigen,
                 CuentaDestino,
                 FechaPago,
                 NumeroPoliza,
				 UUIDFactura

        SELECT @idTransferImport = min(IdTransferenciaImportacion)
        FROM #tmpImportacion;

        WHILE @idTransferImport IS NOT NULL
        BEGIN
            DECLARE @IdTransfer INT,
                    @IdTransferFactura INT,
                    @nFacturas1 TINYINT,
                    @nFacturas2 TINYINT

            BEGIN TRY
                --Iniciar transacción
                BEGIN TRAN

                SET @IdTransfer = 0;
                SET @IdCuentaBancariaOrigen = 0;
                SET @IdCuentaBancariaDestino = 0;
                SET @IdMoneda = 0;

				 select @IdCuentaBancariaOrigen = ISNULL(PV_CuentaBancaria.DatoBancarioID, 0)
                FROM FI_TransferImportacion (NOLOCK)
                    JOIN PV_CuentaBancaria (NOLOCK)
                        ON PV_CuentaBancaria.NumeroCuenta = FI_TransferImportacion.CuentaOrigen
                WHERE FI_TransferImportacion.IdContrato = @pIdContrato
                      AND FI_TransferImportacion.IdTransferenciaImportacion = @idTransferImport

                select @IdCuentaBancariaDestino = ISNULL(PV_CuentaBancaria.DatoBancarioID, 0)
                FROM FI_TransferImportacion (NOLOCK)
                    JOIN PV_CuentaBancaria (NOLOCK)
                        ON (
                               PV_CuentaBancaria.NumeroCuenta = FI_TransferImportacion.CuentaDestino
                               OR PV_CuentaBancaria.CuentaClave = FI_TransferImportacion.CuentaDestino
                           )
                WHERE FI_TransferImportacion.IdContrato = @pIdContrato
                      AND FI_TransferImportacion.IdTransferenciaImportacion = @idTransferImport

                SELECT @IdMoneda = ISNULL(PV_TipoMoneda.IdMoneda, 0)
                FROM FI_TransferImportacion (NOLOCK)
                    JOIN PV_TipoMoneda (NOLOCK)
                        ON PV_TipoMoneda.TipoMonedaCorto = FI_TransferImportacion.MonedaPago
                WHERE FI_TransferImportacion.IdContrato = @pIdContrato
                      AND FI_TransferImportacion.IdTransferenciaImportacion = @idTransferImport;


                SELECT @IdTransfer = IdTransferencia
                FROM [FI_TransferImportacion] t (NOLOCK)
                    INNER JOIN FI_Factura fac (NOLOCK)
                        on fac.UUID = t.UUIDFactura
                    INNER JOIN FI_Transfer tr (NOLOCK)
                        on tr.IdCuentaOrigen = @IdCuentaBancariaOrigen
                           and tr.IdCuentaDestino = @IdCuentaBancariaDestino
                           and tr.idContrato = t.IdContrato
						   AND tr.IdMoneda = @IdMoneda
                           and convert(varchar, tr.FechaPago, 112) = convert(varchar, t.FechaPago, 112)
                           and tr.NumeroPolizaContable = t.NumeroPoliza
                WHERE t.IdContrato = @pIdContrato
                      AND t.IdTransferenciaImportacion = @idTransferImport;
				
                IF (
                       ISNULL(@IdCuentaBancariaOrigen, 0) = 0
                       OR ISNULL(@IdCuentaBancariaDestino, 0) = 0
                       OR ISNULL(@IdMoneda, 0) = 0
                   )
                BEGIN
                    update FI_TransferImportacion
                    set TieneError = 1,
                        Error = CASE
                                    WHEN
                                    (
                                        ISNULL(@IdCuentaBancariaOrigen, 0) = 0
                                        AND ISNULL(@IdCuentaBancariaDestino, 0) = 0
                                    ) THEN
                                        CONCAT(Error, '[No se encontraron ambas cuentas bancarias, verifique que los formato ingresados de este dato sea como texto] ')
                                    WHEN
                                    (
                                        ISNULL(@IdCuentaBancariaOrigen, 0) = 0
                                        AND ISNULL(@IdCuentaBancariaDestino, 0) > 0
                                    ) THEN
                                        CONCAT(Error, '[No se encontró la cuenta bancaria origen, verifique que el formato ingresado de este dato sea como texto] ')
                                    WHEN
                                    (
                                        ISNULL(@IdCuentaBancariaOrigen, 0) > 0
                                        AND ISNULL(@IdCuentaBancariaDestino, 0) = 0
                                    ) THEN
                                        CONCAT(Error, '[No se encontró la cuenta bancaria destino, verifique que el formato ingresado de este dato sea como texto] ')
                                    ELSE
                                        Error
                                END,
                        Sincronizar = 0,
                        ModificadoEl = GETDATE()
                    from FI_TransferImportacion
                    WHERE FI_TransferImportacion.IdTransferenciaImportacion = @idTransferImport;

                    update FI_TransferImportacion
                    set TieneError = 1,
                        Error = CASE
                                    WHEN (ISNULL(@IdMoneda, 0) = 0) THEN
                                        CONCAT(Error, '[No se encontró la moneda de pago establecida] ')
                                    ELSE
                                        Error
                                END,
                        Sincronizar = 0,
                        ModificadoEl = GETDATE()
                    from FI_TransferImportacion
                    WHERE FI_TransferImportacion.IdTransferenciaImportacion = @idTransferImport
                END

                IF (
                       (
                       (
                           SELECT LEN(REPLACE(ISNULL(Error, ''), ' ', ''))
                           FROM FI_TransferImportacion (NOLOCK)
                           WHERE IdTransferenciaImportacion = @idTransferImport
                       ) = 0
                       )
                       OR (ISNULL(@IdTransfer, 0) > 0)
                   )
                BEGIN

                    IF (ISNULL(@IdTransfer, 0) = 0)
                    BEGIN

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
                        SELECT t.IdContrato,
                               null,
                               null,
                               null,
                               FechaPago,
                               @IdCuentaBancariaOrigen,
                               @IdCuentaBancariaDestino,
                               MontoPagado,
                               @IdMoneda,
                               1,
                               t.Concepto,
                               4,
                               0,
                               NumeroPoliza,
                               Interes,
                               null,
                               @pCreadoPor,
                               getdate(),
                               null,
                               null,
                               null,
                               null,
                               null
                        FROM [FI_TransferImportacion] t (NOLOCK)
                            INNER JOIN FI_Factura fac (NOLOCK)
                                on fac.UUID = t.UUIDFactura
                        WHERE t.IdContrato = @pIdContrato
                              AND t.IdTransferenciaImportacion = @idTransferImport

                        SELECT @IdTransfer = tr.IdTransferencia
                        from [FI_TransferImportacion] t (NOLOCK)
                            INNER JOIN FI_Factura fac (NOLOCK)
                                on fac.UUID = t.UUIDFactura
                            INNER JOIN FI_Transfer tr (NOLOCK)
                                on tr.IdCuentaOrigen = @IdCuentaBancariaOrigen
                                   and tr.IdCuentaDestino =	@IdCuentaBancariaDestino
                                   and tr.idContrato = t.IdContrato
								   AND tr.IdMoneda = @IdMoneda
                                   and convert(varchar, tr.FechaPago, 112) = convert(varchar, t.FechaPago, 112)
                                   AND tr.NumeroPolizaContable = t.NumeroPoliza
                        WHERE t.IdContrato = @pIdContrato
                              AND t.IdTransferenciaImportacion = @idTransferImport

                    END


                    if ISNULL(@IdTransfer, 0) > 0
                    BEGIN

                        --Actualizar encabezado
                        UPDATE FI_Transfer
                        SET NumeroPolizaContable = t.NumeroPoliza
                        FROM FI_Transfer t1
                            INNER JOIN [FI_TransferImportacion] t
                                on t.IdContrato = @pIdContrato
                                   and t.IdTransferenciaImportacion = @idTransferImport
                        where t1.IdTransferencia = @IdTransfer

                        --Identificar cuantas facturas se deben afectar
                        SELECT @nFacturas1 = COUNT(distinct t2.UUIDFactura)
                        FROM [FI_TransferImportacion] t (NOLOCK)
                            INNER JOIN [FI_TransferImportacion] t2 (NOLOCK)
                                ON t2.RFCEmisor = t.RFCEmisor
                                   AND t2.CuentaOrigen = t.CuentaOrigen
                                   AND t2.CuentaDestino = t.CuentaDestino
                                   AND t2.FechaPago = t.FechaPago
                            INNER JOIN FI_Factura fac (NOLOCK)
                                ON fac.UUID = t2.UUIDFactura
                        WHERE t.IdContrato = @pIdContrato
                              AND t.IdTransferenciaImportacion = @idTransferImport

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
                        SELECT @IdTransfer,
                               fac.IdFactura,
                               null,
                               t2.ValorFactura,
                               1,
                               @pCreadoPor,
                               getdate(),
                               null,
                               null
                        FROM [FI_TransferImportacion] t (NOLOCK)
                            INNER JOIN [FI_TransferImportacion] t2 (NOLOCK)
                                ON t2.RFCEmisor = t.RFCEmisor
                                   AND t2.CuentaOrigen = t.CuentaOrigen
                                   AND t2.CuentaDestino = t.CuentaDestino
                                   AND t2.FechaPago = t.FechaPago
                                   AND t2.NumeroPoliza = t.NumeroPoliza
                                   AND t2.Id = t.Id
                            INNER JOIN FI_Factura fac (NOLOCK)
                                ON fac.UUID = t2.UUIDFactura
                        WHERE t.IdContrato = @pIdContrato
                              AND t.IdTransferenciaImportacion = @idTransferImport
                              AND isnull(@IdTransfer, 0) > 0
                              AND NOT EXISTS
                        (
                            SELECT 1
                            FROM FI_TransferFactura st1 (NOLOCK)
                            WHERE st1.IdTransfer = @IdTransfer
                                  AND st1.IdFactura = fac.IdFactura
                                  AND st1.MontoPagado = t2.ValorFactura
                        )

                        --Contar cuantas facturas se generaron
                        SELECT @nFacturas2 = COUNT(distinct fac.UUID)
                        FROM FI_TransferFactura t2 (NOLOCK)
                            INNER JOIN FI_Factura fac
                                ON fac.IdFactura = t2.IdFactura
                        WHERE IdTransfer = @IdTransfer;

                        UPDATE FI_TransferImportacion
                        SET IdTransferFactura = tf.IdTransferFactura,
                            Sincronizar = 0,
                            Procesado = 1,
                            TieneError = 0,
                            Error = ''
                        FROM FI_TransferImportacion ti
                            INNER JOIN FI_Factura fac
                                ON fac.UUID = ti.UUIDFactura
                            INNER JOIN FI_TransferFactura tf
                                ON tf.IdTransfer = @IdTransfer
                                   AND tf.IdFactura = fac.IdFactura

                        
                    END
                    ELSE
                    BEGIN
                        UPDATE [FI_TransferImportacion]
                        SET TieneError = 1,
                            Error = 'NO SE ENCONTRÓ LA FACTURA O ALGUNA DE LAS CUENTAS BANCARIAS NO EXISTE',
                            Sincronizar = 0
                        FROM [FI_TransferImportacion] t2
                            INNER JOIN #tmpImportacion t
                                ON t2.RFCEmisor = t.RFCEmisor
                                   AND t2.CuentaOrigen = t.CuentaOrigen
                                   AND t2.CuentaDestino = t.CuentaDestino
                                   AND t2.FechaPago = t.FechaPago
								   and t2.UUIDFactura = t.UUIDFactura
                                   AND t.IdTransferenciaImportacion = @idTransferImport
                    END

                END
				COMMIT TRAN
            END TRY
            BEGIN CATCH
                ROLLBACK TRAN

                --MARCAR CON ERROR
                UPDATE [FI_TransferImportacion]
                SET TieneError = 1,
                    Error = ERROR_MESSAGE(),
                    Sincronizar = 0
                FROM [FI_TransferImportacion] t2
                    INNER JOIN #tmpImportacion t
                        ON t2.RFCEmisor = t.RFCEmisor
                           AND t2.CuentaOrigen = t.CuentaOrigen
                           AND t2.CuentaDestino = t.CuentaDestino
                           AND t2.FechaPago = t.FechaPago
                           AND t.IdTransferenciaImportacion = @idTransferImport
            END CATCH;

            SELECT @idTransferImport = min(IdTransferenciaImportacion)
            FROM #tmpImportacion
            WHERE IdTransferenciaImportacion > @idTransferImport
        END

    END


    IF (@pIdContrato IN ( 10038, 10044, 10045, 10046, 10145 ))
    BEGIN

        EXEC p_GeneracionTransferenciaConLigueDeComplemento @pIdContrato,
                                                            @pCreadoPor,
                                                            @pIds
    END
END

