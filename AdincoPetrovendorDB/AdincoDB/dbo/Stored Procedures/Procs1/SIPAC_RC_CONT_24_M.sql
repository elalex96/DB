
-- =============================================
-- Author:                            Yazmin Glez
-- Create date:  2017-11-29
-- Description:  
-- =============================================
-- Modificado:       Marcos Garcia
-- Fecha Modificado: 2020-01-13
-- Description:     *Agregar Validacion de @IdPresupuesto = 0
--                  *Agregar WITH (NOLOCK) en las tablas 
-- =============================================
CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_24_M]
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT  = 0
AS
     BEGIN
         SET NOCOUNT ON;

         /*Generar nombre de archivos*/

         EXEC [SIPAC_RC_CONT_24_M_IdDoc] 
              @Contrato, 
              @Mes, 
              @IdPresupuesto;

         /**/

         SELECT LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00], 
                LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00], 
                C.NumeroContrato AS [RF01_01], 
                MONTH(R.MesPresentacion) AS [RC24_00], --LTRIM(REPLICATE('0', 2-LEN(MONTH(R.MesPresentacion))))+LTRIM(MONTH(R.MesPresentacion)) AS [RC24_00],

                YEAR(R.MesPresentacion) AS [RC24_01], 
                CONCAT(REPLACE(PC.IdDocFacturacionSIPAC, '-', '_'), '.pdf') AS [RC24_02], 
                PC.HashSHA256 AS [RC24_03], 
                LTRIM(RTRIM(SUBSTRING(PC.NumeroPedimento, 0, 20))) AS [RC24_04], 
                LTRIM(RTRIM(SUBSTRING(PC.AcuseElectronico, 0, 12))) AS [RC24_05],
                CASE
                    WHEN ISNULL(PCD.ImporteTotal, 0) <> 0
                    THEN CAST(ROUND((ISNULL(PCD.ImporteTotal, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                    ELSE 0
                END AS [RC24_06], 
                PCD.ImporteTotal AS [RC24_07], 
                LTRIM(RTRIM(SUBSTRING(CV.Clave, 0, 16))) AS [RC24_08], 
                CDIM.Clave AS [RC24_09], 
                TR.FechaPago AS [RC24_10], 
                PC.Regimen AS [RC24_11], 
                LTRIM(RTRIM(SUBSTRING(SUBI.RFC, 0, 13))) AS [RC24_12], 
                PC.AduanaES AS [RC24_13], 
                LTRIM(RTRIM(SUBE.RFC)) AS [RC24_14], 
                LTRIM(RTRIM(SUBE.RazonSocial)) AS [RC24_15], 
                LTRIM(RTRIM(PC.FolioComprobante)) AS [RC24_16], 
                PC.FechaPago AS [RC24_17], 
                PCD.ImporteTotal AS [RC24_18],
                CASE
                    WHEN ISNULL(PCD.ImporteTotal, 0) <> 0
                    THEN CAST(ROUND((ISNULL(PCD.ImporteTotal, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                    ELSE 0
                END AS [RC24_19], 
                2 AS [RC24_20]
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
               AND C.IdContrato = @Contrato
               AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
               AND R.IdEstado = 10004
               AND ISNULL(CONVERT(INT, PC.ProcesadoSIPAC), 0) = 0
               AND SER.NombreServicio NOT LIKE '%No elegibles%'
               AND P.IdPresupuesto = CASE
                                         WHEN @IdPresupuesto = 0
                                         THEN LPM.IdPresupuesto
                                         ELSE @IdPresupuesto
                                     END
         GROUP BY LTRIM(RTRIM(CON.IDSIPAC)), 
                  LTRIM(RTRIM(C.IDRegFiducidiario)), 
                  C.NumeroContrato, 
                  MONTH(R.MesPresentacion), --LTRIM(REPLICATE('0', 2-LEN(MONTH(R.MesPresentacion))))+LTRIM(MONTH(R.MesPresentacion)),

                  YEAR(R.MesPresentacion), 
                  CONCAT(REPLACE(PC.IdDocFacturacionSIPAC, '-', '_'), '.pdf'), 
                  PC.HashSHA256, 
                  LTRIM(RTRIM(SUBSTRING(PC.NumeroPedimento, 0, 20))), 
                  LTRIM(RTRIM(SUBSTRING(PC.AcuseElectronico, 0, 12))),
                  CASE
                      WHEN ISNULL(PCD.ImporteTotal, 0) <> 0
                      THEN CAST(ROUND((ISNULL(PCD.ImporteTotal, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                      ELSE 0
                  END, 
                  PCD.ImporteTotal, 
                  LTRIM(RTRIM(SUBSTRING(CV.Clave, 0, 16))), 
                  CDIM.Clave, 
                  TR.FechaPago, 
                  PC.Regimen, 
                  LTRIM(RTRIM(SUBSTRING(SUBI.RFC, 0, 13))), 
                  PC.AduanaES, 
                  LTRIM(RTRIM(SUBE.RFC)), 
                  LTRIM(RTRIM(SUBE.RazonSocial)), 
                  LTRIM(RTRIM(PC.FolioComprobante)), 
                  PC.FechaPago, 
                  PCD.ImporteTotal,
                  CASE
                      WHEN ISNULL(PCD.ImporteTotal, 0) <> 0
                      THEN CAST(ROUND((ISNULL(PCD.ImporteTotal, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                      ELSE 0
                  END;
     END;
