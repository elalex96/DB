
-- =============================================
-- Author:      Manuel Cruz
-- Create date: 07-06-17
-- Description:
-- =============================================
-- Modificado:       Marcos Garcia
-- Fecha Modificado: 2020-01-13
-- Description:     *Agregar Validacion de @IdPresupuesto = 0
--                  *Agregar WITH (NOLOCK) en las tablas 
-- =============================================
CREATE PROCEDURE [dbo].[sp_SIPAC_ListaArchivosReporteGastosComprobantes]
-- [sp_SIPAC_ListaArchivosReporteGastosComprobantes] 10011,'2019-04-01',1
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT  = 0
AS
     BEGIN
         SET NOCOUNT ON;

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

         /*Consulta general*/

         SELECT TR.IdTransferencia, 
                TR.IdContrato, 
                TR.NombreExtencionArchivo AS NombreArchivo
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
              JOIN dbo.PV_CuentaBancaria CBO WITH(NOLOCK) ON TR.IdCuentaOrigen = CBO.DatoBancarioID
              JOIN dbo.PV_CuentaBancaria CBD WITH(NOLOCK) ON TR.IdCuentaDestino = CBD.DatoBancarioID
              JOIN dbo.PV_Subcontratista SUBO WITH(NOLOCK) ON CBO.IdProveedor = SUBO.IdSubcontratista
              JOIN dbo.PV_Subcontratista SUBD WITH(NOLOCK) ON CBD.IdProveedor = SUBD.IdSubcontratista
              JOIN dbo.PV_Banco BO WITH(NOLOCK) ON CBO.BancoID = BO.BancoID
              JOIN dbo.PV_Banco BD WITH(NOLOCK) ON CBD.BancoID = BD.BancoID
              JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON TR.IdMoneda = TM.IdMoneda
              LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TR.IdMoneda
                                                                    AND DAY(TCD.Fecha) = DAY(F.Fecha)
                                                                    AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                                                    AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
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
         --AND P.IdPresupuesto = @IdPresupuesto

         GROUP BY TR.IdTransferencia, 
                  TR.IdContrato, 
                  TR.NombreExtencionArchivo
         --
         UNION
         --
         SELECT TR.IdTransferencia, 
                TR.IdContrato, 
                TR.NombreExtencionArchivo AS NombreArchivo
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
              JOIN dbo.PV_CuentaBancaria CBO WITH(NOLOCK) ON TR.IdCuentaOrigen = CBO.DatoBancarioID
              JOIN dbo.PV_CuentaBancaria CBD WITH(NOLOCK) ON TR.IdCuentaDestino = CBD.DatoBancarioID
              JOIN dbo.PV_Subcontratista SUBO WITH(NOLOCK) ON CBO.IdProveedor = SUBO.IdSubcontratista
              JOIN dbo.PV_Subcontratista SUBD WITH(NOLOCK) ON CBD.IdProveedor = SUBD.IdSubcontratista
              JOIN dbo.PV_Banco BO WITH(NOLOCK) ON CBO.BancoID = BO.BancoID
              JOIN dbo.PV_Banco BD WITH(NOLOCK) ON CBD.BancoID = BD.BancoID
              JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON TR.IdMoneda = TM.IdMoneda
              LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TR.IdMoneda
                                                                    AND DAY(TCD.Fecha) = DAY(FCP.Fecha)
                                                                    AND MONTH(TCD.Fecha) = MONTH(FCP.Fecha)
                                                                    AND YEAR(TCD.Fecha) = YEAR(FCP.Fecha)
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
         --AND P.IdPresupuesto = @IdPresupuesto

         GROUP BY TR.IdTransferencia, 
                  TR.IdContrato, 
                  TR.NombreExtencionArchivo
         --
         UNION
         --
         SELECT TR.IdTransferencia, 
                TR.IdContrato, 
                TR.NombreExtencionArchivo AS NombreArchivo
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
              JOIN dbo.PV_CuentaBancaria CBO WITH(NOLOCK) ON TR.IdCuentaOrigen = CBO.DatoBancarioID
              JOIN dbo.PV_CuentaBancaria CBD ON TR.IdCuentaDestino = CBD.DatoBancarioID
              JOIN dbo.PV_Subcontratista SUBO WITH(NOLOCK) ON CBO.IdProveedor = SUBO.IdSubcontratista
              JOIN dbo.PV_Subcontratista SUBD WITH(NOLOCK) ON CBD.IdProveedor = SUBD.IdSubcontratista
              JOIN dbo.PV_Banco BO WITH(NOLOCK) ON CBO.BancoID = BO.BancoID
              JOIN dbo.PV_Banco BD WITH(NOLOCK) ON CBD.BancoID = BD.BancoID
              JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON TR.IdMoneda = TM.IdMoneda
              LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TM.IdMoneda
                                                                    AND DAY(TCD.Fecha) = DAY(PC.FechaPago)
                                                                    AND MONTH(TCD.Fecha) = MONTH(PC.FechaPago)
                                                                    AND YEAR(TCD.Fecha) = YEAR(PC.FechaPago)
              LEFT JOIN dbo.PV_MetodoPago PVM WITH(NOLOCK) ON PVM.idMetodoPago = TR.IdMetodoPago
         WHERE C.IdContrato = @Contrato
               AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
               AND R.IdEstado = 10004
               AND ISNULL(CONVERT(INT, TR.ProcesadoSIPAC), 0) = 0
               AND SER.NombreServicio NOT LIKE '%No elegibles%'
               AND P.IdPresupuesto = CASE
                                         WHEN @IdPresupuesto = 0
                                         THEN LPM.IdPresupuesto
                                         ELSE @IdPresupuesto
                                     END

         --AND DATEFROMPARTS(YEAR(TR.FechaPago), MONTH(TR.FechaPago), 1) = @Mes
         --AND P.IdPresupuesto = @IdPresupuesto

         GROUP BY TR.IdTransferencia, 
                  TR.IdContrato, 
                  TR.NombreExtencionArchivo;

         ----
         --UNION
         ----
         --SELECT TR.IdTransferencia,
         --       TR.IdContrato,
         --       TR.NombreExtencionArchivo AS NombreArchivo
         --FROM dbo.FI_Transfer TR
         --     JOIN dbo.FI_TransferFactura TF ON TR.IdTransferencia = TF.IdTransfer
         --     JOIN dbo.FI_Factura F ON TF.IdFactura = F.IdFactura
         --                              AND F.IdContrato = TR.IdContrato
         --     JOIN dbo.CO_Registro R ON R.IdFactura = F.IdFactura
         --     JOIN dbo.CO_LineaPresupuestoMes LPM ON R.IdPrograma = LPM.IdLineaPresupuestoMes
         --     JOIN dbo.CO_Presupuesto P ON P.IdPresupuesto = LPM.IdPresupuesto
         --     JOIN dbo.CO_AnioContractual AC ON AC.IdAnioContractual = P.IdAnioContractual
         --     JOIN dbo.CO_Contrato C ON AC.IdContrato = C.IdContrato
         --     JOIN dbo.CO_Contratista CON ON C.IdContratista = CON.IdContratista
         --     JOIN dbo.CO_Servicio SER ON SER.IdServicio = LPM.IdServicio
         --                                 AND SER.IdContrato = C.IdContrato
         --     JOIN dbo.PV_CuentaBancaria CBO ON TR.IdCuentaOrigen = CBO.DatoBancarioID
         --     JOIN dbo.PV_CuentaBancaria CBD ON TR.IdCuentaDestino = CBD.DatoBancarioID
         --     JOIN dbo.PV_Subcontratista SUBO ON CBO.IdProveedor = SUBO.IdSubcontratista
         --     JOIN dbo.PV_Subcontratista SUBD ON CBD.IdProveedor = SUBD.IdSubcontratista
         --     JOIN dbo.PV_Banco BO ON CBO.BancoID = BO.BancoID
         --     JOIN dbo.PV_Banco BD ON CBD.BancoID = BD.BancoID
         --     JOIN dbo.PV_TipoMoneda TM ON TR.IdMoneda = TM.IdMoneda
         --     LEFT JOIN dbo.CO_TipoCambioDiario TCD ON TCD.IdMoneda = TR.IdMoneda
         --                                              AND DAY(TCD.Fecha) = DAY(F.Fecha)
         --                                              AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
         --                                              AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
         --     LEFT JOIN dbo.PV_MetodoPago PVM ON PVM.idMetodoPago = TR.IdMetodoPago
         --WHERE C.IdContrato = @Contrato --10011
         --      AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes --'2019-04-01'
         --      AND R.IdEstado = 10004
         --      AND ISNULL(CONVERT(INT, TR.ProcesadoSIPAC), 0) = 0
         --      AND SER.NombreServicio NOT LIKE '%No elegibles%'
         --      AND (F.MetodoPago NOT LIKE '%exhibi%'
         --           OR F.MetodoPago NOT LIKE '%PUE%'
         --           OR F.FormaPago NOT LIKE '%exhibi%'
         --           OR F.FormaPago NOT LIKE '%PUE%')
         --GROUP BY TR.IdTransferencia,
         --         TR.IdContrato,
         --         TR.NombreExtencionArchivo;

     END;
