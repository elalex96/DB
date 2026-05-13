CREATE PROCEDURE [dbo].[sp_SIPAC_Procesar_IdTarjetaCredito_V2]
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT
AS
     BEGIN

         -- =============================================
         -- Author: Manuel Cruz
         -- Create date: 2017-04-11
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

         -- Insert statements for procedure here

         CREATE TABLE #FI_Transfer
         ([IdTransferencia] INT, 
          [IdContrato]      INT, 
          [IdMetodoPago]    INT, 
          SIPAC             INT
         );
         INSERT INTO #FI_Transfer
                SELECT tr.IdTransferencia, 
                       tr.IdContrato, 
                       tr.IdMetodoPago, 
                       ROW_NUMBER() OVER(ORDER BY tr.FechaPago) AS SIPAC
                FROM FI_Transfer tr WITH(NOLOCK)
                     LEFT JOIN FI_TransferFactura tf WITH(NOLOCK) ON tr.IdTransferencia = tf.IdTransfer
                     LEFT JOIN FI_Factura f WITH(NOLOCK) ON tf.IdFactura = f.IdFactura
                     LEFT JOIN CO_Registro r WITH(NOLOCK) ON r.IdFactura = f.IdFactura
                     LEFT JOIN CO_LineaPresupuestoMes lpm WITH(NOLOCK) ON r.IdPrograma = lpm.IdLineaPresupuestoMes
                     LEFT JOIN CO_Presupuesto p WITH(NOLOCK) ON p.IdPresupuesto = lpm.IdPresupuesto
                     LEFT JOIN co_contrato c WITH(NOLOCK) ON tr.IdContrato = c.IdContrato
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
                      AND tr.IdMetodoPago = 2
                      AND li.IdGrupo = 10000
                      AND ISNULL(CONVERT(INT, tr.ProcesadoSIPAC), 0) = 0
                      AND lpm.IdPresupuesto = CASE
                                                  WHEN @IdPresupuesto = 0
                                                  THEN lpm.IdPresupuesto
                                                  ELSE @IdPresupuesto
                                              END
                --AND p.idpresupuesto = @IdPresupuesto

                GROUP BY tr.IdTransferencia, 
                         tr.IdContrato, 
                         tr.IdMetodoPago, 
                         tr.FechaPago;
         --
         UPDATE dbo.FI_Transfer
           SET 
               IdComprobantePago = CONCAT('TC', '-', LEFT('0'+CAST(MONTH(@Mes) AS VARCHAR(2)), 2)+CAST(YEAR(@Mes) AS CHAR(4)), '-', RIGHT('000000'+CAST(TRT.SIPAC AS VARCHAR(6)), 6)), 
               NombreExtencionArchivo = 'TC_'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'_'+RIGHT('000000'+CAST(TRT.SIPAC AS VARCHAR(6)), 6)+'.pdf'
         FROM FI_Transfer TR
              JOIN #FI_Transfer TRT ON TR.IdTransferencia = TRT.IdTransferencia
         WHERE TR.IdTransferencia = TRT.IdTransferencia;
         --sp_SIPAC_Procesar_IdTarjetaCredito_V2 10005,'20180401',1

     END;
