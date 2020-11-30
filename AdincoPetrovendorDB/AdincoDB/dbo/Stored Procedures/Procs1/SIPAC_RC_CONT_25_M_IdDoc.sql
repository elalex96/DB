
-- =============================================
-- Author: Manuel Cruz
-- Create date: 2017-04-10
-- Description:  
-- =============================================
-- Modificado:       Marcos Garcia
-- Fecha Modificado: 2020-01-13
-- Description:     *Agregar Validacion de @IdPresupuesto = 0
--                  *Agregar WITH (NOLOCK) en las tablas 
-- =============================================
CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_25_M_IdDoc]
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

         /*Actualizar o no nombre archivos*/

         --IF(@DiaActual <= @DiaReporte)
         --BEGIN
         -- PRIMERO CREAR LA TABLA TEMPORAL

         IF OBJECT_ID('tempdb..#PedimentoComprobante', 'U') IS NOT NULL
             DROP TABLE #PedimentoComprobante;
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
                         PC.FechaPago;

         --

         UPDATE dbo.FI_PedimentoComprobante
           SET 
               IdDocFacturacionSIPAC = 'PE-'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'-'+RIGHT('000000'+CAST(PCT.SIPAC AS VARCHAR(6)), 6)
         FROM FI_PedimentoComprobante PC
              JOIN #PedimentoComprobante PCT ON PC.IdPedimentoComprobante = PCT.IdPedimentoComprobante
         WHERE PC.IdPedimentoComprobante = PCT.IdPedimentoComprobante;

         --END;

     END;
