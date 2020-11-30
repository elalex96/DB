-- p_FI_TransferImportacion_Generacion 10036,1
CREATE proc p_FI_TransferImportacion_Generacion
@pIdContrato int,
@pCreadoPor int,
@pIds varchar(max)
as
    declare @idTransferImport int
    select Id = splitdata
    into #tmpId
    from [dbo].[fnSplitString](@pIds,',')
    select IdTransferenciaImportacion = min(IdTransferenciaImportacion),
    RFCEmisor,
    CuentaOrigen,
    CuentaDestino,
    FechaPago,
    NumeroPoliza
    into #tmpImportacion
    from [FI_TransferImportacion] t1
    inner join #tmpId t2 on t2.Id = t1.Id
    where IdContrato = @pIdContrato and
    isnull(Sincronizar,0) = 1
    group by RFCEmisor,CuentaOrigen,CuentaDestino,FechaPago,NumeroPoliza
        
    select @idTransferImport = min(IdTransferenciaImportacion)
    from #tmpImportacion
    
    while @idTransferImport is not null
    begin   
        
    
        declare @IdTransfer int ,
            @IdTransferFactura int  ,
            @nFacturas1 tinyint,
            @nFacturas2 tinyint
        
        BEGIN TRY  
            --Iniciar transacción
            BEGIN TRAN  
                            set @IdTransfer = 0
                            SELECT @IdTransfer = IdTransferencia
                            from [FI_TransferImportacion] t
                            inner join PV_CuentaBancaria co on co.NumeroCuenta = t.CuentaOrigen
                            inner join PV_CuentaBancaria cd on  (
                                                                    cd.NumeroCuenta = t.CuentaDestino OR
                                                                    cd.CuentaClave = t.CuentaDestino
                                                                    )
                                inner join PV_TipoMoneda tm on tm.TipoMonedaCorto = t.MonedaPago
                                inner join FI_Factura fac on fac.UUID = t.UUIDFactura
                                inner join FI_Transfer tr on tr.IdCuentaOrigen = co.DatoBancarioID and
                                                                tr.IdCuentaDestino = cd.DatoBancarioID and
                                                                tr.idContrato = t.IdContrato and
                                                                convert(varchar,tr.FechaPago,112) = convert(varchar,t.FechaPago,112) and
                                                                --tr.MontoPagado  = cast(t.MontoPagado as money) and
                                                                tr.NumeroPolizaContable = t.NumeroPoliza
                                where t.IdContrato = @pIdContrato  and
                                t.IdTransferenciaImportacion = @idTransferImport
                            if(isnull(@IdTransfer,0) = 0)
                            begin
                                insert into FI_Transfer(
                                IdContrato,     IdComprobantePago,      NombreExtencionArchivo,     ReferenciaBancaria,         FechaPago,
                                IdCuentaOrigen,     IdCuentaDestino,    MontoPagado,            IdMoneda,                   IdClasificacionDocumento,   Concepto,
                                IdMetodoPago,       ProcesadoSIPAC,     NumeroPolizaContable,   Intereses,                  PDF,                        CreadoPor,
                                CreadoEn,           ModificadoPor,      ModificadoEn,           HashSHA256,                 IdFacturaPago,              AWSPDFId
                                )
                                select  t.IdContrato,       null,               null,                       null,                       FechaPago,
                                co.DatoBancarioID,      cd.DatoBancarioID,  MontoPagado,                tm.IdMoneda,            1,                          t.Concepto,
                                4,                      0,                  NumeroPoliza,           Interes,                    null,                       @pCreadoPor,
                                getdate(),              null,               null,                   null,                       null,                       null                                        
                                from [FI_TransferImportacion] t
                                inner join PV_CuentaBancaria co on co.NumeroCuenta = t.CuentaOrigen
                                inner join PV_CuentaBancaria cd on (
                                                                    cd.NumeroCuenta = t.CuentaDestino OR
                                                                    cd.CuentaClave = t.CuentaDestino
                                                                    )
                                inner join PV_TipoMoneda tm on tm.TipoMonedaCorto = t.MonedaPago
                                inner join FI_Factura fac on fac.UUID = t.UUIDFactura
                                where t.IdContrato = @pIdContrato  and
                                t.IdTransferenciaImportacion = @idTransferImport
                
                                SELECT @IdTransfer = IdTransferencia
                                from [FI_TransferImportacion] t
                                inner join PV_CuentaBancaria co on co.NumeroCuenta = t.CuentaOrigen
                                inner join PV_CuentaBancaria cd on  (
                                                                    cd.NumeroCuenta = t.CuentaDestino OR
                                                                    cd.CuentaClave = t.CuentaDestino
                                                                    )
                                inner join PV_TipoMoneda tm on tm.TipoMonedaCorto = t.MonedaPago
                                inner join FI_Factura fac on fac.UUID = t.UUIDFactura
                                inner join FI_Transfer tr on tr.IdCuentaOrigen = co.DatoBancarioID and
                                                                tr.IdCuentaDestino = cd.DatoBancarioID and
                                                                tr.idContrato = t.IdContrato and
                                                                convert(varchar,tr.FechaPago,112) = convert(varchar,t.FechaPago,112) and
                                                                --tr.MontoPagado  = cast(t.MontoPagado as money) and
                                                                tr.NumeroPolizaContable = t.NumeroPoliza
                                where t.IdContrato = @pIdContrato  and
                                t.IdTransferenciaImportacion = @idTransferImport
                            end
                                        
                            
                            if isnull(@IdTransfer,0) > 0
                            begin

								--Actualizar encabezado
								update FI_Transfer
								set NumeroPolizaContable = t.NumeroPoliza
								from FI_Transfer t1 
								inner join [FI_TransferImportacion] t on t.IdContrato = @pIdContrato  and
														t.IdTransferenciaImportacion = @idTransferImport
								where t1.IdTransferencia = @IdTransfer

                                --Identificar cuantas facturas se deben afectar
                                select @nFacturas1 = count(distinct t2.UUIDFactura)
                                from [FI_TransferImportacion] t 
                                inner join [FI_TransferImportacion] t2 on t2.RFCEmisor = t.RFCEmisor and
                                                                            t2.CuentaOrigen  = t.CuentaOrigen and
                                                                            t2.CuentaDestino = t.CuentaDestino and
                                                                            t2.FechaPago = t.FechaPago
                                inner join FI_Factura fac on fac.UUID = t2.UUIDFactura
                                where t.IdContrato = @pIdContrato  and
                                t.IdTransferenciaImportacion = @idTransferImport
                    
                                insert into FI_TransferFactura(
                                IdTransfer,             IdFactura,          IdPedimentoComprobante,
                                MontoPagado,            CvTipoDocFacturacion,   CreadoPor,          CreadoEn,
                                ModificadoPor,          ModificadoEn
                                )
                                select @IdTransfer,     fac.IdFactura,      null,
                                t2.ValorFactura,            1,                  @pCreadoPor,            getdate(),
                                null,                   null        
                                from [FI_TransferImportacion] t 
                                inner join [FI_TransferImportacion] t2 on t2.RFCEmisor = t.RFCEmisor and
                                                                            t2.CuentaOrigen  = t.CuentaOrigen and
                                                                            t2.CuentaDestino = t.CuentaDestino and
                                                                            t2.FechaPago = t.FechaPago and
                                                                            t2.NumeroPoliza = t.NumeroPoliza and
                                                                            t2.Id = t.Id
                                inner join FI_Factura fac on fac.UUID = t2.UUIDFactura
                                where t.IdContrato = @pIdContrato  and
                                t.IdTransferenciaImportacion = @idTransferImport and
                                isnull(@IdTransfer,0) > 0 and not exists (
                                    select 1
                                    from FI_TransferFactura st1
                                    where st1.IdTransfer = @IdTransfer and
                                    st1.IdFactura = fac.IdFactura and
                                    st1.MontoPagado = t2.ValorFactura
                                )
                                
                                --Contar cuantas facturas se generaron
                                select @nFacturas2 = count(distinct fac.UUID)
                                from FI_TransferFactura t2
                                inner join FI_Factura fac on fac.IdFactura = t2.IdFactura
                                where IdTransfer = @IdTransfer

                    
                                --Si la cantidad de facturas difiere, marcar error
                                --if(@nFacturas1 <> @nFacturas2)
                                --begin
                                --   RAISERROR('No fue posible generar todas las transacciones para las factura', 16, 1);                       
                        
                                --end
                                --Else
                                --begin
                                    update FI_TransferImportacion
                                    set IdTransferFactura =tf.IdTransferFactura,
                                        Sincronizar = 0,
                                        Procesado = 1,
                                        TieneError = 0,
                                        Error = ''
                                    from FI_TransferImportacion ti
                                    inner join FI_Factura fac on fac.UUID = ti.UUIDFactura
                                    inner join FI_TransferFactura tf on tf.IdTransfer = @IdTransfer and
                                                                tf.IdFactura = fac.IdFactura
                    
                                    COMMIT TRAN

                                --End
            
                            END
                            Else
                            Begin
                                update [FI_TransferImportacion]
                                set TieneError = 1,
                                    Error = 'NO SE ENCONTRÓ LA FACTURA O ALGUNA DE LAS CUENTAS BANCARIAS NO EXISTE',
                                    Sincronizar = 0
                                from [FI_TransferImportacion] t2
                                inner join #tmpImportacion t on t2.RFCEmisor = t.RFCEmisor and
                                t2.CuentaOrigen  = t.CuentaOrigen and
                                t2.CuentaDestino = t.CuentaDestino and
                                t2.FechaPago = t.FechaPago  and                                                                 
                                t.IdTransferenciaImportacion = @idTransferImport
                                --RAISERROR('No fue posible generar el registro de transferencia, asegurase que exista la factura', 16, 1); 
                                COMMIT TRAN
                
                            End

                
                --ELSE SI YA EXISTE TRANSFERENCIA               
                
        END TRY  
        BEGIN CATCH  
            ROLLBACK TRAN

            --MARCAR CON ERROR
            update [FI_TransferImportacion]
            set TieneError = 1,
                Error = ERROR_MESSAGE(),
                Sincronizar = 0
            from [FI_TransferImportacion] t2
            inner join #tmpImportacion t on t2.RFCEmisor = t.RFCEmisor and
            t2.CuentaOrigen  = t.CuentaOrigen and
            t2.CuentaDestino = t.CuentaDestino and
            t2.FechaPago = t.FechaPago  and                                                                 
            t.IdTransferenciaImportacion = @idTransferImport
        END CATCH;   
            
        

        select @idTransferImport = min(IdTransferenciaImportacion)
        from #tmpImportacion
        where IdTransferenciaImportacion > @idTransferImport
    end

    fin:




