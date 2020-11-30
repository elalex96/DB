CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_27_A_IdDoc]
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT
AS
     BEGIN
         -- =============================================
         -- Author:		Manuel Cruz
         -- Create date: 07-04-17
         -- Description:	
         -- =============================================
         -- SET NOCOUNT ON added to prevent extra result sets from
         SET NOCOUNT ON;
         --
         IF OBJECT_ID('tempdb..#EstudiosTransfer', 'U') IS NOT NULL
             DROP TABLE #EstudiosTransfer;
         CREATE TABLE #EstudiosTransfer
         (IdEstudioPrecioTransfer INT, 
          IdContrato              INT, 
          SIPAC                   INT
         );
         --
         INSERT INTO #EstudiosTransfer
         (IdEstudioPrecioTransfer, 
          IdContrato, 
          SIPAC
         )
                SELECT EPT.IdEstudioPrecioTransfer, 
                       EPT.IdContrato, 
                       ROW_NUMBER() OVER(ORDER BY EPT.IdEstudioPrecioTransfer) AS SIPAC
                FROM dbo.FI_EstudioPreciosTransfer EPT
                     JOIN dbo.FI_Factura F ON F.IdEstudioPrecioTransfer = EPT.IdEstudioPrecioTransfer
                     JOIN dbo.CO_Contrato C ON C.IdContrato = EPT.IdContrato
                     JOIN dbo.CO_Contratista CC ON CC.IdContratista = C.IdContratista
                     JOIN dbo.CO_Registro R ON R.IdFactura = F.IdFactura
                     JOIN dbo.CO_LineaPresupuestoMes L ON L.IdLineaPresupuestoMes = R.IdPrograma
                     JOIN dbo.CO_Presupuesto P ON P.IdPresupuesto = L.IdPresupuesto
                     JOIN dbo.FI_TransferFactura TF ON TF.IdFactura = F.IdFactura
                     JOIN dbo.FI_Transfer T ON T.IdTransferencia = TF.IdTransfer
                WHERE C.IdContrato = @Contrato
                      AND R.IdEstado = 10004
                      AND EPT.FechaCargaSIPAC = @Mes
                      AND R.CvTipoDocFacturacion = 1
                      AND ISNULL(CONVERT(INT, EPT.ProcesadoSIPAC), 0) = 0
                      AND F.IdEstudioPrecioTransfer IS NOT NULL
                --AND P.IdPresupuesto = @IdPresupuesto
                GROUP BY EPT.IdEstudioPrecioTransfer, 
                         EPT.IdContrato;
         --
         DECLARE @maxid INT;
         SELECT @maxid = MAX(SIPAC)
         FROM #EstudiosTransfer;
         --
         INSERT INTO #EstudiosTransfer
         (IdEstudioPrecioTransfer, 
          IdContrato, 
          SIPAC
         )
                SELECT EPT.IdEstudioPrecioTransfer, 
                       EPT.IdContrato, 
                       ROW_NUMBER() OVER(ORDER BY EPT.IdEstudioPrecioTransfer) + ISNULL(@maxid, 0) AS SIPAC
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
                      AND F.IdEstudioPrecioTransfer IS NOT NULL
                --AND P.IdPresupuesto = @IdPresupuesto
                GROUP BY EPT.IdEstudioPrecioTransfer, 
                         EPT.IdContrato;
         --
         SELECT @maxid = MAX(SIPAC)
         FROM #EstudiosTransfer;
         --
         INSERT INTO #EstudiosTransfer
         (IdEstudioPrecioTransfer, 
          IdContrato, 
          SIPAC
         )
                SELECT EPT.IdEstudioPrecioTransfer, 
                       EPT.IdContrato, 
                       ROW_NUMBER() OVER(ORDER BY EPT.IdEstudioPrecioTransfer) + ISNULL(@maxid, 0) AS SIPAC
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
                WHERE C.IdContrato = @Contrato
                      AND R.IdEstado = 10004
                      AND EPT.FechaCargaSIPAC = @Mes
                      AND R.CvTipoDocFacturacion IN(2, 3)
                     AND ISNULL(CONVERT(INT, EPT.ProcesadoSIPAC), 0) = 0
                     AND PC.IdEstudioPrecioTransfer IS NOT NULL
                --AND P.IdPresupuesto = @IdPresupuesto
                GROUP BY EPT.IdEstudioPrecioTransfer, 
                         EPT.IdContrato;
         --
         UPDATE EPT
           SET 
               IdDocFacturacionSIPAC = 'PT-'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'-'+RIGHT('000000'+CAST(ET.SIPAC AS VARCHAR(6)), 6)
         FROM FI_EstudioPreciosTransfer EPT
              JOIN #EstudiosTransfer ET ON EPT.IdEstudioPrecioTransfer = ET.IdEstudioPrecioTransfer
         WHERE EPT.IdEstudioPrecioTransfer = ET.IdEstudioPrecioTransfer;
     END;