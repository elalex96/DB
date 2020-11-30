
-- =============================================
-- Author:                            Manuel Cruz
-- Create date: 2017-04-11
-- Description:  
-- =============================================
-- Modificado:       Marcos Garcia
-- Fecha Modificado: 2020-01-13
-- Description:     *Agregar Validacion de @IdPresupuesto = 0
--                  *Agregar WITH (NOLOCK) en las tablas 
-- =============================================
CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_26_M_IdDocFormaPago]
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT  = 0
AS
     BEGIN
         SET NOCOUNT ON;

         -- Insert statements for procedure here

         /*Verificar día de consulta*/

         DECLARE @DiaReporte INT;
         DECLARE @DiaActual INT;

         --

         SELECT @DiaReporte = Dia
         FROM dbo.AP_Calendario WITH(NOLOCK)
         WHERE YEAR(@Mes) = Anio
               AND MONTH(@Mes) = Mes
               AND Descripcion = 'Recepción de Información para el cálculo de contraprestaciones';

         --

         SELECT @DiaActual = DAY(GETDATE());

         /*Omitir facturas en la hoja 22*/

         IF OBJECT_ID('tempdb..#uuidNoReportar', 'U') IS NOT NULL
             DROP TABLE #uuidNoReportar;
         CREATE TABLE #uuidNoReportar(UUID VARCHAR(500));
         IF(@Mes = '20190801')
             BEGIN
                 INSERT INTO #uuidNoReportar(UUID)
             VALUES('091A3242-EF0F-444A-A5C1-3D7D50247D3B'), ('775E782A-9493-3D40-9B24-E1604A865A0F'), ('78BB3869-8091-B049-98B4-1238E15E7BDA'), ('A6344C73-4C5A-EA4A-B2F8-3378CDA24C17');
             END;
         IF(@Mes <> '20190901')
             BEGIN
                 INSERT INTO #uuidNoReportar(UUID)
             VALUES('9A159442-52BC-1E49-8190-D020953CE967');
             END;
         IF(@Mes <> '20200101')
             BEGIN
                 INSERT INTO #uuidNoReportar(UUID)
             VALUES('78CA2E37-22C0-408C-8E94-105C7388A704'), ('30EFEC90-471E-434A-87CF-EFFEEE7C48C1');
             END;
         IF(@Mes = '20200501')
             BEGIN
                 INSERT INTO #uuidNoReportar(UUID)
             VALUES('D515F4A9-244C-422E-A2B1-11B234039715'), ('1091E714-CC8E-46B8-8421-37470C285BAC'), ('95AB6B55-C312-4CAF-9A9E-BD7E7A2124AB'), ('10FDC8FB-DEBB-4BD5-8C10-6B51E61B5FE6');
             END;

         /*Actualizar o no nombre archivos*/

         --IF(@DiaActual <= @DiaReporte)
         --BEGIN

         IF OBJECT_ID('tempdb..#FI_Transfer', 'U') IS NOT NULL
             DROP TABLE #FI_Transfer;
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
                FROM dbo.FI_Transfer TR WITH(NOLOCK)
                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TR.IdTransferencia = TF.IdTransfer
                     JOIN dbo.FI_Factura F WITH(NOLOCK) ON TF.IdFactura = F.IdFactura
                                                           AND F.IdContrato = TR.IdContrato
                     JOIN dbo.CO_Registro R WITH(NOLOCK) ON R.IdFactura = F.IdFactura
                     JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                     JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
                     JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
                     JOIN dbo.CO_Contrato C WITH(NOLOCK) ON AC.IdContrato = C.IdContrato
                     JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista
                     JOIN dbo.CO_Servicio SER WITH(NOLOCK) ON SER.IdServicio = LPM.IdServicio
                                                              AND SER.IdContrato = C.IdContrato

                     --JOIN dbo.PV_CuentaBancaria CBO ON TR.IdCuentaOrigen = CBO.DatoBancarioID
                     --JOIN dbo.PV_CuentaBancaria CBD ON TR.IdCuentaDestino = CBD.DatoBancarioID
                     --JOIN dbo.PV_Subcontratista SUBO ON CBO.IdProveedor = SUBO.IdSubcontratista
                     --JOIN dbo.PV_Subcontratista SUBD ON CBD.IdProveedor = SUBD.IdSubcontratista

                     JOIN dbo.PV_Subcontratista S WITH(NOLOCK) ON F.IdSubcontratista = S.IdSubcontratista
                     JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON TR.IdMoneda = TM.IdMoneda
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TR.IdMoneda
                                                                           AND DAY(TCD.Fecha) = DAY(TR.FechaPago)
                                                                           AND MONTH(TCD.Fecha) = MONTH(TR.FechaPago)
                                                                           AND YEAR(TCD.Fecha) = YEAR(TR.FechaPago)
                     LEFT JOIN dbo.PV_MetodoPago PVM WITH(NOLOCK) ON PVM.idMetodoPago = TR.IdMetodoPago
                WHERE C.IdContrato = @Contrato
                      AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
                      AND R.IdEstado = 10004
                      AND ISNULL(CONVERT(INT, TR.ProcesadoSIPAC), 0) = 0
                      AND SER.NombreServicio NOT LIKE '%No elegibles%'
                      AND (F.MetodoPago LIKE '%exhibi%'
                           OR F.MetodoPago LIKE '%PUE%'
                           OR F.FormaPago LIKE '%exhibi%'
                           OR F.FormaPago LIKE '%PUE%')
                      AND P.IdPresupuesto = CASE
                                                WHEN @IdPresupuesto = 0
                                                THEN LPM.IdPresupuesto
                                                ELSE @IdPresupuesto
                                            END
                --AND DATEFROMPARTS(YEAR(TR.FechaPago), MONTH(TR.FechaPago), 1) = @Mes

                GROUP BY TR.IdTransferencia, 
                         TR.IdContrato, 
                         TR.IdMetodoPago, 
                         TR.FechaPago;

         --
         DECLARE @maxid INT= 0;
         SELECT @maxid = MAX(SIPAC)
         FROM #FI_Transfer;
         --

         INSERT INTO #FI_Transfer
                SELECT TR.IdTransferencia, 
                       TR.IdContrato, 
                       TR.IdMetodoPago, 
                       ROW_NUMBER() OVER(ORDER BY TR.FechaPago) + ISNULL(@maxid, 0) AS SIPAC
                FROM dbo.FI_Transfer TR WITH(NOLOCK)
                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TR.IdTransferencia = TF.IdTransfer
                     JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura
                     JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
                     JOIN dbo.FI_Factura FCP WITH(NOLOCK) ON TF.IdFactura = FCP.IdFactura
                                                             AND TR.IdContrato = FCP.IdContrato
                     JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID
                     JOIN dbo.CO_Registro R WITH(NOLOCK) ON FCPDR.IdFactura = R.IdFactura
                     JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                     JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
                     JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
                     JOIN dbo.CO_Contrato C WITH(NOLOCK) ON AC.IdContrato = C.IdContrato
                     JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista
                     JOIN dbo.CO_Servicio SER WITH(NOLOCK) ON SER.IdServicio = LPM.IdServicio
                                                              AND SER.IdContrato = C.IdContrato

                     --JOIN dbo.PV_CuentaBancaria CBO ON TR.IdCuentaOrigen = CBO.DatoBancarioID
                     --JOIN dbo.PV_CuentaBancaria CBD ON TR.IdCuentaDestino = CBD.DatoBancarioID
                     --JOIN dbo.PV_Subcontratista SUBO ON CBO.IdProveedor = SUBO.IdSubcontratista
                     --JOIN dbo.PV_Subcontratista SUBD ON CBD.IdProveedor = SUBD.IdSubcontratista

                     JOIN dbo.PV_Subcontratista S WITH(NOLOCK) ON FCPDR.IdSubcontratista = S.IdSubcontratista
                     JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON TR.IdMoneda = TM.IdMoneda
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TR.IdMoneda
                                                                           AND DAY(TCD.Fecha) = DAY(TR.FechaPago)
                                                                           AND MONTH(TCD.Fecha) = MONTH(TR.FechaPago)
                                                                           AND YEAR(TCD.Fecha) = YEAR(TR.FechaPago)
                     LEFT JOIN dbo.PV_MetodoPago PVM WITH(NOLOCK) ON PVM.idMetodoPago = TR.IdMetodoPago
                WHERE C.IdContrato = @Contrato
                      AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
                      AND R.IdEstado = 10004
                      AND ISNULL(CONVERT(INT, TR.ProcesadoSIPAC), 0) = 0
                      AND SER.NombreServicio NOT LIKE '%No elegibles%'
                      AND FCP.UUID NOT IN
                (
                    SELECT RPT.UUID
                    FROM #uuidNoReportar RPT
                )
                      AND FCP.UUID NOT IN
                (
                    SELECT ControlF.UUID
                    FROM dbo.FI_ControlPPDComplementos ControlF
                    WHERE ControlF.IdContrato = @Contrato
                )
                      AND P.IdPresupuesto = CASE
                                                WHEN @IdPresupuesto = 0
                                                THEN LPM.IdPresupuesto
                                                ELSE @IdPresupuesto
                                            END

                --AND DATEFROMPARTS(YEAR(TR.FechaPago), MONTH(TR.FechaPago), 1) = @Mes

                GROUP BY TR.IdTransferencia, 
                         TR.IdContrato, 
                         TR.IdMetodoPago, 
                         TR.FechaPago;

         --
         SELECT @maxid = MAX(SIPAC)
         FROM #FI_Transfer;
         --

         INSERT INTO #FI_Transfer
                SELECT TR.IdTransferencia, 
                       TR.IdContrato, 
                       TR.IdMetodoPago, 
                       ROW_NUMBER() OVER(ORDER BY TR.FechaPago) + ISNULL(@maxid, 0) AS SIPAC
                FROM dbo.FI_Transfer TR WITH(NOLOCK)
                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TR.IdTransferencia = TF.IdTransfer
                     JOIN dbo.FI_PedimentoComprobante PC WITH(NOLOCK) ON TF.IdPedimentoComprobante = PC.IdPedimentoComprobante
                                                                         AND TR.IdContrato = PC.IdContrato
                     JOIN dbo.CO_Registro R WITH(NOLOCK) ON R.IdPedimentoComprobante = PC.IdPedimentoComprobante
                     JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                     JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
                     JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
                     JOIN dbo.CO_Contrato C WITH(NOLOCK) ON AC.IdContrato = C.IdContrato
                     JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista
                     JOIN dbo.CO_Servicio SER WITH(NOLOCK) ON SER.IdServicio = LPM.IdServicio
                                                              AND SER.IdContrato = C.IdContrato

                     --JOIN dbo.PV_CuentaBancaria CBO ON TR.IdCuentaOrigen = CBO.DatoBancarioID
                     --JOIN dbo.PV_CuentaBancaria CBD ON TR.IdCuentaDestino = CBD.DatoBancarioID
                     --JOIN dbo.PV_Subcontratista SUBO ON CBO.IdProveedor = SUBO.IdSubcontratista
                     --JOIN dbo.PV_Subcontratista SUBD ON CBD.IdProveedor = SUBD.IdSubcontratista
                     --JOIN dbo.PV_Banco BO ON CBO.BancoID = BO.BancoID
                     --JOIN dbo.PV_Banco BD ON CBD.BancoID = BD.BancoID

                     JOIN dbo.PV_Subcontratista S WITH(NOLOCK) ON PC.IdSubcontratistaExportador = S.IdSubcontratista
                     JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON TR.IdMoneda = TM.IdMoneda
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TM.IdMoneda
                                                                           AND DAY(TCD.Fecha) = DAY(TR.FechaPago)
                                                                           AND MONTH(TCD.Fecha) = MONTH(TR.FechaPago)
                                                                           AND YEAR(TCD.Fecha) = YEAR(TR.FechaPago)
                     LEFT JOIN dbo.PV_MetodoPago PVM WITH(NOLOCK) ON PVM.idMetodoPago = TR.IdMetodoPago
                WHERE C.IdContrato = @Contrato
                      AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
                      AND R.IdEstado = 10004
                      AND ISNULL(CONVERT(INT, TR.ProcesadoSIPAC), 0) = 0
                      AND SER.NombreServicio NOT LIKE '%No elegibles%'
                      AND ISNULL(PC.EsnotaCredito, 0) <> 1
                      AND P.IdPresupuesto = CASE
                                                WHEN @IdPresupuesto = 0
                                                THEN LPM.IdPresupuesto
                                                ELSE @IdPresupuesto
                                            END
                --AND DATEFROMPARTS(YEAR(TR.FechaPago), MONTH(TR.FechaPago), 1) = @Mes

                GROUP BY TR.IdTransferencia, 
                         TR.IdContrato, 
                         TR.IdMetodoPago, 
                         TR.FechaPago;

         --

         UPDATE TR
           SET 
               IdComprobantePago = CASE
                                       WHEN TR.IdMetodoPago = 1
                                       THEN 'CH-'
                                       WHEN TR.IdMetodoPago = 2
                                       THEN 'TC-'
                                       WHEN TR.IdMetodoPago = 3
                                       THEN 'TD-'
                                       WHEN TR.IdMetodoPago = 4
                                       THEN 'TE-'
                                       WHEN TR.IdMetodoPago = 5
                                       THEN 'TS-'
                                       WHEN TR.IdMetodoPago = 6
                                       THEN 'EF-'
                                       WHEN TR.IdMetodoPago = 7
                                       THEN 'ME-'
                                       WHEN TR.IdMetodoPago = 8
                                       THEN 'VD-'
                                       WHEN TR.IdMetodoPago = 9
                                       THEN 'PD-'
                                       WHEN TR.IdMetodoPago = 10
                                       THEN 'DE-'
                                       WHEN TR.IdMetodoPago = 11
                                       THEN 'DP-'
                                       WHEN TR.IdMetodoPago = 12
                                       THEN 'PS-'
                                       WHEN TR.IdMetodoPago = 13
                                       THEN 'PC-'
                                       WHEN TR.IdMetodoPago = 14
                                       THEN 'CD-'
                                       WHEN TR.IdMetodoPago = 15
                                       THEN 'CP-'
                                       WHEN TR.IdMetodoPago = 16
                                       THEN 'NOV-'
                                       WHEN TR.IdMetodoPago = 17
                                       THEN 'CON-'
                                       WHEN TR.IdMetodoPago = 18
                                       THEN 'RD-'
                                       WHEN TR.IdMetodoPago = 19
                                       THEN 'PRE_CAD-'
                                       WHEN TR.IdMetodoPago = 20
                                       THEN 'SA-'
                                       WHEN TR.IdMetodoPago = 21
                                       THEN 'AA-'
                                   END+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'-'+RIGHT('000000'+CAST(TRT.SIPAC AS VARCHAR(6)), 6), 
               NombreExtencionArchivo = CASE
                                            WHEN TR.IdMetodoPago = 1
                                            THEN 'CH_'
                                            WHEN TR.IdMetodoPago = 2
                                            THEN 'TC_'
                                            WHEN TR.IdMetodoPago = 3
                                            THEN 'TD_'
                                            WHEN TR.IdMetodoPago = 4
                                            THEN 'TE_'
                                            WHEN TR.IdMetodoPago = 5
                                            THEN 'TS_'
                                            WHEN TR.IdMetodoPago = 6
                                            THEN 'EF_'
                                            WHEN TR.IdMetodoPago = 7
                                            THEN 'ME_'
                                            WHEN TR.IdMetodoPago = 8
                                            THEN 'VD_'
                                            WHEN TR.IdMetodoPago = 9
                                            THEN 'PD_'
                                            WHEN TR.IdMetodoPago = 10
                                            THEN 'DE_'
                                            WHEN TR.IdMetodoPago = 11
                                            THEN 'DP_'
                                            WHEN TR.IdMetodoPago = 12
                                            THEN 'PS_'
                                            WHEN TR.IdMetodoPago = 13
                                            THEN 'PC_'
                                            WHEN TR.IdMetodoPago = 14
                                            THEN 'CD_'
                                            WHEN TR.IdMetodoPago = 15
                                            THEN 'CP_'
                                            WHEN TR.IdMetodoPago = 16
                                            THEN 'NOV_'
                                            WHEN TR.IdMetodoPago = 17
                                            THEN 'CON_'
                                            WHEN TR.IdMetodoPago = 18
                                            THEN 'RD_'
                                            WHEN TR.IdMetodoPago = 19
                                            THEN 'PRE_CAD_'
                                            WHEN TR.IdMetodoPago = 20
                                            THEN 'SA_'
                                            WHEN TR.IdMetodoPago = 21
                                            THEN 'AA_'
                                        END+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'_'+RIGHT('000000'+CAST(TRT.SIPAC AS VARCHAR(6)), 6)+'.pdf'
         FROM FI_Transfer TR
              JOIN #FI_Transfer TRT ON TR.IdTransferencia = TRT.IdTransferencia
         WHERE TR.IdTransferencia = TRT.IdTransferencia;

         --END;

     END;
