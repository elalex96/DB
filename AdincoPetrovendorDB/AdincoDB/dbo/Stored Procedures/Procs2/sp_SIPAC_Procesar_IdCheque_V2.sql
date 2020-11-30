CREATE PROCEDURE [dbo].[sp_SIPAC_Procesar_IdCheque_V2]
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
                SELECT TR.IdTransferencia, 
                       TR.IdContrato, 
                       TR.IdMetodoPago, 
                       ROW_NUMBER() OVER(ORDER BY TR.FechaPago) AS SIPAC
                FROM FI_Transfer TR WITH(NOLOCK)
                     LEFT JOIN PV_CuentaBancaria cbo WITH(NOLOCK) ON TR.IdCuentaOrigen = cbo.DatoBancarioID
                     LEFT JOIN PV_CuentaBancaria cbd WITH(NOLOCK) ON TR.IdCuentaDestino = cbd.DatoBancarioID
                     LEFT JOIN PV_Subcontratista subo WITH(NOLOCK) ON cbo.IdProveedor = subo.IdSubcontratista
                     LEFT JOIN PV_Subcontratista subd WITH(NOLOCK) ON cbd.IdProveedor = subd.IdSubcontratista
                     LEFT JOIN PV_Banco bo WITH(NOLOCK) ON cbo.BancoID = bo.BancoID
                     LEFT JOIN PV_Banco bd WITH(NOLOCK) ON cbd.BancoID = bd.BancoID
                     LEFT JOIN FI_TransferFactura tf WITH(NOLOCK) ON TR.IdTransferencia = tf.IdTransfer
                     LEFT JOIN FI_Factura f WITH(NOLOCK) ON tf.IdFactura = f.IdFactura
                     LEFT JOIN CO_Registro r WITH(NOLOCK) ON f.IdFactura = r.IdFactura
                     LEFT JOIN CO_LineaPresupuestoMes lpm WITH(NOLOCK) ON r.IdPrograma = lpm.IdLineaPresupuestoMes
                     LEFT JOIN CO_Presupuesto p WITH(NOLOCK) ON p.IdPresupuesto = lpm.IdPresupuesto
                     LEFT JOIN Co_anioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = p.IdAnioContractual
                     LEFT JOIN co_contrato c WITH(NOLOCK) ON AC.IdContrato = c.IdContrato
                     LEFT JOIN PV_TipoMoneda tm WITH(NOLOCK) ON TR.IdMoneda = tm.IdMoneda
                     LEFT JOIN CO_TipoCambioMensual tcm WITH(NOLOCK) ON tm.IdMoneda = tcm.IdMoneda
                                                                        AND tcm.IdMes = MONTH(f.Fecha)
                                                                        AND tcm.Anio = YEAR(f.Fecha)
                     LEFT JOIN ap_lista li WITH(NOLOCK) ON TR.IdClasificacionDocumento = li.idclave
                WHERE c.IdContrato = @Contrato
                      AND DATEFROMPARTS(YEAR(r.MesPresentacion), MONTH(r.MesPresentacion), 1) = @Mes
                      AND r.IdEstado = 10004
                      AND TR.IdMetodoPago = 1
                      AND li.IdGrupo = 10000
                      AND p.IdPresupuesto = CASE
                                                WHEN @IdPresupuesto = 0
                                                THEN lpm.IdPresupuesto
                                                ELSE @IdPresupuesto
                                            END
                      --AND p.idpresupuesto = @IdPresupuesto

                      AND ISNULL(CONVERT(INT, TR.ProcesadoSIPAC), 0) = 0
                GROUP BY TR.IdTransferencia, 
                         TR.IdContrato, 
                         TR.IdMetodoPago, 
                         TR.FechaPago;
         --
         UPDATE dbo.FI_Transfer
           SET
         --IdComprobantePago = CONCAT('CH', '-', LEFT('0'+CAST(MONTH(@Mes) AS VARCHAR(2)), 2)+CAST(YEAR(@Mes) AS CHAR(4)), '-', RIGHT('000000'+CAST(TRT.SIPAC AS VARCHAR(6)), 6))
         --,nombreextencionArchivo = CONCAT('CH', '_', LEFT('0'+CAST(MONTH(@Mes) AS VARCHAR(2)), 2)+CAST(YEAR(@Mes) AS CHAR(4)), '_', RIGHT('000000'+CAST(TRT.SIPAC AS VARCHAR(6)), 6),'.pdf')
               IdComprobantePago = 'CH-'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'-'+RIGHT('000000'+CAST(TRT.SIPAC AS VARCHAR(6)), 6), 
               NombreExtencionArchivo = 'CH_'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'_'+RIGHT('000000'+CAST(TRT.SIPAC AS VARCHAR(6)), 6)+'.pdf'
         FROM FI_Transfer TR
              JOIN #FI_Transfer TRT ON TR.IdTransferencia = TRT.IdTransferencia
         WHERE TR.IdTransferencia = TRT.IdTransferencia;
         --EXEC sp_SIPAC_Procesar_IdCheque_V2 3,'2017-03-01',3

     END;
