CREATE PROCEDURE [dbo].[sp_SIPAC_ReporteTransferencia_RCCONT06M]
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT
AS
     BEGIN

         -- =============================================
         -- Author: Manuel Cruz
         -- Create date:  21-03-17
         -- Description:   Reporte de CGI - MP Transferencia Electrónica. Plantilla
         --                                                            RC_CONT_06_M
         -- =============================================
         -- Modificado:		  Marcos Garcia
         -- Fecha Modificado: 2020-01-23
         -- Description:	  *Agregar Validacion de @IdPresupuesto = 0
         --					  *Agregar WITH (NOLOCK) en las tablas 
         -- =============================================
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.

         SET NOCOUNT ON;

         /**/

         EXEC sp_SIPAC_Procesar_IdTransferencia_V2 
              @Contrato, 
              @Mes, 
              @IdPresupuesto;

         /**/

         SELECT con.IdSipac, 
                c.IdRegFiducidiario, 
                CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(@Mes), MONTH(@Mes), 1)), 103) AS PeriodoReporte, 
                tr.IdComprobantePago AS ComprobantePago, 
                REPLACE(tr.NombreExtencionArchivo, '-', '_') AS ArchivoAsociado, 
                tr.ReferenciaBancaria, 
                CONVERT(CHAR(10), tr.FechaPago, 103) AS FechaPago, 
                subd.RazonSocial AS Beneficiario, 
                CAST(ROUND(tr.MontoPagado, 2) AS DECIMAL(15, 2)) AS MontoPagado, 
                tm.TipoMonedaCorto AS MonedaFuncional, 
                cbo.NumeroCuenta AS CuentaOrigen,
                CASE
                    WHEN bo.Nacional = 1
                    THEN bo.Banco
                    ELSE ''
                END AS BancoOrigenNacional,
                CASE
                    WHEN bo.Nacional = 0
                    THEN bo.Banco
                    ELSE ''
                END AS BancoOrigenExtranjero, 
                LTRIM(RTRIM(REPLACE(REPLACE(cbd.CuentaClave, CHAR(10), ''), CHAR(13), ''))) AS CuentaDestino,
                CASE
                    WHEN bd.Nacional = 1
                    THEN bd.Banco
                    ELSE ''
                END AS BancoDestinoNacional,
                CASE
                    WHEN bd.Nacional = 0
                    THEN bd.Banco
                    ELSE ''
                END AS BancoDestinoExtranjero,
                CASE
                    WHEN ISNULL(tr.MontoPagado, 0) <> 0
                    THEN CAST(ROUND((ISNULL(tr.MontoPagado, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                    ELSE 0
                END AS MontoUSD, 
                CAST(ROUND(TCD.TipoCambio, 2) AS DECIMAL(7, 4)) AS TipoCambioUSD, 
                2 AS ClasificacionDocumento
         FROM FI_Transfer tr WITH(NOLOCK)
              LEFT JOIN FI_TransferFactura tf WITH(NOLOCK) ON tr.IdTransferencia = tf.IdTransfer
              LEFT JOIN FI_Factura f WITH(NOLOCK) ON tf.IdFactura = f.IdFactura
              LEFT JOIN CO_Registro r WITH(NOLOCK) ON r.IdFactura = f.IdFactura
              LEFT JOIN CO_LineaPresupuestoMes lpm WITH(NOLOCK) ON r.IdPrograma = lpm.IdLineaPresupuestoMes
              LEFT JOIN CO_Presupuesto p WITH(NOLOCK) ON p.IdPresupuesto = lpm.IdPresupuesto
              LEFT JOIN Co_anioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = p.IdAnioContractual
              LEFT JOIN co_contrato c WITH(NOLOCK) ON AC.IdContrato = c.IdContrato
              LEFT JOIN co_contratista con WITH(NOLOCK) ON c.idcontratista = con.idcontratista
              LEFT JOIN PV_CuentaBancaria cbo WITH(NOLOCK) ON tr.IdCuentaOrigen = cbo.DatoBancarioID
              LEFT JOIN PV_CuentaBancaria cbd WITH(NOLOCK) ON tr.IdCuentaDestino = cbd.DatoBancarioID
              LEFT JOIN PV_Subcontratista subo WITH(NOLOCK) ON cbo.IdProveedor = subo.IdSubcontratista
              LEFT JOIN PV_Subcontratista subd WITH(NOLOCK) ON cbd.IdProveedor = subd.IdSubcontratista
              LEFT JOIN PV_Banco bo WITH(NOLOCK) ON cbo.BancoID = bo.BancoID
              LEFT JOIN PV_Banco bd WITH(NOLOCK) ON cbd.BancoID = bd.BancoID
              LEFT JOIN PV_TipoMoneda tm WITH(NOLOCK) ON tr.IdMoneda = tm.IdMoneda
              LEFT JOIN CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = tm.IdMoneda
                                                                AND DAY(TCD.Fecha) = DAY(tr.FechaPago)
                                                                AND MONTH(TCD.Fecha) = MONTH(tr.FechaPago)
                                                                AND YEAR(TCD.Fecha) = YEAR(tr.FechaPago)
              LEFT JOIN ap_lista li WITH(NOLOCK) ON tr.IdClasificacionDocumento = li.idclave
         WHERE c.IdContrato = @Contrato
               AND DATEFROMPARTS(YEAR(r.MesPresentacion), MONTH(r.MesPresentacion), 1) = @Mes
               AND r.IdEstado = 10004
               AND tr.IdMetodoPago = 4
               AND li.IdGrupo = 10000
               AND ISNULL(CONVERT(INT, tr.ProcesadoSIPAC), 0) = 0
               AND p.IdPresupuesto = CASE
                                         WHEN @IdPresupuesto = 0
                                         THEN lpm.IdPresupuesto
                                         ELSE @IdPresupuesto
                                     END
         --AND p.idpresupuesto = @IdPresupuesto

         GROUP BY con.IdSipac, 
                  c.IdRegFiducidiario, 
                  tr.FechaPago, 
                  tr.IdComprobantePago, 
                  tr.NombreExtencionArchivo, 
                  tr.ReferenciaBancaria, 
                  tr.FechaPago, 
                  subd.RazonSocial, 
                  CAST(ROUND(tr.MontoPagado, 2) AS DECIMAL(15, 2)), 
                  tm.TipoMonedaCorto, 
                  cbo.NumeroCuenta,
                  CASE
                      WHEN bo.Nacional = 1
                      THEN bo.Banco
                      ELSE ''
                  END,
                  CASE
                      WHEN bo.Nacional = 0
                      THEN bo.Banco
                      ELSE ''
                  END, 
                  cbd.CuentaClave,
                  CASE
                      WHEN bd.Nacional = 1
                      THEN bd.Banco
                      ELSE ''
                  END,
                  CASE
                      WHEN bd.Nacional = 0
                      THEN bd.Banco
                      ELSE ''
                  END,
                  CASE
                      WHEN ISNULL(tr.MontoPagado, 0) <> 0
                      THEN CAST(ROUND((ISNULL(tr.MontoPagado, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                      ELSE 0
                  END, 
                  CAST(ROUND(TCD.TipoCambio, 2) AS DECIMAL(7, 4)), 
                  li.IdClave
         --
         UNION
         --
         SELECT con.IdSipac, 
                c.IdRegFiducidiario, 
                CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(@Mes), MONTH(@Mes), 1)), 103) AS PeriodoReporte, 
                tr.IdComprobantePago AS ComprobantePago, 
                REPLACE(tr.NombreExtencionArchivo, '-', '_') AS ArchivoAsociado, 
                tr.ReferenciaBancaria, 
                CONVERT(CHAR(10), tr.FechaPago, 103) AS FechaPago, 
                subd.RazonSocial AS Beneficiario, 
                CAST(ROUND(tr.MontoPagado, 2) AS DECIMAL(15, 2)) AS MontoPagado, 
                tm.TipoMonedaCorto AS MonedaFuncional, 
                cbo.NumeroCuenta AS CuentaOrigen,
                CASE
                    WHEN bo.Nacional = 1
                    THEN bo.Banco
                    ELSE ''
                END AS BancoOrigenNacional,
                CASE
                    WHEN bo.Nacional = 0
                    THEN bo.Banco
                    ELSE ''
                END AS BancoOrigenExtranjero, 
                LTRIM(RTRIM(REPLACE(REPLACE(cbd.CuentaClave, CHAR(10), ''), CHAR(13), ''))) AS CuentaDestino,
                CASE
                    WHEN bd.Nacional = 1
                    THEN bd.Banco
                    ELSE ''
                END AS BancoDestinoNacional,
                CASE
                    WHEN bd.Nacional = 0
                    THEN bd.Banco
                    ELSE ''
                END AS BancoDestinoExtranjero,
                CASE
                    WHEN ISNULL(tr.MontoPagado, 0) <> 0
                    THEN CAST(ROUND((ISNULL(tr.MontoPagado, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                    ELSE 0
                END AS MontoUSD, 
                CAST(ROUND(TCD.tipocambio, 2) AS DECIMAL(7, 4)) AS TipoCambioUSD, 
                2 AS ClasificacionDocumento
         FROM FI_Transfer tr WITH(NOLOCK)
              LEFT JOIN FI_TransferFactura tf WITH(NOLOCK) ON tr.IdTransferencia = tf.IdTransfer
              LEFT JOIN dbo.FI_PedimentoComprobante f WITH(NOLOCK) ON tf.IdPedimentoComprobante = f.IdPedimentoComprobante
              LEFT JOIN CO_Registro r WITH(NOLOCK) ON r.IdPedimentoComprobante = f.IdPedimentoComprobante
              LEFT JOIN CO_LineaPresupuestoMes lpm WITH(NOLOCK) ON r.IdPrograma = lpm.IdLineaPresupuestoMes
              LEFT JOIN CO_Presupuesto p WITH(NOLOCK) ON p.IdPresupuesto = lpm.IdPresupuesto
              LEFT JOIN Co_anioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = p.IdAnioContractual
              LEFT JOIN co_contrato c WITH(NOLOCK) ON AC.IdContrato = c.IdContrato
              LEFT JOIN co_contratista con WITH(NOLOCK) ON c.idcontratista = con.idcontratista
              LEFT JOIN PV_CuentaBancaria cbo WITH(NOLOCK) ON tr.IdCuentaOrigen = cbo.DatoBancarioID
              LEFT JOIN PV_CuentaBancaria cbd WITH(NOLOCK) ON tr.IdCuentaDestino = cbd.DatoBancarioID
              LEFT JOIN PV_Subcontratista subo WITH(NOLOCK) ON cbo.IdProveedor = subo.IdSubcontratista
              LEFT JOIN PV_Subcontratista subd WITH(NOLOCK) ON cbd.IdProveedor = subd.IdSubcontratista
              LEFT JOIN PV_Banco bo WITH(NOLOCK) ON cbo.BancoID = bo.BancoID
              LEFT JOIN PV_Banco bd WITH(NOLOCK) ON cbd.BancoID = bd.BancoID
              LEFT JOIN PV_TipoMoneda tm WITH(NOLOCK) ON tr.IdMoneda = tm.IdMoneda
              LEFT JOIN CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = tm.IdMoneda
                                                                AND DAY(TCD.Fecha) = DAY(tr.FechaPago)
                                                                AND MONTH(TCD.Fecha) = MONTH(tr.FechaPago)
                                                                AND YEAR(TCD.Fecha) = YEAR(tr.FechaPago)
              LEFT JOIN ap_lista li WITH(NOLOCK) ON tr.IdClasificacionDocumento = li.idclave
         WHERE c.IdContrato = @Contrato
               AND DATEFROMPARTS(YEAR(r.MesPresentacion), MONTH(r.MesPresentacion), 1) = @Mes
               AND r.IdEstado = 10004
               AND tr.IdMetodoPago = 4
               AND li.IdGrupo = 10000
               AND ISNULL(CONVERT(INT, tr.ProcesadoSIPAC), 0) = 0
               AND p.IdPresupuesto = CASE
                                         WHEN @IdPresupuesto = 0
                                         THEN lpm.IdPresupuesto
                                         ELSE @IdPresupuesto
                                     END
         --AND p.idpresupuesto = @IdPresupuesto

         GROUP BY con.IdSipac, 
                  c.IdRegFiducidiario, 
                  tr.FechaPago, 
                  tr.IdComprobantePago, 
                  tr.NombreExtencionArchivo, 
                  tr.ReferenciaBancaria, 
                  tr.FechaPago, 
                  subd.RazonSocial, 
                  CAST(ROUND(tr.MontoPagado, 2) AS DECIMAL(15, 2)), 
                  tm.TipoMonedaCorto, 
                  cbo.NumeroCuenta,
                  CASE
                      WHEN bo.Nacional = 1
                      THEN bo.Banco
                      ELSE ''
                  END,
                  CASE
                      WHEN bo.Nacional = 0
                      THEN bo.Banco
                      ELSE ''
                  END, 
                  cbd.CuentaClave,
                  CASE
                      WHEN bd.Nacional = 1
                      THEN bd.Banco
                      ELSE ''
                  END,
                  CASE
                      WHEN bd.Nacional = 0
                      THEN bd.Banco
                      ELSE ''
                  END,
                  CASE
                      WHEN ISNULL(tr.MontoPagado, 0) <> 0
                      THEN CAST(ROUND((ISNULL(tr.MontoPagado, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                      ELSE 0
                  END, 
                  CAST(ROUND(TCD.tipocambio, 2) AS DECIMAL(7, 4)), 
                  li.IdClave;

         --EXEC sp_SIPAC_ReporteTransferencia_RCCONT06M 10003,'2016-05-01',10006  --3,'2017-03-01',3

     END;
