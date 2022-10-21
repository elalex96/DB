CREATE PROCEDURE [dbo].[SP_CO_ValidarConvercioTransferencia] 
-- [SP_CO_ValidarConvercioTransferencia] 1003,72630,100000,1,0,1,'',0,0
@IdTransfer            INT, 
@IdDocumento           INT, 
@MontoPagado           MONEY, 
@cvTipoDocumento       INT, 
@Suma                  MONEY, 
@TipoVerificacion      INT, 
@CadenaIdentifacadores VARCHAR(5000), 
@IdContrato            INT, 
@IdUsuario             INT
AS
     BEGIN
         DECLARE @error VARCHAR(500)= '', @accion INT= 0, @TipoMoneda VARCHAR(50), @TipoMonedaDocumento VARCHAR(50), @Conversion VARCHAR(5000), @totalTransferencia MONEY, @IdDocumentoFPC INT;
         DECLARE @IdMonedaPFC INT;
         SELECT @TipoMoneda = TM.TipoMonedaCorto
         FROM dbo.FI_Transfer T (NOLOCK)
              JOIN dbo.PV_TipoMoneda TM ON TM.IdMoneda = T.IdMoneda
         WHERE T.IdTransferencia = @IdTransfer;
         --==
         SELECT @totalTransferencia = ISNULL(MontoPagado, 0)
         FROM dbo.FI_Transfer (NOLOCK)
         WHERE IdTransferencia = @IdTransfer;
         --==
         IF(@TipoVerificacion = 0)
             BEGIN
                 IF(@cvTipoDocumento = 1)
                     BEGIN
                         SET @Conversion =
                         (
                             SELECT CASE
                                        WHEN(T.IdMoneda = 1
                                             AND F.IdMoneda = 2)
                                        THEN(CONVERT(VARCHAR(5000), ROUND(CONVERT(DECIMAL(12, 4), (CONVERT(DECIMAL(12, 4), @MontoPagado) / TCD.TipoCambio)), 4)))
                                        WHEN(T.IdMoneda = 2
                                             AND F.IdMoneda = 1)
                                        THEN(CONVERT(VARCHAR(5000), ROUND(CONVERT(DECIMAL(12, 4), (CONVERT(DECIMAL(12, 4), @MontoPagado) * TCD.TipoCambio)), 4)))
                                    END AS Error
                             FROM dbo.FI_Transfer T (NOLOCK)
                                  LEFT JOIN dbo.CO_TipoCambioDiario TCD (NOLOCK) ON T.FechaPago = TCD.Fecha
                                                                           AND TCD.IdMoneda = 1
                                  LEFT JOIN dbo.FI_Factura F (NOLOCK) ON F.IdFactura = @IdDocumento
                             WHERE T.IdTransferencia = @IdTransfer
                         );
                         --==                        
                         SELECT @TipoMonedaDocumento = TM.TipoMonedaCorto, 
                                @IdMonedaPFC = F.IdMoneda
                         FROM dbo.FI_Factura F (NOLOCK)
                              JOIN dbo.PV_TipoMoneda TM  (NOLOCK) ON TM.IdMoneda = F.IdMoneda
                         WHERE F.IdFactura = @IdDocumento;
                         --==

                         IF(@TipoMoneda <> @TipoMonedaDocumento)
                             BEGIN
                                 IF(@MontoPagado > @totalTransferencia)
                                     BEGIN
                                         IF(@IdMonedaPFC = 10000)
                                             BEGIN
                                                 SET @error = @error+CONCAT('No es posible ligar la factura con ID ', @IdDocumento, ' ya que el monto ', @MontoPagado, ' excede el total de la transferencia de ', @totalTransferencia, '. | La transferencia ', @IdTransfer, ' es de tipo ', @TipoMoneda, ' y la factura ', @IdDocumento, ' es de tipo ', @TipoMonedaDocumento, '.');
                                                 SET @accion = 1;
                                             END;
                                             ELSE
                                             BEGIN
                                                 SET @error = @error+CONCAT('No es posible ligar la factura con ID ', @IdDocumento, ' ya que el monto ', @MontoPagado, ' excede el total de la transferencia de ', @totalTransferencia, '. | La transferencia ', @IdTransfer, ' es de tipo ', @TipoMoneda, ' y la factura ', @IdDocumento, ' es de tipo ', @TipoMonedaDocumento, ' la conversión de ',@TipoMoneda, ' a ',  @TipoMonedaDocumento, ' sería un aproximado de ', @Conversion, ' ', @TipoMonedaDocumento, '.');
                                                 SET @accion = 1;
                                             END;
                                     END;
                                     ELSE
                                     BEGIN
                                         IF(@IdMonedaPFC = 10000)
                                             BEGIN
                                                 SET @error = @error+CONCAT('La transferencia ', @IdTransfer, ' es de tipo ', @TipoMoneda, ' y la factura ', @IdDocumento, ' es de tipo ', @TipoMonedaDocumento, '.');
                                                 SET @accion = 2;
                                             END
                                             ELSE
                                             BEGIN
                                                 SET @error = @error+CONCAT('La transferencia ', @IdTransfer, ' es de tipo ', @TipoMoneda, ' y la factura ', @IdDocumento, ' es de tipo ', @TipoMonedaDocumento, ' la conversión de ',@TipoMoneda, ' a ',  @TipoMonedaDocumento, ' sería un aproximado de ', @Conversion, ' ', @TipoMonedaDocumento, '.');
                                                 SET @accion = 2;
                                             END
                                     END;
                             END;
                         IF(@TipoMoneda = @TipoMonedaDocumento
                            AND @MontoPagado > @totalTransferencia)
                             BEGIN
                                 SET @error = @error+CONCAT('No es posible ligar la factura con ID ', @IdDocumento, ' ya que el monto ', @MontoPagado, ' excede el total de la transferencia ', @IdTransfer, ' de ', @totalTransferencia, '.');
                                 SET @accion = 1;
                             END;
                     END;
                 --==
                 IF(@cvTipoDocumento = 2
                    OR @cvTipoDocumento = 3)
                     BEGIN
                         --==
                         SET @Conversion =
                         (
                             SELECT CASE
                                        WHEN(T.IdMoneda = 1
                                             AND PC.IdMoneda = 2)
                                        THEN(CONVERT(VARCHAR(5000), ROUND(CONVERT(DECIMAL(12, 4), (CONVERT(DECIMAL(12, 4), @MontoPagado) / TCD.TipoCambio)), 4)))
                                        WHEN(T.IdMoneda = 2
                                             AND PC.IdMoneda = 1)
                                        THEN(CONVERT(VARCHAR(5000), ROUND(CONVERT(DECIMAL(12, 4), (CONVERT(DECIMAL(12, 4), @MontoPagado) * TCD.TipoCambio)), 4)))
                                    END AS Error
                             FROM dbo.FI_Transfer T (NOLOCK)
                                  LEFT JOIN dbo.CO_TipoCambioDiario TCD (NOLOCK) ON T.FechaPago = TCD.Fecha
                                                                           AND TCD.IdMoneda = 1
                                  LEFT JOIN dbo.FI_PedimentoComprobante PC (NOLOCK) ON PC.IdPedimentoComprobante = @IdDocumento
                             WHERE T.IdTransferencia = @IdTransfer
                         );
                         --==
                         SELECT @TipoMonedaDocumento = TM.TipoMonedaCorto, 
                                @IdMonedaPFC = PC.IdMoneda
                         FROM dbo.FI_PedimentoComprobante PC (NOLOCK)
                              JOIN dbo.PV_TipoMoneda TM (NOLOCK) ON TM.IdMoneda = PC.IdMoneda
                         WHERE PC.IdPedimentoComprobante = @IdDocumento;
                         --==                        
                         IF(@TipoMoneda <> @TipoMonedaDocumento)
                             BEGIN
                                 IF(@MontoPagado > @totalTransferencia)
                                     BEGIN
                                         IF(@IdMonedaPFC = 10000)
                                             BEGIN
                                                 SET @error = @error+CONCAT('No es posible ligar el pedimento o comprobante con ID ', @IdDocumento, ' ya que el monto ', @MontoPagado, ' excede el total de la transferencia de ', @totalTransferencia, '. | La transferencia ', @IdTransfer, ' es de Tipo ', @TipoMoneda, ' y el pedimento o comprobante ', @IdDocumento, ' es de tipo ', @TipoMoneda, '.');
                                                 SET @accion = 1;
                                             END;
                                             ELSE
                                             BEGIN
                                                 SET @error = @error+CONCAT('No es posible ligar el pedimento o comprobante con ID ', @IdDocumento, ' ya que el monto ', @MontoPagado, ' excede el total de la transferencia de ', @totalTransferencia, '. | La transferencia ', @IdTransfer, ' es de Tipo ', @TipoMoneda, ' y el pedimento o comprobante ', @IdDocumento, ' es de tipo ', @TipoMonedaDocumento, ' la conversión de ',@TipoMoneda , ' a ',  @TipoMonedaDocumento, ' sería un aproximado de ', @Conversion, ' ', @TipoMonedaDocumento, '.');
                                                 SET @accion = 1;
                                             END;
                                     END;
                                     ELSE
                                     BEGIN
                                         IF(@IdMonedaPFC = 10000)
                                             BEGIN
                                                 SET @error = @error+CONCAT('La Transferencia ', @IdTransfer, ' es de tipo ', @TipoMoneda, ' y el pedimento o comprobante ', @IdDocumento, ' es de tipo ', @TipoMonedaDocumento, '.');
                                                 SET @accion = 2;
                                             END
                                             ELSE
                                             BEGIN
                                                 SET @error = @error+CONCAT('La Transferencia ', @IdTransfer, ' es de tipo ', @TipoMoneda, ' y el pedimento o comprobante ', @IdDocumento, ' es de tipo ', @TipoMonedaDocumento, ', la conversión de ',@TipoMoneda , ' a ',  @TipoMonedaDocumento, ' sería un aproximado de ', @Conversion, ' ', @TipoMonedaDocumento, '.');
                                                 SET @accion = 2;
                                             END
                                     END;
                             END;
                         IF(@TipoMoneda = @TipoMonedaDocumento
                            AND @MontoPagado > @totalTransferencia)
                             BEGIN
                                 SET @error = @error+CONCAT('No es posible ligar el pedimento o comprobante con ID ', @IdDocumento, ' ya que el monto ', @MontoPagado, ' excede el total de la transferencia de ', @totalTransferencia, '.');
                                 SET @Accion = 1;
                             END;
                     END;
             END;
         --==
         IF(@TipoVerificacion = 1)
             BEGIN                
                 --==
                 IF OBJECT_ID('tempdb..#DatosPCF', 'U') IS NOT NULL
                     DROP TABLE #DatosPCF;
                 --==
                 CREATE TABLE #DatosPCF
                 (Id       INT, 
                  IdMoneda VARCHAR(5000)
                 );
                 --==
                 IF(@cvTipoDocumento = 1)
                     BEGIN
                         INSERT INTO #DatosPCF
                         (Id, 
                          IdMoneda
                         )
                                SELECT F.IdFactura, 
                                       TM.TipoMonedaCorto
                                FROM dbo.FI_Factura F (NOLOCK)
                                     JOIN dbo.PV_TipoMoneda TM (NOLOCK) ON TM.IdMoneda = F.IdMoneda
                                WHERE F.IdFactura IN
                                (
                                    SELECT *
                                    FROM [fn_FI_StringList2Table](@CadenaIdentifacadores)
                                );
                         --==
                         SELECT TOP 1 @TipoMonedaDocumento = temp.IdMoneda
                         FROM #DatosPCF temp
                         WHERE temp.IdMoneda <> @TipoMoneda;	
                         --==
                         SET @IdDocumentoFPC =
                         (
                             SELECT TOP 1 Id
                             FROM #DatosPCF
                             WHERE IdMoneda <> @TipoMoneda
                         );
                         --==
                         SET @IdMonedaPFC =
                         (
                             SELECT TOP 1 IdMoneda
                             FROM dbo.FI_Factura (NOLOCK)
                             WHERE IdFactura IN
                             (
                                 SELECT Id
                                 FROM #DatosPCF
                                 WHERE IdMoneda <> @TipoMoneda
                             )
                             ORDER BY IdMoneda DESC
                         );
                         --==
                         SET @Conversion =
                         (
                             SELECT CASE
                                        WHEN(T.IdMoneda = 1
                                             AND F.IdMoneda = 2)
                                        THEN(CONVERT(VARCHAR(5000), ROUND(CONVERT(DECIMAL(12, 4), (CONVERT(DECIMAL(12, 4), @Suma) / TCD.TipoCambio)), 4)))
                                        WHEN(T.IdMoneda = 2
                                             AND F.IdMoneda = 1)
                                        THEN(CONVERT(VARCHAR(5000), ROUND(CONVERT(DECIMAL(12, 4), (CONVERT(DECIMAL(12, 4), @Suma) * TCD.TipoCambio)), 4)))
                                    END AS Error
                             FROM dbo.FI_Transfer T (NOLOCK)
                                  LEFT JOIN dbo.CO_TipoCambioDiario TCD (NOLOCK) ON T.FechaPago = TCD.Fecha
                                                                           AND TCD.IdMoneda = 1
                                  LEFT JOIN dbo.FI_Factura F (NOLOCK) ON F.IdFactura = @IdDocumentoFPC
                             WHERE T.IdTransferencia = @IdTransfer
                         );
                         --==
                         IF EXISTS
                         (
                             SELECT *
                             FROM #DatosPCF
                             WHERE IdMoneda <> @TipoMoneda
                         )
                             BEGIN
                                 IF(@Suma > @totalTransferencia)
                                     BEGIN
                                         IF(@IdMonedaPFC = 10000)
                                             BEGIN
                                                 SET @error = @error+CONCAT('No es posible ligar las facturas ya que el monto total de estas es de ', @Suma, ' excede el total de la transferencia de ', @totalTransferencia, '. | La transferencia ', @IdTransfer, ' es de tipo ', @TipoMoneda, ' y las facturas ', STUFF(
                                                 (
                                                     SELECT DISTINCT 
                                                            ', '+CONCAT(tempo.Id, ' es de tipo ', tempo.IdMoneda)
                                                     FROM #DatosPCF tempo FOR XML PATH('')
                                                 ), 1, 2, ''), '.');
                                                 SET @accion = 1;
                                             END;
                                             ELSE
                                             BEGIN
                                                 SET @error = @error+CONCAT('No es posible ligar las facturas ya que el monto total de estas es de ', @Suma, ' excede el total de la transferencia de ', @totalTransferencia, '. | La transferencia ', @IdTransfer, ' es de tipo ', @TipoMoneda, ' y las facturas ', STUFF(
                                                 (
                                                     SELECT DISTINCT 
                                                            ', '+CONCAT(tempo.Id, ' es de tipo ', tempo.IdMoneda)
                                                     FROM #DatosPCF tempo FOR XML PATH('')
                                                 ), 1, 2, ''), ' la conversión de ', @TipoMoneda, ' a ', @TipoMonedaDocumento, ' sería un aproximado de ', @Conversion, ' ', @TipoMonedaDocumento, '.');
                                                 SET @accion = 1;
                                             END;
                                     END;
                                     ELSE
                                     BEGIN
                                         IF(@IdMonedaPFC = 10000)
                                             BEGIN
                                                 SET @error = @error+CONCAT('La transferencia ', @IdTransfer, ' es de tipo ', @TipoMoneda, ' y las facturas ', STUFF(
                                                 (
                                                     SELECT DISTINCT 
                                                            ', '+CONCAT(tempo.Id, ' es de tipo ', tempo.IdMoneda)
                                                     FROM #DatosPCF tempo FOR XML PATH('')
                                                 ), 1, 2, ''), '.');
                                                 SET @accion = 2;
                                             END;
                                             ELSE
                                             BEGIN
                                                 SET @error = @error+CONCAT('La transferencia ', @IdTransfer, ' es de tipo ', @TipoMoneda, ' y las facturas ', STUFF(
                                                 (
                                                     SELECT DISTINCT 
                                                            ', '+CONCAT(tempo.Id, ' es de tipo ', tempo.IdMoneda)
                                                     FROM #DatosPCF tempo FOR XML PATH('')
                                                 ), 1, 2, ''), ' la conversión de ', @TipoMoneda, ' a ', @TipoMonedaDocumento, ' sería un aproximado de ', @Conversion, ' ', @TipoMonedaDocumento, '.');
                                                 SET @accion = 2;
                                             END;
                                     END;
                             END;
                             ELSE
                             BEGIN
                                 IF(@Suma > @totalTransferencia)
                                     BEGIN
                                         SET @error = @error+CONCAT('No es posible ligar las facturas ', STUFF(
                                         (
                                             SELECT DISTINCT 
                                                    ', '+CONVERT(VARCHAR(5000), tempo.Id)
                                             FROM #DatosPCF tempo FOR XML PATH('')
                                         ), 1, 2, ''), ' ya que el monto total a registrar es de ', @Suma, ' excede el total de la transferencia de ', @totalTransferencia, '.');
                                         SET @Accion = 1;
                                     END;
                             END;
                     END;
                 --==
                 IF(@cvTipoDocumento = 2
                    OR @cvTipoDocumento = 3)
                     BEGIN
                         INSERT INTO #DatosPCF
                         (Id, 
                          IdMoneda
                         )
                                SELECT PC.IdPedimentoComprobante, 
                                       TM.TipoMonedaCorto
                                FROM dbo.FI_PedimentoComprobante PC (NOLOCK)
                                     JOIN dbo.PV_TipoMoneda TM (NOLOCK) ON TM.IdMoneda = PC.IdMoneda
                                WHERE PC.IdPedimentoComprobante IN
                                (
                                    SELECT *
                                    FROM [fn_FI_StringList2Table](@CadenaIdentifacadores)
                                );
                         --==
                         SELECT TOP 1 @TipoMonedaDocumento = temp.IdMoneda
                         FROM #DatosPCF temp
                         WHERE temp.IdMoneda <> @TipoMoneda;	
                         --==
                         SET @IdDocumentoFPC =
                         (
                             SELECT TOP 1 Id
                             FROM #DatosPCF
                             WHERE IdMoneda <> @TipoMoneda
                         );
                         SET @IdMonedaPFC =
                         (
                             SELECT TOP 1 IdMoneda
                             FROM dbo.FI_PedimentoComprobante (NOLOCK)
                             WHERE IdPedimentoComprobante IN
                             (
                                 SELECT Id
                                 FROM #DatosPCF
                                 WHERE IdMoneda <> @TipoMoneda
                             )
                             ORDER BY IdMoneda DESC
                         );

                         --==
                         SET @Conversion =
                         (
                             SELECT CASE
                                        WHEN(T.IdMoneda = 1
                                             AND PC.IdMoneda = 2)
                                        THEN(CONVERT(VARCHAR(5000), ROUND(CONVERT(DECIMAL(12, 4), (CONVERT(DECIMAL(12, 4), @Suma) / TCD.TipoCambio)), 4)))
                                        WHEN(T.IdMoneda = 2
                                             AND PC.IdMoneda = 1)
                                        THEN(CONVERT(VARCHAR(5000), ROUND(CONVERT(DECIMAL(12, 4), (CONVERT(DECIMAL(12, 4), @Suma) * TCD.TipoCambio)), 4)))
                                    END AS Error
                             FROM dbo.FI_Transfer T (NOLOCK)
                                  LEFT JOIN dbo.CO_TipoCambioDiario TCD (NOLOCK) ON T.FechaPago = TCD.Fecha
                                                                           AND TCD.IdMoneda = 1
                                  LEFT JOIN dbo.FI_PedimentoComprobante PC (NOLOCK) ON PC.IdPedimentoComprobante = @IdDocumentoFPC
                             WHERE T.IdTransferencia = @IdTransfer
                         );
                         --==
                         IF EXISTS
                         (
                             SELECT *
                             FROM #DatosPCF
                             WHERE IdMoneda <> @TipoMoneda
                         )
                             BEGIN
                                 IF(@Suma > @totalTransferencia)
                                     BEGIN
                                         IF(@IdMonedaPFC = 10000)
                                             BEGIN
                                                 SET @error = @error+CONCAT('No es posible ligar los pedimentos o comprobantes ya que el monto total de estas es de ', @Suma, ' excede el total de la transferencia de ', @totalTransferencia, '. | La transferencia ', @IdTransfer, ' es de tipo ', @TipoMoneda, ' y los pedimentos o comprobantes ', STUFF(
                                                 (
                                                     SELECT DISTINCT 
                                                            ', '+CONCAT(tempo.Id, ' es de tipo ', tempo.IdMoneda)
                                                     FROM #DatosPCF tempo FOR XML PATH('')
                                                 ), 1, 2, ''), ' .');
                                                 SET @accion = 1;
                                             END;
                                             ELSE
                                             BEGIN
                                                 SET @error = @error+CONCAT('No es posible ligar los pedimentos o comprobantes ya que el monto total de estas es de ', @Suma, ' excede el total de la transferencia de ', @totalTransferencia, '. | La transferencia ', @IdTransfer, ' es de tipo ', @TipoMoneda, ' y los pedimentos o comprobantes ', STUFF(
                                                 (
                                                     SELECT DISTINCT 
                                                            ', '+CONCAT(tempo.Id, ' es de tipo ', tempo.IdMoneda)
                                                     FROM #DatosPCF tempo FOR XML PATH('')
                                                 ), 1, 2, ''), ' la conversión de ', @TipoMoneda, ' a ', @TipoMonedaDocumento, ' sería  un aproximado de ', @Conversion, ' ', @TipoMonedaDocumento, '.');
                                                 SET @accion = 1;
                                             END;
                                     END;
                                     ELSE
                                     BEGIN
                                         IF(@IdMonedaPFC = 10000)
                                             BEGIN
                                                 SET @error = @error+CONCAT('La transferencia ', @IdTransfer, ' es de tipo ', @TipoMoneda, ' y los pedimentos o comprobantes ', STUFF(
                                                 (
                                                     SELECT DISTINCT 
                                                            ', '+CONCAT(tempo.Id, ' es de tipo ', tempo.IdMoneda)
                                                     FROM #DatosPCF tempo FOR XML PATH('')
                                                 ), 1, 2, ''), '.');
                                                 SET @accion = 2;
                                             END;
                                             ELSE
                                             BEGIN
                                                 SET @error = @error+CONCAT('La transferencia ', @IdTransfer, ' es de tipo ', @TipoMoneda, ' y los pedimentos o comprobantes ', STUFF(
                                                 (
                                                     SELECT DISTINCT 
                                                            ', '+CONCAT(tempo.Id, ' es de tipo ', tempo.IdMoneda)
                                                     FROM #DatosPCF tempo FOR XML PATH('')
                                                 ), 1, 2, ''), ' la conversión de ', @TipoMoneda, ' a ', @TipoMonedaDocumento, ' sería un aproximado de ', @Conversion, ' ', @TipoMonedaDocumento, '.');
                                                 SET @accion = 2;
                                             END;
                                     END;
                             END;
                             ELSE
                             BEGIN
                                 IF(@Suma > @totalTransferencia)
                                     BEGIN
                                         SET @error = @error+CONCAT('No es posible ligar los pedimentos o comprobantes ', STUFF(
                                         (
                                             SELECT DISTINCT 
                                                    ', '+CONVERT(VARCHAR(5000), tempo.Id)
                                             FROM #DatosPCF tempo FOR XML PATH('')
                                         ), 1, 2, ''), ' ya que el monto total de estas es de ', @Suma, ' excede el total de la transferencia de ', @totalTransferencia, '.');
                                         SET @Accion = 1;
                                     END;
                             END;
                     END;
             END;
         SELECT @error AS Error, 
                @accion AS Accion;
     END;