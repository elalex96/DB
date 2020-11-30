-- p_TransferImportFiles_Format_Sel 3,1
CREATE PROC [dbo].[p_TransferImportFiles_Format_Sel]
--
@pIdContrato     INT, 
@pSoloPendientes BIT
--
AS
     IF(@pIdContrato IN (10039,10049,10050,10054,10055,10056,10057))
         BEGIN
             SELECT RFCEmisor = isnull(ti.RFCEmisor, cont.RFC), 
                    Proveedor = isnull(ti.Proveedor, subC.RazonSocial), 
                    FormaPago = isnull(ti.FormaPago, 'Transferencia'), 
                    ti.BancoOrigen, 
                    CuentaOrigen = isnull(ti.CuentaOrigen, cbOrig.NumeroCuenta), 
                    ti.BancoDestino, 
                    CuentaDestino = isnull(ti.CuentaDestino, cbDest.NumeroCuenta), 
                    FechaPago = isnull(ti.FechaPago, t.FechaPago), 
                    MontoPagado = T.MontoPagado, 
                    T.Intereses AS Interes, 
                    MonedaPago = isnull(ti.MonedaPago, mon.TipoMonedaCorto), 
                    Concepto = isnull(ti.Concepto, t.Concepto), 
                    NumeroPoliza = isnull(ti.NumeroPoliza, t.Intereses), 
                    UUIDFactura = isnull(ti.UUIDFactura, fac.UUID), 
                    ValorFactura = isnull(ti.ValorFactura, tf.MontoPagado), 
                    MonedaFactura = isnull(ti.MonedaFactura, monF.TipoMonedaCorto), 
                    c.NumeroContrato, 
                    T.IdTransferencia AS IdTransfer, 
                    PDF = CASE
                              WHEN @pSoloPendientes = 1
                              THEN aws.NombreArchivo
                              ELSE isnull(aws.NombreArchivo, 'SIN PDF - Verifique el nombre del archivo')
                          END
             FROM FI_Transfer t
                  INNER JOIN PV_CuentaBancaria cbOrig ON cbOrig.DatoBancarioID = t.IdCuentaOrigen
                  INNER JOIN PV_CuentaBancaria cbDest ON cbDest.DatoBancarioID = t.IdCuentaDestino
                  LEFT JOIN FI_TransferFactura tf ON tf.IdTransfer = t.IdTransferencia
                  LEFT JOIN FI_Factura fac ON fac.IdFactura = tf.IdFactura
                  LEFT JOIN PV_Subcontratista subC ON subC.RFC = fac.Emisor
                  INNER JOIN CO_Contrato c ON c.IdContrato = t.IdContrato
                  INNER JOIN CO_contratista cont ON cont.IdCOntratista = c.IdContratista
                  INNER JOIN PV_TipoMoneda mon ON mon.IdMoneda = t.IdMoneda
                  LEFT JOIN PV_TipoMoneda monF ON monF.IdMoneda = fac.IdMoneda
                  LEFT JOIN AWS_Documentos aws ON aws.AWSDocumentoId = t.AWSPDFId
                  LEFT JOIN [dbo].[FI_TransferImportacion] ti ON ti.IdContrato = t.IdContrato
                                                                 AND ti.IdTransferFactura = tf.IdTransferFactura
                                                                 AND ti.TieneError = 0
                                                                 AND ti.Procesado = 1
                                                                 AND isnull(ti.Sincronizar, 0) = 0
             WHERE t.IdContrato = @pidContrato
                   AND ((@pSoloPendientes = 1
                         AND t.AWSPDFId IS NULL)
                        OR (@pSoloPendientes = 0))
             GROUP BY ti.RFCEmisor, 
                      ti.Proveedor, 
                      ti.FormaPago, 
                      ti.BancoOrigen, 
                      ti.CuentaOrigen, 
                      ti.BancoDestino, 
                      ti.CuentaDestino, 
                      ti.FechaPago, 
                      T.MontoPagado, 
                      T.Intereses, 
                      ti.MonedaPago, 
                      ti.Concepto, 
                      ti.NumeroPoliza, 
                      ti.UUIDFactura, 
                      ti.ValorFactura, 
                      ti.MonedaFactura, 
                      c.NumeroContrato, 
                      T.IdTransferencia, 
                      aws.NombreArchivo, 
                      cbOrig.NumeroCuenta, 
                      cbDest.NumeroCuenta, 
                      t.FechaPago, 
                      mon.TipoMonedaCorto, 
                      t.Concepto, 
                      t.Intereses, 
                      fac.UUID, 
                      tf.MontoPagado, 
                      monF.TipoMonedaCorto, 
                      cont.RFC, 
                      subC.RazonSocial
             ORDER BY T.IdTransferencia DESC;
         END;
         ELSE
         BEGIN
             SELECT RFCEmisor = isnull(ti.RFCEmisor, cont.RFC), 
                    Proveedor = isnull(ti.Proveedor, subC.RazonSocial), 
                    FormaPago = isnull(ti.FormaPago, 'Transferencia'), 
                    ti.BancoOrigen, 
                    CuentaOrigen = isnull(ti.CuentaOrigen, cbOrig.NumeroCuenta), 
                    ti.BancoDestino, 
                    CuentaDestino = isnull(ti.CuentaDestino, cbDest.NumeroCuenta), 
                    FechaPago = isnull(ti.FechaPago, t.FechaPago), 
                    MontoPagado = ti.MontoPagado, 
                    ti.Interes, 
                    MonedaPago = isnull(ti.MonedaPago, mon.TipoMonedaCorto), 
                    Concepto = isnull(ti.Concepto, t.Concepto), 
                    NumeroPoliza = isnull(ti.NumeroPoliza, t.Intereses), 
                    UUIDFactura = isnull(ti.UUIDFactura, fac.UUID), 
                    ValorFactura = isnull(ti.ValorFactura, tf.MontoPagado), 
                    MonedaFactura = isnull(ti.MonedaFactura, monF.TipoMonedaCorto), 
                    c.NumeroContrato, 
                    tf.IdTransfer, 
                    PDF = CASE
                              WHEN @pSoloPendientes = 1
                              THEN aws.NombreArchivo
                              ELSE isnull(aws.NombreArchivo, 'SIN PDF - Verifique el nombre del archivo')
                          END
             FROM FI_Transfer t
                  INNER JOIN PV_CuentaBancaria cbOrig ON cbOrig.DatoBancarioID = t.IdCuentaOrigen
                  INNER JOIN PV_CuentaBancaria cbDest ON cbDest.DatoBancarioID = t.IdCuentaDestino
                  INNER JOIN FI_TransferFactura tf ON tf.IdTransfer = t.IdTransferencia
                  INNER JOIN FI_Factura fac ON fac.IdFactura = tf.IdFactura
                  LEFT JOIN PV_Subcontratista subC ON subC.RFC = fac.Emisor
                  INNER JOIN CO_Contrato c ON c.IdContrato = t.IdContrato
                  INNER JOIN CO_contratista cont ON cont.IdCOntratista = c.IdContratista
                  INNER JOIN PV_TipoMoneda mon ON mon.IdMoneda = t.IdMoneda
                  INNER JOIN PV_TipoMoneda monF ON monF.IdMoneda = fac.IdMoneda
                  LEFT JOIN AWS_Documentos aws ON aws.AWSDocumentoId = t.AWSPDFId
                  LEFT JOIN [dbo].[FI_TransferImportacion] ti ON ti.IdContrato = t.IdContrato
                                                                 AND ti.IdTransferFactura = tf.IdTransferFactura
                                                                 AND ti.TieneError = 0
                                                                 AND ti.Procesado = 1
                                                                 AND isnull(ti.Sincronizar, 0) = 0
             WHERE t.IdContrato = @pidContrato
                   AND ((@pSoloPendientes = 1
                         AND t.AWSPDFId IS NULL)
                        OR (@pSoloPendientes = 0))
             GROUP BY ti.RFCEmisor, 
                      ti.Proveedor, 
                      ti.FormaPago, 
                      ti.BancoOrigen, 
                      ti.CuentaOrigen, 
                      ti.BancoDestino, 
                      ti.CuentaDestino, 
                      ti.FechaPago, 
                      ti.MontoPagado, 
                      ti.Interes, 
                      ti.MonedaPago, 
                      ti.Concepto, 
                      ti.NumeroPoliza, 
                      ti.UUIDFactura, 
                      ti.ValorFactura, 
                      ti.MonedaFactura, 
                      c.NumeroContrato, 
                      tf.IdTransfer, 
                      aws.NombreArchivo, 
                      cbOrig.NumeroCuenta, 
                      cbDest.NumeroCuenta, 
                      t.FechaPago, 
                      mon.TipoMonedaCorto, 
                      t.Concepto, 
                      t.Intereses, 
                      fac.UUID, 
                      tf.MontoPagado, 
                      monF.TipoMonedaCorto, 
                      cont.RFC, 
                      subC.RazonSocial
             ORDER BY tf.IdTransfer DESC;
         END;