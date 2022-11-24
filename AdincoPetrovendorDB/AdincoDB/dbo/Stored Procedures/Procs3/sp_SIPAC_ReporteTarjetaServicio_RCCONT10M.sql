CREATE PROCEDURE [dbo].[sp_SIPAC_ReporteTarjetaServicio_RCCONT10M]
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT
AS
     BEGIN

         -- =============================================
         -- Author: Manuel Cruz
         -- Create date: 2017-03-23
         -- Description:  
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

         EXEC sp_SIPAC_Procesar_IdTarjetaServicio_V2 
              @Contrato, 
              @Mes, 
              @IdPresupuesto;

         /**/

         SELECT con.IdSipac AS RF_00, 
                c.IdRegFiducidiario AS RI_00, 
                CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(@Mes), MONTH(@Mes), 1)), 103) AS RC10_00, 
                tr.IdComprobantePago AS RC10_01, 
                tr.NombreExtencionArchivo AS RC10_02, 
                tr.ReferenciaBancaria AS RC10_03, 
                CONVERT(CHAR(10), tr.FechaPago, 103) AS RC10_04, 
                subd.RazonSocial AS RC10_05, 
                CAST(ROUND(tr.MontoPagado, 2) AS DECIMAL(15, 2)) AS RC10_06, 
                tm.TipoMonedaCorto AS RC10_07, 
                cbo.NumeroCuenta AS RC10_08,
                CASE
                    WHEN bo.Nacional = 1
                    THEN bo.Banco
                    ELSE ''
                END AS RC10_09,
                CASE
                    WHEN bo.Nacional = 0
                    THEN bo.Banco
                    ELSE ''
                END AS RC10_10,
                CASE
                    WHEN ISNULL(tr.MontoPagado, 0) <> 0
                    THEN CAST(ROUND((ISNULL(tr.MontoPagado, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                    ELSE 0
                END AS RC10_11, 
                CAST(ROUND(TCD.TipoCambio, 2) AS DECIMAL(7, 4)) AS RC10_12, 
                li.idclave AS RC10_13
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
               AND tr.IdMetodoPago = 5
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
                  CASE
                      WHEN ISNULL(tr.MontoPagado, 0) <> 0
                      THEN CAST(ROUND((ISNULL(tr.MontoPagado, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                      ELSE 0
                  END, 
                  CAST(ROUND(TCD.TipoCambio, 2) AS DECIMAL(7, 4)), 
                  li.idclave;
         --EXEC sp_SIPAC_ReporteTarjetaServicio_RCCONT10M 3,'2017-03-01',3

     END;
