-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2019-07-05
-- Description:	Devuelve el listado de los EPT
-- =============================================
CREATE PROCEDURE [dbo].[SP_SIPAC_ListaArchivosReporteEPT]
-- SP_SIPAC_ListaArchivosReporteEPT 3,'2019-06-01',1
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT  = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         SET NOCOUNT ON;

         --EPT ligadas a facturas PUE
         SELECT EPT.IdEstudioPrecioTransfer, 
                EPT.IdContrato, 
                CONCAT(REPLACE(EPT.IdDocFacturacionSIPAC, '-', '_'), '.pdf') AS NombreArchivo
         FROM dbo.FI_EstudioPreciosTransfer EPT
              JOIN dbo.FI_Factura F ON F.IdEstudioPrecioTransfer = EPT.IdEstudioPrecioTransfer
              JOIN dbo.CO_Contrato C ON C.IdContrato = EPT.IdContrato
              JOIN dbo.CO_Contratista CC ON CC.IdContratista = C.IdContratista
              JOIN dbo.CO_Registro R ON R.IdFactura = F.IdFactura
              JOIN dbo.CO_LineaPresupuestoMes L ON L.IdLineaPresupuestoMes = R.IdPrograma
              JOIN dbo.CO_Presupuesto P ON P.IdPresupuesto = L.IdPresupuesto
              JOIN dbo.FI_TransferFactura TF ON TF.IdFactura = F.IdFactura
              JOIN dbo.FI_Transfer T ON T.IdTransferencia = TF.IdTransfer
                                        AND F.IdDocFacturacionSIPAC IS NOT NULL
         WHERE C.IdContrato = @Contrato
               AND R.IdEstado = 10004
               AND EPT.FechaCargaSIPAC = @Mes
               AND R.CvTipoDocFacturacion = 1
               AND ISNULL(CONVERT(INT, EPT.ProcesadoSIPAC), 0) = 0
         --AND P.IdPresupuesto = @IdPresupuesto
         GROUP BY CONCAT(REPLACE(EPT.IdDocFacturacionSIPAC, '-', '_'), '.pdf'), 
                  EPT.IdEstudioPrecioTransfer, 
                  EPT.IdContrato
         --EPT ligadas a facturas PPD /*Ya no aplica a partir de EPT 2020*/
         /*UNION
         --
         SELECT EPT.IdEstudioPrecioTransfer, 
                EPT.IdContrato, 
                CONCAT(REPLACE(EPT.IdDocFacturacionSIPAC, '-', '_'), '.pdf') AS NombreArchivo
         FROM dbo.FI_EstudioPreciosTransfer EPT
              JOIN dbo.FI_Factura F ON F.IdEstudioPrecioTransfer = EPT.IdEstudioPrecioTransfer
              JOIN dbo.FI_CPDocRelacionado CPDR ON F.UUID = CPDR.IdDocumento
              JOIN dbo.FI_ComplementoDePago CP ON CP.IdComplementoDePago = CPDR.IdComplementoDePago
              JOIN dbo.FI_Factura FCP ON FCP.IdFactura = CP.IdFactura
              JOIN dbo.CO_Contrato C ON C.IdContrato = EPT.IdContrato
              JOIN dbo.CO_Contratista CC ON CC.IdContratista = C.IdContratista
              JOIN dbo.CO_Registro R ON R.IdFactura = F.IdFactura
              JOIN dbo.CO_LineaPresupuestoMes L ON L.IdLineaPresupuestoMes = R.IdPrograma
              JOIN dbo.CO_Presupuesto P ON P.IdPresupuesto = L.IdPresupuesto
              JOIN dbo.FI_TransferFactura TF ON TF.IdFactura = FCP.IdFactura
              JOIN dbo.FI_Transfer T ON T.IdTransferencia = TF.IdTransfer
                                        AND FCP.IdContrato = T.IdContrato
         WHERE C.IdContrato = @Contrato
               AND R.IdEstado = 10004
               AND EPT.FechaCargaSIPAC = @Mes
               AND R.CvTipoDocFacturacion = 1
               AND ISNULL(CONVERT(INT, EPT.ProcesadoSIPAC), 0) = 0
         --AND P.IdPresupuesto = @IdPresupuest
         GROUP BY CONCAT(REPLACE(EPT.IdDocFacturacionSIPAC, '-', '_'), '.pdf'), 
                  EPT.IdEstudioPrecioTransfer, 
                  EPT.IdContrato*/
         --EPT ligado a Pedimentos de Importación o Complemento de Proveedor Extranjero
         UNION
         --
         SELECT EPT.IdEstudioPrecioTransfer, 
                EPT.IdContrato, 
                CONCAT(REPLACE(EPT.IdDocFacturacionSIPAC, '-', '_'), '.pdf') AS NombreArchivo
         FROM dbo.FI_EstudioPreciosTransfer EPT
              JOIN dbo.FI_PedimentoComprobante PC ON PC.IdEstudioPrecioTransfer = EPT.IdEstudioPrecioTransfer
              JOIN dbo.CO_Contrato C ON C.IdContrato = EPT.IdContrato
              JOIN dbo.CO_Contratista CC ON CC.IdContratista = C.IdContratista
              JOIN dbo.CO_Registro R ON R.IdPedimentoComprobante = PC.IdPedimentoComprobante
              JOIN dbo.CO_LineaPresupuestoMes L ON L.IdLineaPresupuestoMes = R.IdPrograma
              JOIN dbo.CO_Presupuesto P ON P.IdPresupuesto = L.IdPresupuesto
              JOIN dbo.FI_TransferFactura TF ON TF.IdPedimentoComprobante = PC.IdPedimentoComprobante
              JOIN dbo.FI_Transfer T ON T.IdTransferencia = TF.IdTransfer
                                        AND PC.IdContrato = T.IdContrato
										AND PC.IdDocFacturacionSIPAC IS NOT NULL
         WHERE C.IdContrato = @Contrato
               AND R.IdEstado = 10004
               AND EPT.FechaCargaSIPAC = @Mes
               AND R.CvTipoDocFacturacion IN(2, 3)
              AND ISNULL(CONVERT(INT, EPT.ProcesadoSIPAC), 0) = 0
         --AND P.IdPresupuesto = @IdPresupuesto
         GROUP BY CONCAT(REPLACE(EPT.IdDocFacturacionSIPAC, '-', '_'), '.pdf'), 
                  EPT.IdEstudioPrecioTransfer, 
                  EPT.IdContrato
         --EPT ligado al Complemento de Pago de la factura PPD principal relacionado al gasto
         UNION
         --
         SELECT EPT.IdEstudioPrecioTransfer, 
                EPT.IdContrato, 
                CONCAT(REPLACE(EPT.IdDocFacturacionSIPAC, '-', '_'), '.pdf') AS NombreArchivo
         FROM dbo.FI_EstudioPreciosTransfer EPT
             JOIN dbo.FI_Factura F ON F.IdEstudioPrecioTransfer = EPT.IdEstudioPrecioTransfer
             JOIN dbo.FI_ComplementoDePago CP ON CP.IdFactura = F.IdFactura
             JOIN dbo.FI_CPDocRelacionado DR ON CP.IdComplementoDePago = DR.IdComplementoDePago
             JOIN dbo.FI_Factura FDR ON FDR.UUID = DR.IdDocumento
             JOIN dbo.CO_Contrato C ON C.IdContrato = EPT.IdContrato
             JOIN dbo.CO_Contratista CC ON CC.IdContratista = C.IdContratista
             JOIN dbo.CO_Registro R ON R.IdFactura = FDR.IdFactura
             JOIN dbo.CO_LineaPresupuestoMes L ON L.IdLineaPresupuestoMes = R.IdPrograma
             JOIN dbo.CO_Presupuesto P ON P.IdPresupuesto = L.IdPresupuesto
             JOIN dbo.FI_TransferFactura TF ON TF.IdFactura = F.IdFactura
             JOIN dbo.FI_Transfer T ON T.IdTransferencia = TF.IdTransfer
                                       AND F.IdContrato = T.IdContrato
                                       AND F.IdDocFacturacionSIPAC IS NOT NULL
         WHERE C.IdContrato = @Contrato
             AND R.IdEstado = 10004
             AND EPT.FechaCargaSIPAC = @Mes
             AND R.CvTipoDocFacturacion = 1
             AND ISNULL(CONVERT(INT, EPT.ProcesadoSIPAC), 0) = 0
             AND F.IdDocFacturacionSIPAC IS NOT NULL
             AND F.IdDocFacturacionSIPAC NOT LIKE '%2018%'
         GROUP BY CONCAT(REPLACE(EPT.IdDocFacturacionSIPAC, '-', '_'), '.pdf'), 
                  EPT.IdEstudioPrecioTransfer, 
                  EPT.IdContrato
     END;
