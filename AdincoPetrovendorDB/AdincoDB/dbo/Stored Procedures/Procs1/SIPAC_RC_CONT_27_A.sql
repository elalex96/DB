CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_27_A]
--SIPAC_RC_CONT_27_A 3,'2019-06-01',1
--SIPAC_RC_CONT_27_A 10005,'2017-11-01',1
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT
AS
     BEGIN
         -- =============================================
         -- Author:		Yazmin Gonzalez-Manuel Cruz
         -- Create date: 28-12-17
         -- Description:	
         -- =============================================
         -- SET NOCOUNT ON added to prevent extra result sets from
         SET NOCOUNT ON;

         /*Generar nombre a los pdf de los EPT*/

         EXEC [SIPAC_RC_CONT_27_A_IdDoc] 
              @Contrato, 
              @Mes, 
              @IdPresupuesto;

         /*Consulta que llena la hoja 27 de la plantilla de EPT*/

         SELECT LTRIM(RTRIM(CC.IDSIPAC)) AS [RF_00], 
                LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00], 
                C.NumeroContrato AS [RF01_01], 
                EPT.IdDocFacturacionSIPAC AS [RC27_01], 
                EPT.FechaInicioVigencia AS [RC27_02], 
                EPT.FechaFinVigencia AS [RC27_03], 
                MONTH(EPT.FechaCargaSIPAC) AS [RC27_04], 
                YEAR(EPT.FechaCargaSIPAC) AS [RC27_05], 
                CONCAT(REPLACE(EPT.IdDocFacturacionSIPAC, '-', '_'), '.pdf') AS [RC27_06], 
                EPT.HashSHA256 AS [RC27_07], 
                2 AS [RC27_08]
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
         --AND P.IdPresupuesto = @IdPresupuesto
         GROUP BY LTRIM(RTRIM(CC.IDSIPAC)), 
                  LTRIM(RTRIM(C.IDRegFiducidiario)), 
                  MONTH(EPT.FechaCargaSIPAC), 
                  YEAR(EPT.FechaCargaSIPAC), 
                  CONCAT(REPLACE(EPT.IdDocFacturacionSIPAC, '-', '_'), '.pdf'), 
                  C.NumeroContrato, 
                  EPT.IdDocFacturacionSIPAC, 
                  EPT.FechaInicioVigencia, 
                  EPT.FechaFinVigencia, 
                  EPT.HashSHA256
         --
         UNION
         --
         SELECT LTRIM(RTRIM(CC.IDSIPAC)) AS [RF_00], 
                LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00], 
                C.NumeroContrato AS [RF01_01], 
                EPT.IdDocFacturacionSIPAC AS [RC27_01], 
                EPT.FechaInicioVigencia AS [RC27_02], 
                EPT.FechaFinVigencia AS [RC27_03], 
                MONTH(EPT.FechaCargaSIPAC) AS [RC27_04], 
                YEAR(EPT.FechaCargaSIPAC) AS [RC27_05], 
                CONCAT(REPLACE(EPT.IdDocFacturacionSIPAC, '-', '_'), '.pdf') AS [RC27_06], 
                EPT.HashSHA256 AS [RC27_07], 
                2 AS [RC27_08]
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
         WHERE C.IdContrato = @Contrato
               AND R.IdEstado = 10004
               AND EPT.FechaCargaSIPAC = @Mes
               AND R.CvTipoDocFacturacion = 1
               AND ISNULL(CONVERT(INT, EPT.ProcesadoSIPAC), 0) = 0
         --AND P.IdPresupuesto = @IdPresupuesto
         GROUP BY LTRIM(RTRIM(CC.IDSIPAC)), 
                  LTRIM(RTRIM(C.IDRegFiducidiario)), 
                  MONTH(EPT.FechaCargaSIPAC), 
                  YEAR(EPT.FechaCargaSIPAC), 
                  CONCAT(REPLACE(EPT.IdDocFacturacionSIPAC, '-', '_'), '.pdf'), 
                  C.NumeroContrato, 
                  EPT.IdDocFacturacionSIPAC, 
                  EPT.FechaInicioVigencia, 
                  EPT.FechaFinVigencia, 
                  EPT.HashSHA256
         --
         UNION
         --
         SELECT LTRIM(RTRIM(CC.IDSIPAC)) AS [RF_00], 
                LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00], 
                C.NumeroContrato AS [RF01_01], 
                EPT.IdDocFacturacionSIPAC AS [RC27_01], 
                EPT.FechaInicioVigencia AS [RC27_02], 
                EPT.FechaFinVigencia AS [RC27_03], 
                MONTH(EPT.FechaCargaSIPAC) AS [RC27_04], 
                YEAR(EPT.FechaCargaSIPAC) AS [RC27_05], 
                CONCAT(REPLACE(EPT.IdDocFacturacionSIPAC, '-', '_'), '.pdf') AS [RC27_06], 
                EPT.HashSHA256 AS [RC27_07], 
                2 AS [RC27_08]
         FROM dbo.FI_EstudioPreciosTransfer EPT
              JOIN dbo.FI_PedimentoComprobante PC ON PC.IdEstudioPrecioTransfer = EPT.IdEstudioPrecioTransfer
              JOIN dbo.CO_Contrato C ON C.IdContrato = EPT.IdContrato
              JOIN dbo.CO_Contratista CC ON CC.IdContratista = C.IdContratista
              JOIN dbo.CO_Registro R ON R.IdPedimentoComprobante = PC.IdPedimentoComprobante
              JOIN dbo.CO_LineaPresupuestoMes L ON L.IdLineaPresupuestoMes = R.IdPrograma
              JOIN dbo.CO_Presupuesto P ON P.IdPresupuesto = L.IdPresupuesto
              JOIN dbo.FI_TransferFactura TF ON TF.IdPedimentoComprobante = PC.IdPedimentoComprobante
              JOIN dbo.FI_Transfer T ON T.IdTransferencia = TF.IdTransfer
         WHERE C.IdContrato = @Contrato
               AND R.IdEstado = 10004
               AND EPT.FechaCargaSIPAC = @Mes
               AND R.CvTipoDocFacturacion IN(2, 3)
              AND ISNULL(CONVERT(INT, EPT.ProcesadoSIPAC), 0) = 0
         --AND P.IdPresupuesto = @IdPresupuesto
         GROUP BY LTRIM(RTRIM(CC.IDSIPAC)), 
                  LTRIM(RTRIM(C.IDRegFiducidiario)), 
                  MONTH(EPT.FechaCargaSIPAC), 
                  YEAR(EPT.FechaCargaSIPAC), 
                  CONCAT(REPLACE(EPT.IdDocFacturacionSIPAC, '-', '_'), '.pdf'), 
                  C.NumeroContrato, 
                  EPT.IdDocFacturacionSIPAC, 
                  EPT.FechaInicioVigencia, 
                  EPT.FechaFinVigencia, 
                  EPT.HashSHA256;
     END;