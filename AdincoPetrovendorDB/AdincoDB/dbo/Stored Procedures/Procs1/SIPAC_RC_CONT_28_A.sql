CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_28_A]
--SIPAC_RC_CONT_28_A 3,'2019-06-01',1
--SIPAC_RC_CONT_28_A 10005,'2017-11-01',1
--SIPAC_RC_CONT_28_A 10039,'2019-07-01',1
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
         --
         SELECT DISTINCT 
                ResultUnion.RF_00, 
                ResultUnion.RI_00, 
                ResultUnion.RC11_01, 
                ResultUnion.RF01_01, 
                ResultUnion.RC28_01, 
                ResultUnion.RC28_02, 
                ResultUnion.RC28_03, 
                ResultUnion.RC28_04, 
                ResultUnion.RC28_05
         FROM
         (
             SELECT LTRIM(RTRIM(CC.IDSIPAC)) AS [RF_00], 
                    LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00], 
                    C.NumeroContrato AS [RC11_01], 
                    EPT.IdDocFacturacionSIPAC AS [RF01_01], 
                    ISNULL(F.UUID, 'NA') AS [RC28_01], 
                    REPLACE(CONCAT(F.IdDocFacturacionSIPAC, '.xml'), '-', '_') AS [RC28_02], 
                    MONTH(R.MesPresentacion) AS [RC28_03], 
                    YEAR(R.MesPresentacion) AS [RC28_04], 
                    2 AS [RC28_05]
             FROM dbo.FI_EstudioPreciosTransfer EPT
                  JOIN dbo.FI_Factura F ON F.IdEstudioPrecioTransfer = EPT.IdEstudioPrecioTransfer
                  JOIN dbo.CO_Contrato C ON C.IdContrato = EPT.IdContrato
                  JOIN dbo.CO_Contratista CC ON CC.IdContratista = C.IdContratista
                  JOIN dbo.CO_Registro R ON R.IdFactura = F.IdFactura
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
             --AND P.IdPresupuesto = @IdPresupuesto
             GROUP BY LTRIM(RTRIM(CC.IDSIPAC)), 
                      LTRIM(RTRIM(C.IDRegFiducidiario)), 
                      EPT.IdDocFacturacionSIPAC, 
                      C.NumeroContrato, 
                      ISNULL(F.UUID, 'NA'), 
                      REPLACE(CONCAT(F.IdDocFacturacionSIPAC, '.xml'), '-', '_'), 
                      MONTH(R.MesPresentacion), 
                      YEAR(R.MesPresentacion)
             --
             UNION
             --
             SELECT LTRIM(RTRIM(CC.IDSIPAC)) AS [RF_00], 
                    LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00], 
                    C.NumeroContrato AS [RC11_01], 
                    EPT.IdDocFacturacionSIPAC AS [RF01_01], 
                    ISNULL(F.UUID, 'NA') AS [RC28_01], 
                    REPLACE(CONCAT(F.IdDocFacturacionSIPAC, '.xml'), '-', '_') AS [RC28_02], 
                    MONTH(R.MesPresentacion) AS [RC28_03], 
                    YEAR(R.MesPresentacion) AS [RC28_04], 
                    2 AS [RC28_05]
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
                                            AND F.IdDocFacturacionSIPAC IS NOT NULL
             WHERE C.IdContrato = @Contrato
                   AND R.IdEstado = 10004
                   AND EPT.FechaCargaSIPAC = @Mes
                   AND R.CvTipoDocFacturacion = 1
                   AND ISNULL(CONVERT(INT, EPT.ProcesadoSIPAC), 0) = 0
             --AND P.IdPresupuesto = @IdPresupuesto
             GROUP BY LTRIM(RTRIM(CC.IDSIPAC)), 
                      LTRIM(RTRIM(C.IDRegFiducidiario)), 
                      EPT.IdDocFacturacionSIPAC, 
                      C.NumeroContrato, 
                      ISNULL(F.UUID, 'NA'), 
                      REPLACE(CONCAT(F.IdDocFacturacionSIPAC, '.xml'), '-', '_'), 
                      MONTH(R.MesPresentacion), 
                      YEAR(R.MesPresentacion)
             --
             UNION
             --
             SELECT LTRIM(RTRIM(CC.IDSIPAC)) AS [RF_00], 
                    LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00], 
                    C.NumeroContrato AS [RC11_01], 
                    EPT.IdDocFacturacionSIPAC AS [RF01_01],
                    CASE
                        WHEN R.CvTipoDocFacturacion = 2
                        THEN ISNULL(PC.NumeroPedimento, 'NA')
                        WHEN R.CvTipoDocFacturacion = 3
                        THEN ISNULL(PC.IdDocFacturacionSIPAC, 'NA')
                    END AS [RC28_01],
                    CASE
                        WHEN R.CvTipoDocFacturacion IN(2, 3)
                        THEN REPLACE(CONCAT(PC.IdDocFacturacionSIPAC, '.pdf'), '-', '_')
                    END AS [RC28_02], 
                    MONTH(R.MesPresentacion) AS [RC28_03], 
                    YEAR(R.MesPresentacion) AS [RC28_04], 
                    2 AS [RC28_05]
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
             GROUP BY LTRIM(RTRIM(CC.IDSIPAC)), 
                      LTRIM(RTRIM(C.IDRegFiducidiario)), 
                      EPT.IdDocFacturacionSIPAC, 
                      C.NumeroContrato,
                      CASE
                          WHEN R.CvTipoDocFacturacion = 2
                          THEN ISNULL(PC.NumeroPedimento, 'NA')
                          WHEN R.CvTipoDocFacturacion = 3
                          THEN ISNULL(PC.IdDocFacturacionSIPAC, 'NA')
                      END,
                      CASE
                          WHEN R.CvTipoDocFacturacion IN(2, 3)
                          THEN REPLACE(CONCAT(PC.IdDocFacturacionSIPAC, '.pdf'), '-', '_')
                      END, 
                      MONTH(R.MesPresentacion), 
                      YEAR(R.MesPresentacion)
             --
             UNION
             --
             SELECT LTRIM(RTRIM(CC.IDSIPAC)) AS [RF_00], 
                    LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00], 
                    C.NumeroContrato AS [RC11_01], 
                    EPT.IdDocFacturacionSIPAC AS [RF01_01], 
                    ISNULL(F.UUID, 'NA') AS [RC28_01], 
                    REPLACE(CONCAT(F.IdDocFacturacionSIPAC, '.xml'), '-', '_') AS [RC28_02], 
                    MONTH(R.MesPresentacion) AS [RC28_03], 
                    YEAR(R.MesPresentacion) AS [RC28_04], 
                    2 AS [RC28_05]
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
             GROUP BY LTRIM(RTRIM(CC.IDSIPAC)), 
                      LTRIM(RTRIM(C.IDRegFiducidiario)), 
                      EPT.IdDocFacturacionSIPAC, 
                      C.NumeroContrato, 
                      ISNULL(F.UUID, 'NA'), 
                      REPLACE(CONCAT(F.IdDocFacturacionSIPAC, '.xml'), '-', '_'), 
                      MONTH(R.MesPresentacion), 
                      YEAR(R.MesPresentacion)
         ) AS ResultUnion
         ORDER BY ResultUnion.RC28_03;
     END;