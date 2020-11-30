-- =============================================
-- Author: Manuel Cruz
-- Create date: 2017-04-10
-- Description:
-- Modificado: Manuel Cruz
-- Fecha Modificado: 2019-07-01
-- Description: Cambio de update para procesar el nombre de los PUE PPD y Complementos de Pago
-- Modificado:       Marcos Garcia
-- Fecha Modificado: 2020-01-13
-- Description:     *Agregar Validacion de @IdPresupuesto = 0
--                  *Agregar WITH (NOLOCK) en las tablas 
-- =============================================

CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_22_M_IdDoc]
-- [SIPAC_RC_CONT_22_M_IdDoc] 10016,'2019-06-01',1
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
         FROM dbo.AP_Calendario
         WHERE YEAR(@Mes) = Anio
               AND MONTH(@Mes) = Mes
               AND Descripcion = 'Recepción de Información para el cálculo de contraprestaciones';
         --
         SELECT @DiaActual = DAY(GETDATE());

         /**/

         IF OBJECT_ID('tempdb..#Factura', 'U') IS NOT NULL
             DROP TABLE #FI_Factura;
         CREATE TABLE #FI_Factura
         ([IdFactura]  [INT], 
          [IdContrato] [INT], 
          [SIPAC]      [INT]
         );

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

         INSERT INTO #FI_Factura
                SELECT F.IdFactura, 
                       F.IdContrato, 
                       ROW_NUMBER() OVER(ORDER BY F.Fecha, 
                                                  F.IdSubcontratista) AS SIPAC
                FROM dbo.FI_Transfer TR WITH(NOLOCK)
                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TR.IdTransferencia = TF.IdTransfer
                     JOIN dbo.FI_Factura F WITH(NOLOCK) ON TF.IdFactura = F.IdFactura
                     JOIN dbo.CO_Registro R WITH(NOLOCK) ON R.IdFactura = F.IdFactura
                     JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                     JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
                     JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
                     JOIN dbo.CO_Contrato C WITH(NOLOCK) ON AC.IdContrato = C.IdContrato
                     JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista
                     JOIN dbo.CO_Servicio SER WITH(NOLOCK) ON SER.IdServicio = LPM.IdServicio
                                                              AND SER.IdContrato = C.IdContrato
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TR.IdMoneda
                                                                           AND DAY(TCD.Fecha) = DAY(TR.FechaPago)
                                                                           AND MONTH(TCD.Fecha) = MONTH(TR.FechaPago)
                                                                           AND YEAR(TCD.Fecha) = YEAR(TR.FechaPago)
                WHERE C.IdContrato = @Contrato
                      AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
                      AND R.IdEstado = 10004
                      AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
                      AND P.IdPresupuesto = CASE
                                                WHEN @IdPresupuesto = 0
                                                THEN LPM.IdPresupuesto
                                                ELSE @IdPresupuesto
                                            END
                      AND SER.NombreServicio NOT LIKE '%No elegibles%'
                      AND (F.MetodoPago LIKE '%exhibi%'
                           OR F.MetodoPago LIKE '%PUE%'
                           OR F.FormaPago LIKE '%exhibi%'
                           OR F.FormaPago LIKE '%PUE%')
                GROUP BY F.IdFactura, 
                         F.IdContrato, 
                         F.Fecha, 
                         F.IdSubcontratista;

         --
         DECLARE @maxid INT= 0;
         SELECT @maxid = MAX(SIPAC)
         FROM #FI_Factura;
         --

         INSERT INTO #FI_Factura
                SELECT FCPDR.IdFactura, 
                       FCPDR.IdContrato, 
                       ROW_NUMBER() OVER(ORDER BY FCPDR.Fecha, 
                                                  FCPDR.IdSubcontratista) + ISNULL(@maxid, 0) AS SIPAC
                FROM dbo.FI_Transfer TR WITH(NOLOCK)
                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = TR.IdTransferencia
                     JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura
                     JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
                     JOIN dbo.FI_Factura FCP WITH(NOLOCK) ON FCP.IdFactura = CP.IdFactura
                     JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID
                     JOIN dbo.CO_Registro R WITH(NOLOCK) ON FCPDR.IdFactura = R.IdFactura
                     JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON LPM.IdLineaPresupuestoMes = R.IdPrograma
                     JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
                     JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
                     JOIN dbo.CO_Contrato C WITH(NOLOCK) ON C.IdContrato = AC.IdContrato
                     JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON CON.IdContratista = C.IdContratista
                     JOIN dbo.CO_Servicio SER WITH(NOLOCK) ON SER.IdServicio = LPM.IdServicio
                                                              AND SER.IdContrato = C.IdContrato
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TR.IdMoneda
                                                                           AND DAY(TCD.Fecha) = DAY(TR.FechaPago)
                                                                           AND MONTH(TCD.Fecha) = MONTH(TR.FechaPago)
                                                                           AND YEAR(TCD.Fecha) = YEAR(TR.FechaPago)
                WHERE C.IdContrato = @Contrato
                      AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
                      AND R.IdEstado = 10004
                      AND ISNULL(CONVERT(INT, FCP.ProcesadoSIPAC), 0) = 0
                      AND P.IdPresupuesto = CASE
                                                WHEN @IdPresupuesto = 0
                                                THEN LPM.IdPresupuesto
                                                ELSE @IdPresupuesto
                                            END
                      AND SER.NombreServicio NOT LIKE '%No elegibles%'
                GROUP BY FCPDR.IdFactura, 
                         FCPDR.IdContrato, 
                         FCPDR.Fecha, 
                         FCPDR.IdSubcontratista;
         --
         SELECT @maxid = MAX(SIPAC)
         FROM #FI_Factura;
         --

         INSERT INTO #FI_Factura
                SELECT FCP.IdFactura, 
                       FCP.IdContrato, 
                       ROW_NUMBER() OVER(ORDER BY FCP.Fecha, 
                                                  FCP.IdSubcontratista) + ISNULL(@maxid, 0) AS SIPAC
                FROM dbo.FI_Transfer TR WITH(NOLOCK)
                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = TR.IdTransferencia
                     JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura
                     JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
                     JOIN dbo.FI_Factura FCP WITH(NOLOCK) ON FCP.IdFactura = CP.IdFactura
                     JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID
                     JOIN dbo.CO_Registro R WITH(NOLOCK) ON FCPDR.IdFactura = R.IdFactura
                     JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON LPM.IdLineaPresupuestoMes = R.IdPrograma
                     JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
                     JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
                     JOIN dbo.CO_Contrato C WITH(NOLOCK) ON C.IdContrato = AC.IdContrato
                     JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON CON.IdContratista = C.IdContratista
                     JOIN dbo.CO_Servicio SER WITH(NOLOCK) ON SER.IdServicio = LPM.IdServicio
                                                              AND SER.IdContrato = C.IdContrato
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TR.IdMoneda
                                                                           AND DAY(TCD.Fecha) = DAY(TR.FechaPago)
                                                                           AND MONTH(TCD.Fecha) = MONTH(TR.FechaPago)
                                                                           AND YEAR(TCD.Fecha) = YEAR(TR.FechaPago)
                WHERE C.IdContrato = @Contrato
                      AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
                      AND R.IdEstado = 10004
                      AND ISNULL(CONVERT(INT, FCP.ProcesadoSIPAC), 0) = 0
                      AND P.IdPresupuesto = CASE
                                                WHEN @IdPresupuesto = 0
                                                THEN LPM.IdPresupuesto
                                                ELSE @IdPresupuesto
                                            END
                      AND SER.NombreServicio NOT LIKE '%No elegibles%'
                GROUP BY FCP.IdFactura, 
                         FCP.IdContrato, 
                         FCP.Fecha, 
                         FCP.IdSubcontratista;

         --

         UPDATE F
           SET 
               IdDocFacturacionSIPAC = CASE
                                           WHEN F.TipoComprobante <> 'P'
                                           THEN 'CF-'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'-'+RIGHT('000000'+CAST(FP.SIPAC AS VARCHAR(6)), 6)
                                           ELSE 'CFP-'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'-'+RIGHT('000000'+CAST(FP.SIPAC AS VARCHAR(6)), 6)
                                       END, 
               ArchivoXML = CASE
                                WHEN F.TipoComprobante <> 'P'
                                THEN 'CF_'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'_'+RIGHT('000000'+CAST(FP.SIPAC AS VARCHAR(6)), 6)+'.xml'
                                ELSE 'CFP_'+LTRIM(REPLICATE('0', 2-LEN(MONTH(@Mes))))+LTRIM(MONTH(@Mes))+LTRIM(YEAR(@Mes))+'_'+RIGHT('000000'+CAST(FP.SIPAC AS VARCHAR(6)), 6)+'.xml'
                            END
         FROM #FI_Factura FP
              JOIN dbo.FI_Factura F WITH(NOLOCK) ON F.IdFactura = FP.IdFactura
         WHERE FP.IdFactura = F.IdFactura
               AND F.UUID NOT IN
         (
             SELECT RPT.UUID
             FROM #uuidNoReportar RPT
         )
               AND F.UUID NOT IN
         (
             SELECT ControlF.UUID
             FROM dbo.FI_ControlPPDComplementos ControlF WITH(NOLOCK)
             WHERE ControlF.IdContrato = @Contrato
         );

         --END;

     END;