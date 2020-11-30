
-- =============================================
-- Author:                            Manuel Cruz
-- Create date:  2017-03-29
-- Description:  
-- =============================================
-- Modificado:       Marcos Garcia
-- Fecha Modificado: 2020-01-13
-- Description:     *Agregar Validacion de @IdPresupuesto = 0
--                  *Agregar WITH (NOLOCK) en las tablas 
-- =============================================
CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_25_M]
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT  = 0
AS
     BEGIN
         SET NOCOUNT ON;

         /*Generar nombre de archivos*/

         EXEC [SIPAC_RC_CONT_25_M_IdDoc] 
              @Contrato, 
              @Mes, 
              @IdPresupuesto;

         /**/

         SELECT LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00], 
                C.IdRegFiducidiario AS [RI_00], 
                C.NumeroContrato AS [RF01_01], 
                MONTH(R.MesPresentacion) AS [RC25_00], --LTRIM(REPLICATE('0', 2-LEN(MONTH(R.MesPresentacion))))+LTRIM(MONTH(R.MesPresentacion)) AS [RC25_00],

                YEAR(R.MesPresentacion) AS [RC25_01], 
                CONCAT(REPLACE(PC.IdDocFacturacionSIPAC, '-', '_'), '.pdf') AS [RC25_02], 
                PC.HashSHA256 AS [RC25_03], 
                LTRIM(RTRIM(PC.IdDocFacturacionSIPAC)) AS [RC25_04], 
                SUBSTRING(LTRIM(RTRIM(PC.FolioComprobante)), 0, 36) AS [RC25_05], 
                SUM(CAST(ROUND((PCD.PrecioUnitario), 2) AS DECIMAL(15, 2))) AS [RC25_06], 
                PVM.C_FormaPago AS [RC25_07], 
                TR.FechaPago AS [RC25_08], 
                SUBSTRING(CON.RFC, 0, 13) AS [RC25_09], 
                SUBSTRING(CON.RazonSocial, 0, 120) AS [RC25_10], 
                SUBSTRING(SUBE.RazonSocial, 0, 120) AS [RC25_11], 
                REPLACE(SUBE.RFC, ' ', '') AS [RC25_12], 
                SUBSTRING(REPLACE(ISNULL(PC.NumFacturaC, 'NA'), ' ', ''), 0, 30) AS [RC25_13], 
                PC.FechaPago AS [RC25_14], 
                SUM(CAST(ROUND((PCD.PrecioUnitario), 2) AS DECIMAL(15, 2))) AS [RC25_15], 
                SUM(CASE
                        WHEN ISNULL(PCD.PrecioUnitario, 0) <> 0
                        THEN CAST(ROUND((ISNULL(PCD.PrecioUnitario, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                        ELSE 0
                    END) AS [RC25_16], 
                2 AS [RC25_17]
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

              --JOIN dbo.PV_Subcontratista SUBI ON PC.IdSubcontratistaImportador = SUBI.IdSubcontratista

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
         GROUP BY LTRIM(RTRIM(CON.IDSIPAC)), 
                  C.IdRegFiducidiario, 
                  C.NumeroContrato, 
                  MONTH(R.MesPresentacion), --LTRIM(REPLICATE('0', 2-LEN(MONTH(R.MesPresentacion))))+LTRIM(MONTH(R.MesPresentacion)),

                  YEAR(R.MesPresentacion), 
                  CONCAT(REPLACE(PC.IdDocFacturacionSIPAC, '-', '_'), '.pdf'), 
                  PC.HashSHA256, 
                  LTRIM(RTRIM(PC.IdDocFacturacionSIPAC)), 
                  SUBSTRING(LTRIM(RTRIM(PC.FolioComprobante)), 0, 36),

                  --CAST(ROUND((PCD.PrecioUnitario), 2) AS DECIMAL(15, 2)),

                  PVM.C_FormaPago, 
                  TR.FechaPago, 
                  SUBSTRING(CON.RFC, 0, 13), 
                  SUBSTRING(CON.RazonSocial, 0, 120), 
                  SUBSTRING(SUBE.RazonSocial, 0, 120), 
                  REPLACE(SUBE.RFC, ' ', ''), 
                  SUBSTRING(REPLACE(ISNULL(PC.NumFacturaC, 'NA'), ' ', ''), 0, 30), 
                  PC.FechaPago;             --,
         --CAST(ROUND((PCD.PrecioUnitario), 2) AS DECIMAL(15, 2)),
         --CASE
         --    WHEN ISNULL(PCD.PrecioUnitario, 0) <> 0
         --    THEN CAST(ROUND((ISNULL(PCD.PrecioUnitario, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
         --    ELSE 0
         --END;

     END;
