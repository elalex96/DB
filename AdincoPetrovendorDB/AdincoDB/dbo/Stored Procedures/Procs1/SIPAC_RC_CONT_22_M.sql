-- =============================================
-- Author: Yazmin Glez.
-- Create date: 2017-11-28
-- Description: Reporte de CGI - Registro de costos. Plantilla antes RC_CONT_02_M actual RC_CONT_22_M
-- Modificado: Manuel Cruz
-- Fecha Modificado: 2019-06-28
-- Description: Cambio de consulta para mostrar los complementos de pago relacionadolos al gasto
-- Modificado:       Neri Del Angel
-- Fecha Modificado: 2020-01-13
-- Description:     *Agregar Validacion de @IdPresupuesto = 0
--                  *Agregar WITH (NOLOCK) en las tablas 
-- Modificado:       Neri Del Angel
-- Fecha Modificado: 2022-02-25
-- Description:     *Se excluyen los E
-- =============================================
CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_22_M]
-- [SIPAC_RC_CONT_22_M] 10024, '2020-12-01', 0
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT  = 0
AS
     BEGIN
         SET NOCOUNT ON;

         /*Generar nombre de archivos*/

         EXEC [SIPAC_RC_CONT_22_M_IdDoc] 
              @Contrato, 
              @Mes, 
              @IdPresupuesto;

         /*Todas las facturas relacionadas a un gasto sin importar pago*/

         IF OBJECT_ID('tempdb..#Facturas', 'U') IS NOT NULL
             DROP TABLE #Facturas;
         CREATE TABLE #Facturas
         (IdFactura       INT, 
          UUID            VARCHAR(500), 
          TipoComprobante VARCHAR(50), 
          MetodoPago      VARCHAR(50)
         );
         INSERT INTO #Facturas
         (IdFactura, 
          UUID, 
          TipoComprobante, 
          MetodoPago
         )
                SELECT F.IdFactura, 
                       F.UUID,
                       CASE
                           WHEN F.TipoComprobante LIKE '%ingreso%'
                                OR F.TipoComprobante LIKE 'I%'
                           THEN 'I'
                           WHEN(F.TipoComprobante) LIKE '%egreso%'
                               OR F.TipoComprobante LIKE 'E%'
                           THEN 'E'
                           WHEN(F.TipoComprobante) LIKE '%traslado%'
                               OR F.TipoComprobante LIKE 'T%'
                           THEN 'T'
                           WHEN(F.TipoComprobante) LIKE '%nómina%'
                               OR F.TipoComprobante LIKE 'N%'
                           THEN 'N'
                           WHEN(F.TipoComprobante) LIKE '%pago%'
                               OR F.TipoComprobante LIKE 'P%'
                           THEN 'P'
                           ELSE 'NA'
                       END AS TipoComprobante,
                       CASE
                           WHEN F.MetodoPago LIKE '%exhibi%'
                                OR F.MetodoPago LIKE '%PUE%'
                                OR F.FormaPago LIKE '%exhibi%'
                                OR F.FormaPago LIKE '%PUE%'
                           THEN 'PUE'
                           WHEN F.MetodoPago LIKE '%parcia%'
                                OR F.MetodoPago LIKE '%dife%'
                                OR F.MetodoPago LIKE '%PPD%'
                                OR F.FormaPago LIKE '%parcia%'
                                OR F.FormaPago LIKE '%dife%'
                                OR F.FormaPago LIKE '%PPD%'
                           THEN 'PPD'
                           WHEN F.TipoComprobante = 'P'
                           THEN 'PPD'
                       END AS MetodoPago
                FROM dbo.CO_Registro R WITH(NOLOCK)
                     JOIN dbo.FI_Factura F WITH(NOLOCK) ON R.IdFactura = F.IdFactura
                     JOIN dbo.CO_Contrato C WITH(NOLOCK) ON C.IdContrato = F.IdContrato
                     JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                     JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = LPM.IdServicio
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = F.IdMoneda
                                                                           AND DAY(TCD.Fecha) = DAY(F.Fecha)
                                                                           AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                                                           AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
                WHERE C.IdContrato = @Contrato
                      AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
                      AND R.IdEstado = 10004
                      AND R.CvTipoDocFacturacion = 1
                      AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
                      AND S.NombreServicio NOT LIKE '%No elegibles%'
                      AND LPM.IdPresupuesto = CASE
                                                  WHEN @IdPresupuesto = 0
                                                  THEN LPM.IdPresupuesto
                                                  ELSE @IdPresupuesto
                                              END
                GROUP BY CASE
                             WHEN F.TipoComprobante LIKE '%ingreso%'
                                  OR F.TipoComprobante LIKE 'I%'
                             THEN 'I'
                             WHEN(F.TipoComprobante) LIKE '%egreso%'
                                 OR F.TipoComprobante LIKE 'E%'
                             THEN 'E'
                             WHEN(F.TipoComprobante) LIKE '%traslado%'
                                 OR F.TipoComprobante LIKE 'T%'
                             THEN 'T'
                             WHEN(F.TipoComprobante) LIKE '%nómina%'
                                 OR F.TipoComprobante LIKE 'N%'
                             THEN 'N'
                             WHEN(F.TipoComprobante) LIKE '%pago%'
                                 OR F.TipoComprobante LIKE 'P%'
                             THEN 'P'
                             ELSE 'NA'
                         END,
                         CASE
                             WHEN F.MetodoPago LIKE '%exhibi%'
                                  OR F.MetodoPago LIKE '%PUE%'
                                  OR F.FormaPago LIKE '%exhibi%'
                                  OR F.FormaPago LIKE '%PUE%'
                             THEN 'PUE'
                             WHEN F.MetodoPago LIKE '%parcia%'
                                  OR F.MetodoPago LIKE '%dife%'
                                  OR F.MetodoPago LIKE '%PPD%'
                                  OR F.FormaPago LIKE '%parcia%'
                                  OR F.FormaPago LIKE '%dife%'
                                  OR F.FormaPago LIKE '%PPD%'
                             THEN 'PPD'
                             WHEN F.TipoComprobante = 'P'
                             THEN 'PPD'
                         END, 
                         F.IdFactura, 
                         F.UUID;

         /*Montos Pagados*/

         IF OBJECT_ID('tempdb..#MontosTotalTransferencia', 'U') IS NOT NULL
             DROP TABLE #MontosTotalTransferencia;
         CREATE TABLE #MontosTotalTransferencia
         (IdFactura        INT, 
          UUID             VARCHAR(500), 
          FormaPago        NVARCHAR(50), 
          IdMonedaFactura  INT, 
          MetodoPago       NVARCHAR(50), 
          IdMonedaTransfer INT, 
          TipoCambio       FLOAT, 
          RC2209           FLOAT, 
          NoParcialidad    INT
         );

         --

         INSERT INTO #MontosTotalTransferencia
         (IdFactura, 
          UUID, 
          FormaPago, 
          IdMonedaFactura, 
          MetodoPago, 
          IdMonedaTransfer, 
          TipoCambio, 
          RC2209, 
          NoParcialidad
         )
                SELECT F.IdFactura, 
                       F.UUID, 
                       MP.C_FormaPago AS FormaPago, 
                       F.IdMoneda, 
                       #Facturas.MetodoPago AS MetodoPago, 
                       T.IdMoneda, 
                       TCD.TipoCambio, 
                       CAST(ROUND(F.MontoConIva, 2) AS DECIMAL(15, 2)) AS RC2209, 
                       0 AS NoParcialidad
                FROM dbo.FI_Transfer T WITH(NOLOCK)
                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON T.IdTransferencia = TF.IdTransfer
                     JOIN dbo.FI_Factura F WITH(NOLOCK) ON TF.IdFactura = F.IdFactura
                                                           AND T.IdContrato = F.IdContrato
                     JOIN dbo.PV_MetodoPago MP WITH(NOLOCK) ON MP.IdMetodoPago = T.IdMetodoPago
                     JOIN #Facturas ON #Facturas.IdFactura = F.IdFactura
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = T.IdMoneda
                                                                           AND T.IdMoneda <> F.IdMoneda
                                                                           AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                                           AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                                           AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
                WHERE F.IdContrato = @Contrato
                      AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
                      AND #Facturas.MetodoPago = 'PUE'
                      AND TF.CvTipoDocFacturacion = 1
                GROUP BY CAST(ROUND(F.MontoConIva, 2) AS DECIMAL(15, 2)), 
                         F.IdFactura, 
                         F.UUID, 
                         #Facturas.MetodoPago, 
                         F.IdMoneda, 
                         MP.C_FormaPago, 
                         T.IdMoneda, 
                         TCD.TipoCambio
                --
                UNION
                --
                SELECT FCPDR.IdFactura, 
                       CPDR.IdDocumento, 
                       '99' AS FormaPago, --CP.FormaDePagoP,

                       TM.IdMoneda, 
                       CPDR.MetodoDePagoDR AS MetodoPago, 
                       T.IdMoneda, 
                       MAX(TCD.TipoCambio), 
                       0, 
                       0
                FROM dbo.FI_Transfer T WITH(NOLOCK)
                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = T.IdTransferencia
                     JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura
                     JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
                     JOIN dbo.FI_Factura F WITH(NOLOCK) ON F.IdFactura = CP.IdFactura
                     JOIN FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID
                                                           AND F.IdContrato = FCPDR.IdContrato
                     JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON CPDR.MonedaDR = TM.TipoMonedaCorto
                     JOIN #Facturas ON #Facturas.IdFactura = FCPDR.IdFactura
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = T.IdMoneda
                                                                           AND T.IdMoneda <> FCPDR.IdMoneda
                                                                           AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                                           AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                                           AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
                WHERE F.IdContrato = @Contrato
                      AND ISNULL(CONVERT(INT, FCPDR.ProcesadoSIPAC), 0) = 0
                      AND #Facturas.MetodoPago = 'PPD'
                      AND TF.CvTipoDocFacturacion = 6
                GROUP BY FCPDR.IdFactura, 
                         CPDR.IdDocumento,

                         --CP.FormaDePagoP,

                         TM.IdMoneda, 
                         CPDR.MetodoDePagoDR, 
                         T.IdMoneda;

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

         /*Consulta final quue llena la hoja 22 de la plantilla*/

         SELECT LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00], 
                LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00], 
                C.NumeroContrato AS [RF01_01], 
                MONTH(R.MesPresentacion) AS [RC21_01], 
                YEAR(R.MesPresentacion) AS [RC21_02], 
                REPLACE(F.ArchivoXML, '-', '_') AS [RC22_02], 
                AF.HashSHA256 AS [RC22_03], 
                F.UUID AS [RC22_04], 
                #Facturas.TipoComprobante AS [RC22_05], 
                MTT.MetodoPago AS [RC22_06], 
                CAST(ROUND(F.MontoConIva, 2) AS DECIMAL(15, 2)) AS [RC22_07], 
                CAST(ROUND(ISNULL(F.SubTotal, 0) - (ISNULL(F.Descuento, 0) + ISNULL(F.TotalImpuestosRetenidos, 0)), 2) AS DECIMAL(15, 2)) AS [RC22_08], 
                MTT.RC2209 AS [RC22_09], 
                MTT.NoParcialidad AS [RC22_10], 
                MTT.FormaPago AS [RC22_11], 
                CAST(F.Fecha AS DATE) AS [RC22_12], 
                SUBSTRING(LTRIM(RTRIM((F.Emisor))), 0, 13) AS [RC22_13], 
                SUBSTRING(LTRIM(RTRIM(ISNULL(F.LugarExpedicion, ''))), 0, 30) AS [RC22_14], 
                LTRIM(RTRIM(F.Receptor)) AS [RC22_15], 
                TM.TipoMonedaCorto AS [RC22_16], 
                2 AS [RC22_17]
         FROM dbo.FI_Factura F WITH(NOLOCK)
              JOIN #MontosTotalTransferencia MTT ON MTT.IdFactura = F.IdFactura
              JOIN dbo.CO_Registro R WITH(NOLOCK) ON R.IdFactura = F.IdFactura
              JOIN #Facturas ON #Facturas.IdFactura = R.IdFactura AND #Facturas.TipoComprobante NOT IN ('E')
              JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
              JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
              JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
              JOIN dbo.CO_Contrato C WITH(NOLOCK) ON AC.IdContrato = C.IdContrato
              JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista
              JOIN dbo.CO_Servicio SER WITH(NOLOCK) ON SER.IdServicio = LPM.IdServicio
                                                       AND SER.IdContrato = C.IdContrato
              LEFT JOIN dbo.FI_ArchivoXml AF WITH(NOLOCK) ON F.IdFactura = AF.IdFactura
              LEFT JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON F.IdMoneda = TM.IdMoneda
         WHERE C.IdContrato = @Contrato
               AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
               AND R.IdEstado = 10004
               AND R.CvTipoDocFacturacion = 1
               AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
               AND SER.NombreServicio NOT LIKE '%No elegibles%'
               AND F.UUID NOT IN
         (
             SELECT RPT.UUID
             FROM #uuidNoReportar RPT
         )
               AND F.UUID NOT IN
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
         GROUP BY LTRIM(RTRIM(CON.IDSIPAC)), 
                  LTRIM(RTRIM(C.IDRegFiducidiario)), 
                  C.NumeroContrato, 
                  MONTH(R.MesPresentacion), 
                  YEAR(R.MesPresentacion), 
                  REPLACE(F.ArchivoXML, '-', '_'), 
                  AF.HashSHA256, 
                  F.UUID, 
                  #Facturas.TipoComprobante, 
                  MTT.MetodoPago, 
                  CAST(ROUND(F.MontoConIva, 2) AS DECIMAL(15, 2)), 
                  CAST(ROUND(ISNULL(F.SubTotal, 0) - (ISNULL(F.Descuento, 0) + ISNULL(F.TotalImpuestosRetenidos, 0)), 2) AS DECIMAL(15, 2)), 
                  MTT.RC2209, 
                  MTT.NoParcialidad, 
                  MTT.FormaPago, 
                  CAST(F.Fecha AS DATE), 
                  SUBSTRING(LTRIM(RTRIM((F.Emisor))), 0, 13), 
                  SUBSTRING(LTRIM(RTRIM(ISNULL(F.LugarExpedicion, ''))), 0, 30), 
                  LTRIM(RTRIM(F.Receptor)), 
                  TM.TipoMonedaCorto
         --
         UNION
         --
         SELECT LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00], 
                LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00], 
                C.NumeroContrato AS [RF01_01], 
                MONTH(R.MesPresentacion) AS [RC21_01], 
                YEAR(R.MesPresentacion) AS [RC21_02], 
                REPLACE(FCP.ArchivoXML, '-', '_') AS [RC22_02], 
                AF.HashSHA256 AS [RC22_03], 
                FCP.UUID AS [RC22_04], 
                'P' [RC22_05], 
                'PPD' AS [RC22_06], 
                MAX(CP.Monto) AS [RC22_07], 
                MAX(CP.Monto) AS [RC22_08], 
                MAX(CP.Monto) AS [RC22_09], 
                MAX(CPDR.NumParcialidad) AS [RC22_10], 
                CP.FormaDePagoP AS [RC22_11], --'03'

                CAST(FCP.Fecha AS DATE) AS [RC22_12], 
                SUBSTRING(LTRIM(RTRIM((FCP.Emisor))), 0, 13) AS [RC22_13], 
                SUBSTRING(LTRIM(RTRIM(ISNULL(FCP.LugarExpedicion, ''))), 0, 30) AS [RC22_14], 
                LTRIM(RTRIM(FCP.Receptor)) AS [RC22_15], 
                CP.MonedaP AS [RC22_16], 
                2 AS [RC22_17]
         FROM dbo.FI_Transfer TR WITH(NOLOCK)
              JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TR.IdTransferencia = TF.IdTransfer
              JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura
              JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
              JOIN dbo.FI_Factura FCP WITH(NOLOCK) ON TF.IdFactura = FCP.IdFactura
              JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID
              JOIN dbo.CO_Registro R WITH(NOLOCK) ON R.IdFactura = FCPDR.IdFactura
              JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
              JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
              JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
              JOIN dbo.CO_Contrato C WITH(NOLOCK) ON AC.IdContrato = C.IdContrato
              JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista
              JOIN dbo.CO_Servicio SER WITH(NOLOCK) ON SER.IdServicio = LPM.IdServicio
                                                       AND SER.IdContrato = C.IdContrato
              LEFT JOIN dbo.FI_ArchivoXml AF WITH(NOLOCK) ON FCP.IdFactura = AF.IdFactura
              LEFT JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON FCP.IdMoneda = TM.IdMoneda
         WHERE C.IdContrato = @Contrato
               AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
               AND R.IdEstado = 10004
               AND R.CvTipoDocFacturacion = 1
               AND ISNULL(CONVERT(INT, FCP.ProcesadoSIPAC), 0) = 0
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
         GROUP BY LTRIM(RTRIM(CON.IDSIPAC)), 
                  LTRIM(RTRIM(C.IDRegFiducidiario)), 
                  C.NumeroContrato, 
                  MONTH(R.MesPresentacion), 
                  YEAR(R.MesPresentacion), 
                  REPLACE(FCP.ArchivoXML, '-', '_'), 
                  AF.HashSHA256, 
                  FCP.UUID, 
                  CP.FormaDePagoP, 
                  CAST(FCP.Fecha AS DATE), 
                  SUBSTRING(LTRIM(RTRIM((FCP.Emisor))), 0, 13), 
                  SUBSTRING(LTRIM(RTRIM(ISNULL(FCP.LugarExpedicion, ''))), 0, 30), 
                  LTRIM(RTRIM(FCP.Receptor)), 
                  CP.MonedaP;
     END;