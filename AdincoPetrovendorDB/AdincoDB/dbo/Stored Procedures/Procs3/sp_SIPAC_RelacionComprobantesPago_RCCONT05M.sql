CREATE PROCEDURE [dbo].[sp_SIPAC_RelacionComprobantesPago_RCCONT05M]
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT
AS
     BEGIN

         -- =============================================
         -- Author: Manuel Cruz
         -- Create date: 2017-04-19
         -- Description:  
         -- =============================================
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.

         SET NOCOUNT ON;
         EXEC sp_SIPAC_Procesar_IdTransferencia_V2 
              @Contrato, 
              @Mes, 
              @IdPresupuesto;
         EXEC sp_SIPAC_Procesar_IdFactura_V2 
              @Contrato, 
              @Mes, 
              @IdPresupuesto;
         EXEC sp_SIPAC_Procesar_IdCheque_V2 
              @Contrato, 
              @Mes, 
              @IdPresupuesto;
         EXEC sp_SIPAC_Procesar_IdTarjetaCredito_V2 
              @Contrato, 
              @Mes, 
              @IdPresupuesto;
         EXEC sp_SIPAC_Procesar_IdTarjetaDebito_V2 
              @Contrato, 
              @Mes, 
              @IdPresupuesto;
         EXEC sp_SIPAC_Procesar_IdTarjetaServicio_V2 
              @Contrato, 
              @Mes, 
              @IdPresupuesto;

         /**/

         SELECT con.IdSipac, 
                c.IdRegFiducidiario, 
                CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(@Mes), MONTH(@Mes), 1)), 103) AS PeriodoReporte, 
                PC.IdDocFacturacionSIPAC AS IdentificadorDocumentoFacturacion,
                --ROW_NUMBER() OVER(ORDER BY TR.IdComprobantePago ASC) AS NumeroReferenciaParaRegistrar,
                tr.IdComprobantePago, 
                SUM(CASE
                        WHEN ISNULL(r.MontoRegistro, 0) <> 0
                        THEN CAST(ROUND((ISNULL(r.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                        ELSE 0
                    END) AS 'MontoUSD Ampara Comprobante Pago', 
                '' AS NumeroParcialidad, 
                CONVERT(CHAR(10), tr.FechaPago, 103) AS FechaPago, 
                CAST(ROUND(tr.Intereses, 2) AS DECIMAL(15, 2)) AS Intereses, 
                CAST(ROUND(tr.MontoPagado, 2) AS DECIMAL(15, 2)) AS MontoPagado,
                --CAST(ROUND((TR.MontoPagado - TR.Intereses), 2) AS DECIMAL(15, 2))
                0 AS SaldoDespuesDelPago
         FROM FI_Transfer tr WITH(NOLOCK)
              JOIN FI_TransferFactura tf WITH(NOLOCK) ON tr.IdTransferencia = tf.IdTransfer
              JOIN FI_PedimentoComprobante PC WITH(NOLOCK) ON tf.IdPedimentoComprobante = PC.IdPedimentoComprobante
              JOIN CO_Registro r WITH(NOLOCK) ON r.IdPedimentoComprobante = PC.IdPedimentoComprobante
              JOIN CO_LineaPresupuestoMes lpm WITH(NOLOCK) ON r.IdPrograma = lpm.IdLineaPresupuestoMes
              JOIN CO_Presupuesto p WITH(NOLOCK) ON p.IdPresupuesto = lpm.IdPresupuesto
              JOIN Co_anioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = p.IdAnioContractual
              JOIN co_contrato c WITH(NOLOCK) ON AC.IdContrato = c.IdContrato
              JOIN co_contratista con WITH(NOLOCK) ON c.idcontratista = con.idcontratista
              JOIN PV_TipoMoneda tm WITH(NOLOCK) ON tr.IdMoneda = tm.IdMoneda
              JOIN CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = tm.IdMoneda
                                                           AND DAY(TCD.Fecha) = DAY(tr.FechaPago)
                                                           AND MONTH(TCD.Fecha) = MONTH(tr.FechaPago)
                                                           AND YEAR(TCD.Fecha) = YEAR(tr.FechaPago)
         WHERE c.IdContrato = @Contrato
               AND DATEFROMPARTS(YEAR(r.MesPresentacion), MONTH(r.MesPresentacion), 1) = @Mes
               AND r.IdEstado = 10004
               AND r.CvTipoDocFacturacion IN(2, 3)
              AND ISNULL(CONVERT(INT, PC.ProcesadoSIPAC), 0) = 0
              AND p.IdPresupuesto = CASE
                                        WHEN @IdPresupuesto = 0
                                        THEN lpm.IdPresupuesto
                                        ELSE @IdPresupuesto
                                    END
         --AND p.idpresupuesto = @IdPresupuesto

         GROUP BY con.IdSipac, 
                  c.IdRegFiducidiario, 
                  PC.IdDocFacturacionSIPAC, 
                  PC.IdPedimentoComprobante, 
                  tr.IdComprobantePago, 
                  tr.FechaPago, 
                  CAST(ROUND(tr.Intereses, 2) AS DECIMAL(15, 2)), 
                  CAST(ROUND(tr.MontoPagado, 2) AS DECIMAL(15, 2)), 
                  CAST(ROUND((tr.MontoPagado - tr.Intereses), 2) AS DECIMAL(15, 2))
         --
         UNION
         --
         SELECT con.IdSipac, 
                c.IdRegFiducidiario, 
                CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(@Mes), MONTH(@Mes), 1)), 103) AS PeriodoReporte, 
                f.IdDocFacturacionSIPAC AS IdentificadorDocumentoFacturacion,
                --ROW_NUMBER() OVER(ORDER BY TR.IdComprobantePago ASC) AS NumeroReferenciaParaRegistrar,
                tr.IdComprobantePago, 
                SUM(CASE
                        WHEN ISNULL(r.MontoRegistro, 0) <> 0
                        THEN CAST(ROUND((ISNULL(r.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                        ELSE 0
                    END) AS 'MontoUSD Ampara Comprobante Pago', 
                '' AS NumeroParcialidad, 
                CONVERT(CHAR(10), tr.FechaPago, 103) AS FechaPago, 
                CAST(ROUND(tr.Intereses, 2) AS DECIMAL(15, 2)) AS Intereses, 
                CAST(ROUND(tr.MontoPagado, 2) AS DECIMAL(15, 2)) AS MontoPagado, 
                0 AS SaldoDespuesDelPago
         --CAST (ROUND((TR.MontoPagado - TR.Intereses),2) AS DECIMAL (15,2)) AS SaldoDespuesDelPago
         FROM FI_Transfer tr WITH(NOLOCK)
              JOIN FI_TransferFactura tf WITH(NOLOCK) ON tr.IdTransferencia = tf.IdTransfer
              JOIN FI_Factura f WITH(NOLOCK) ON tf.IdFactura = f.IdFactura
              JOIN CO_Registro r WITH(NOLOCK) ON r.IdFactura = f.IdFactura
              JOIN CO_LineaPresupuestoMes lpm WITH(NOLOCK) ON r.IdPrograma = lpm.IdLineaPresupuestoMes
              JOIN CO_Presupuesto p WITH(NOLOCK) ON p.IdPresupuesto = lpm.IdPresupuesto
              JOIN Co_anioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = p.IdAnioContractual
              JOIN co_contrato c WITH(NOLOCK) ON AC.IdContrato = c.IdContrato
              JOIN co_contratista con WITH(NOLOCK) ON c.idcontratista = con.idcontratista
              JOIN PV_TipoMoneda tm WITH(NOLOCK) ON tr.IdMoneda = tm.IdMoneda
              JOIN CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = tm.IdMoneda
                                                           AND DAY(TCD.Fecha) = DAY(tr.FechaPago)
                                                           AND MONTH(TCD.Fecha) = MONTH(tr.FechaPago)
                                                           AND YEAR(TCD.Fecha) = YEAR(tr.FechaPago)
         WHERE c.IdContrato = @Contrato
               AND DATEFROMPARTS(YEAR(r.MesPresentacion), MONTH(r.MesPresentacion), 1) = @Mes
               AND r.IdEstado = 10004
               AND r.CvTipoDocFacturacion = 1
               AND ISNULL(CONVERT(INT, f.ProcesadoSIPAC), 0) = 0
               AND p.IdPresupuesto = CASE
                                         WHEN @IdPresupuesto = 0
                                         THEN lpm.IdPresupuesto
                                         ELSE @IdPresupuesto
                                     END
         --AND p.idpresupuesto = @IdPresupuesto

         GROUP BY con.IdSipac, 
                  c.IdRegFiducidiario, 
                  f.IdDocFacturacionSIPAC, 
                  f.IdFactura, 
                  tr.IdComprobantePago, 
                  tr.FechaPago, 
                  CAST(ROUND(tr.Intereses, 2) AS DECIMAL(15, 2)), 
                  CAST(ROUND(tr.MontoPagado, 2) AS DECIMAL(15, 2)), 
                  CAST(ROUND((tr.MontoPagado - tr.Intereses), 2) AS DECIMAL(15, 2));

         --EXEC sp_SIPAC_RelacionComprobantesPago_RCCONT05M 10003,'2016-05-01',10006  10001,'2017-03-01',3
         --sp_SIPAC_RelacionComprobantesPago_RCCONT05M 10031,'2018-01-01', 10046

     END;
