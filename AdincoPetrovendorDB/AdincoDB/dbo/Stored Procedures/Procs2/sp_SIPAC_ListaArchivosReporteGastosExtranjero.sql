-- =============================================
-- Author:		Manuel Cruz
-- Create date: 07-06-17
-- Description:	

-- Cambios Por: Neri del Angel
-- Create date: 18 de Marzo del 2022
-- Description:	Ajuste para que obtenga los PE y PI correctamente mediante metodos usadoen el la Hoja 24 y 25
-- =============================================
CREATE PROCEDURE [dbo].[sp_SIPAC_ListaArchivosReporteGastosExtranjero]  
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
		 --========================================
         IF OBJECT_ID('tempdb..#PedimentoComprobante', 'U') IS NOT NULL
             DROP TABLE #PedimentoComprobante;
		--========================================
         CREATE TABLE #PedimentoComprobante
         (IdPedimentoComprobante INT, 
          IdContrato             INT, 
          CvTipoDocFacturacion   INT, 
          SIPAC                  INT
         );
         INSERT INTO #PedimentoComprobante
                SELECT PC.IdPedimentoComprobante, 
                       PC.IdContrato, 
                       PC.CvTipoDocFacturacion, 
                       ROW_NUMBER() OVER(ORDER BY PC.FechaPago) AS SIPAC
                FROM dbo.FI_Transfer TR WITH(NOLOCK)
                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = TR.IdTransferencia
                     JOIN dbo.FI_PedimentoComprobante PC WITH(NOLOCK) ON TF.IdPedimentoComprobante = PC.IdPedimentoComprobante
                     JOIN dbo.CO_Registro R WITH(NOLOCK) ON R.IdPedimentoComprobante = PC.IdPedimentoComprobante
                     JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                     JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
                     JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
                     JOIN dbo.CO_Contrato C WITH(NOLOCK) ON AC.IdContrato = C.IdContrato
                     JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista
                     JOIN dbo.FI_Documento DOC WITH(NOLOCK) ON PC.IdPedimentoComprobante = DOC.IdPedimentoComprobante
                     JOIN dbo.PV_Subcontratista SUBE WITH(NOLOCK) ON PC.IdSubcontratistaExportador = SUBE.IdSubcontratista
                     JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON PC.IdMoneda = TM.IdMoneda
                     JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TM.IdMoneda
                                                                      AND DAY(TCD.Fecha) = DAY(PC.FechaPago)
                                                                      AND MONTH(TCD.Fecha) = MONTH(PC.FechaPago)
                                                                      AND YEAR(TCD.Fecha) = YEAR(PC.FechaPago)
                     JOIN dbo.FI_PedimentoComprobanteDetalle PCD WITH(NOLOCK) ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
                     JOIN dbo.PV_MetodoPago PVM WITH(NOLOCK) ON PVM.idMetodoPago = TR.IdMetodoPago
                     JOIN dbo.CO_Servicio SER WITH(NOLOCK) ON SER.IdServicio = LPM.IdServicio
                WHERE R.CvTipoDocFacturacion = 3
                      AND C.IdContrato = @Contrato
                      AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
                      AND R.IdEstado = 10004
                      AND ISNULL(CONVERT(INT, PC.ProcesadoSIPAC), 0) = 0
                      AND SER.NombreServicio NOT LIKE '%No elegibles%'
                      AND ISNULL(PC.EsnotaCredito, 0) <> 1
                      AND P.IdPresupuesto = CASE
                                                WHEN @IdPresupuesto = 0
                                                THEN LPM.IdPresupuesto
                                                ELSE @IdPresupuesto
                                            END
                GROUP BY PC.IdPedimentoComprobante, 
                         PC.IdContrato, 
                         PC.CvTipoDocFacturacion, 
                         PC.FechaPago
				UNION
                SELECT PC.IdPedimentoComprobante, 
                       PC.IdContrato, 
                       PC.CvTipoDocFacturacion, 
                       ROW_NUMBER() OVER(ORDER BY PC.FechaPago) AS SIPAC
                FROM dbo.FI_Transfer TR WITH(NOLOCK)
                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = TR.IdTransferencia
                     JOIN dbo.FI_PedimentoComprobante PC WITH(NOLOCK) ON TF.IdPedimentoComprobante = PC.IdPedimentoComprobante
                     JOIN dbo.CO_Registro R WITH(NOLOCK) ON R.IdPedimentoComprobante = PC.IdPedimentoComprobante
                     JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                     JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
                     JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
                     JOIN dbo.CO_Contrato C WITH(NOLOCK) ON AC.IdContrato = C.IdContrato
                     JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista
                     JOIN dbo.FI_PedimentoComprobanteDetalle PCD WITH(NOLOCK) ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
                     JOIN dbo.PV_Subcontratista SUBI WITH(NOLOCK) ON PC.IdSubcontratistaImportador = SUBI.IdSubcontratista
                     JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON PC.IdMoneda = TM.IdMoneda
                     JOIN dbo.FI_CFDIMetodoPago CDIM WITH(NOLOCK) ON CDIM.IdCFDIMetodoPago = TR.IdMetodoPago
                     JOIN dbo.PV_Subcontratista SUBE WITH(NOLOCK) ON PC.IdSubcontratistaExportador = SUBE.IdSubcontratista
                     JOIN dbo.FI_ClavesPedimento CV WITH(NOLOCK) ON PC.ClavePedimento = CV.IdPedimento
                     JOIN dbo.CO_Servicio SER WITH(NOLOCK) ON SER.IdServicio = LPM.IdServicio
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TM.IdMoneda
                                                                           AND DAY(TCD.Fecha) = DAY(PC.FechaPago)
                                                                           AND MONTH(TCD.Fecha) = MONTH(PC.FechaPago)
                                                                           AND YEAR(TCD.Fecha) = YEAR(PC.FechaPago)
                WHERE R.CvTipoDocFacturacion = 2
                      AND PC.IdContrato = @Contrato
                      AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
                      AND R.IdEstado = 10004
                      AND ISNULL(CONVERT(INT, PC.ProcesadoSIPAC), 0) = 0
                      AND SER.NombreServicio NOT LIKE '%No elegibles%'
                      AND P.IdPresupuesto = CASE
                                                WHEN @IdPresupuesto = 0
                                                THEN LPM.IdPresupuesto
                                                ELSE @IdPresupuesto
                                            END
                GROUP BY PC.IdPedimentoComprobante, 
                         PC.IdContrato, 
                         PC.CvTipoDocFacturacion, 
                         PC.FechaPago;
		--========================================
		SELECT 
			REPLACE(PC.IdDocFacturacionSIPAC, '-', '_')+'.pdf' AS Nombre, 
				FD.DocumentoByte AS Doc
		FROM #PedimentoComprobante FPC
		JOIN FI_PedimentoComprobante PC ON 
			FPC.IdPedimentoComprobante = PC.IdPedimentoComprobante 
		JOIN dbo.FI_Documento FD ON 
			FD.IdTipoDocumento IN(4, 5) AND FPC.IdPedimentoComprobante = FD.IdPedimentoComprobante 
		ORDER BY IdDocumento DESC
     END;