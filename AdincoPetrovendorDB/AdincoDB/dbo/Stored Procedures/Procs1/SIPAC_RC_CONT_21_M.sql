USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SIPAC_RC_CONT_21_M]    Script Date: 28/03/2022 12:53:29 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================= 
-- Author: Manuel Cruz-Yazmin Glez. 
-- Create date: 2017-11-24 
-- Description: Reporte de CGI - Registro de costos. Plantilla antes RC_CONT_01_M actual RC_CONT_21_M 
-- Modificado: Manuel Cruz 
-- Fecha Modificado: 2019-06-28 
-- Description: Cambio de consulta para mostrar los complementos de pago relacionadolos al gasto 
-- ============================================= 
-- Modificado:       Marcos Garcia 
-- Fecha Modificado: 2020-01-13 
-- Description:     *Agregar Validacion de @IdPresupuesto = 0 
--                  *Agregar WITH (NOLOCK) en las tablas  
-- ============================================= 
-- Modificado:       Manuel Cruz
-- Fecha Modificado: 2022-03-28
-- Description:      Se ajusta tipo de cambio RC_21_25 a 4 decimales
-- =============================================
ALTER PROCEDURE [dbo].[SIPAC_RC_CONT_21_M] 

-- [SIPAC_RC_CONT_21_M] 10011,'2019-04-01',1 

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

         EXEC [SIPAC_RC_CONT_24_M_IdDoc]  

              @Contrato,  

              @Mes,  

              @IdPresupuesto; 

         EXEC [SIPAC_RC_CONT_25_M_IdDoc]  

              @Contrato,  

              @Mes,  

              @IdPresupuesto; 

  

         /*Calcular montos pagados*/ 

  

         IF OBJECT_ID('tempdb..#Facturas', 'U') IS NOT NULL 

             DROP TABLE #Facturas; 

         IF OBJECT_ID('tempdb..#MontosTotalTransferenciaPPD', 'U') IS NOT NULL 

             DROP TABLE #MontosTotalTransferenciaPPD; 

         IF OBJECT_ID('tempdb..#MontosTotalTransferenciaPUE', 'U') IS NOT NULL 

             DROP TABLE #MontosTotalTransferenciaPUE; 

         IF OBJECT_ID('tempdb..#MontosConvertidosPedimentosCom', 'U') IS NOT NULL 

             DROP TABLE #MontosConvertidosPedimentosCom; 

         IF OBJECT_ID('tempdb..#uuidNoReportar', 'U') IS NOT NULL 

             DROP TABLE #uuidNoReportar; 

  

         /*Omitir facturas en la hoja 21*/ 

  

         CREATE TABLE #uuidNoReportar 

         (UUID VARCHAR(500) 

         ); 

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

  

         /**/ 

  

         CREATE TABLE #Facturas 

         (IdRegistro      INT,  

          UUID            NVARCHAR(500),  

          Idfactura       INT,  

          MontoRegistro   FLOAT,  

          TipoComprobante NVARCHAR(50),  

          RC2122          FLOAT,  

          MetodoPago      NVARCHAR(50),  

          Fecha           DATETIME,  

          IdMoneda        INT 

         ); 

         -- 

         INSERT INTO #Facturas 

         (IdRegistro,  

          UUID,  

          Idfactura,  

          MontoRegistro,  

          TipoComprobante,  

          RC2122,  

          MetodoPago,  

          Fecha,  

          IdMoneda 

         ) 

                SELECT R.IdRegistro,  

                       ISNULL(F.UUID, 'NÚMERO NO REGISTRADO') AS UUID,  

                       F.IdFactura,  

                       R.MontoRegistro, 

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

                       SUM(CASE 

                               WHEN ISNULL(R.MontoRegistro, 0) <> 0 

                               THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2)) 

                               ELSE 0 

                           END) AS [RC21_22], 

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

                       END AS MetodoPago,  

                       F.Fecha,  

                       F.IdMoneda 

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

                GROUP BY R.IdRegistro,  

                         ISNULL(F.UUID, 'NÚMERO NO REGISTRADO'),  

                         F.IdFactura,  

                         R.MontoRegistro, 

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

                         F.Fecha,  

                         F.IdMoneda; 

  

         /*Facturas Con Tipo de Cambio de Transferencia*/ 

  

         CREATE TABLE #MontosTotalTransferenciaPPD 

         (IdFacturaCP     INT,  

          UUIDCP          VARCHAR(500),  

          FormaPagoCP     VARCHAR(50),  

          MontoCP         FLOAT,  

          TipoCambioCP    FLOAT,  

          MonedaCP        VARCHAR(50),  

          MontoPesos      FLOAT,  

          MontoDolares    FLOAT,  

          TipoComprobante VARCHAR(50),  

          MontoRegistro   FLOAT,  

          IdRegistro      INT 

         ); 

         -- 

         INSERT INTO #MontosTotalTransferenciaPPD 

         (IdFacturaCP,  

          UUIDCP,  

          FormaPagoCP,  

          MontoCP,  

          TipoCambioCP,  

          MonedaCP,  

          MontoPesos,  

          MontoDolares,  

          TipoComprobante,  

          MontoRegistro,  

          IdRegistro 

         ) 

                SELECT F.IdFactura AS IdFacturaCP,  

                       F.UUID AS UUIDCP,  

                       CP.FormaDePagoP AS FormaPagoCP,  

                       SUM(CPDR.ImpPagado) AS MontoCP,  

                       TCD.TipoCambio AS TipoCambioCP,  

                       CP.MonedaP AS MonedaCP,  

                       CAST(SUM(CPDR.ImpPagado) AS DECIMAL(15, 2)) AS MontoPesos,  

                       CAST(SUM(CASE 

                                    WHEN TM.IdMoneda = 1 

                             THEN CPDR.ImpPagado / TCD.TipoCambio 

                                    ELSE CPDR.ImpPagado 

                                END) AS DECIMAL(15, 2)) AS MontoDolares,  

                       F.TipoComprobante,  

                       CAST(#Facturas.MontoRegistro / TCD.TipoCambio AS DECIMAL(15, 2)) AS MontoRegistro,  

                       #Facturas.IdRegistro 

                FROM dbo.FI_Transfer T WITH(NOLOCK) 

                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = T.IdTransferencia 

                     JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura 

                     JOIN dbo.FI_Factura F WITH(NOLOCK) ON CP.IdFactura = F.IdFactura 

                     JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CP.IdComplementoDePago = CPDR.IdComplementoDePago 

                     JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID 

                                                               AND F.IdContrato = FCPDR.IdContrato 

                                                               AND F.IdContrato = T.IdContrato 

                     JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON CP.MonedaP = TM.TipoMonedaCorto 

                     JOIN #Facturas ON #Facturas.Idfactura = FCPDR.IdFactura 

                     LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TM.IdMoneda 

                                                                           AND TCD.IdMoneda = FCPDR.IdMoneda 

                                                                           AND DAY(TCD.Fecha) = DAY(T.FechaPago) 

                                                                           AND MONTH(TCD.Fecha) = MONTH(T.FechaPago) 

                                                                           AND YEAR(TCD.Fecha) = YEAR(T.FechaPago) 

                WHERE #Facturas.MetodoPago = 'PPD' 

                      AND TF.CvTipoDocFacturacion = 6 

                      AND TCD.IdMoneda = FCPDR.IdMoneda 

                GROUP BY F.IdFactura,  

                         F.UUID,  

                         CP.FormaDePagoP,  

                         TCD.TipoCambio,  

                         CP.MonedaP,  

                         F.TipoComprobante,  

                         CAST(#Facturas.MontoRegistro / TCD.TipoCambio AS DECIMAL(15, 2)),  

                         #Facturas.IdRegistro 

                UNION 

                SELECT F.IdFactura AS IdFacturaCP,  

                       F.UUID AS UUIDCP,  

                       CP.FormaDePagoP AS FormaPagoCP,  

                       SUM(CPDR.ImpPagado) AS MontoCP,  

                       1 AS TipoCambioCP,  

                       CP.MonedaP AS MonedaCP,  

                       CAST((SUM(CPDR.ImpPagado * TCD.TipoCambio)) AS DECIMAL(15, 2)) AS MontoPesos,  

                       CAST((SUM(CASE 

                                     WHEN TM.IdMoneda = 2 

                                     THEN CPDR.ImpPagado / TCD.TipoCambio 

                                     ELSE CPDR.ImpPagado 

                                 END)) AS DECIMAL(15, 2)) AS MontoDolares,  

                       F.TipoComprobante,  

                       CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)) AS MontoRegistro,  

                       #Facturas.IdRegistro 

                FROM dbo.FI_Transfer T WITH(NOLOCK) 

                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = T.IdTransferencia 

                     JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura 

                     JOIN dbo.FI_Factura F WITH(NOLOCK) ON CP.IdFactura = F.IdFactura 

                     JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CP.IdComplementoDePago = CPDR.IdComplementoDePago 

                     JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID 

                                                               AND F.IdContrato = FCPDR.IdContrato 

                                                               AND F.IdContrato = T.IdContrato 

                     JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON CP.MonedaP = TM.TipoMonedaCorto 

                     JOIN #Facturas ON #Facturas.Idfactura = FCPDR.IdFactura 

                     LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TM.IdMoneda 

                                                                           AND TCD.IdMoneda <> FCPDR.IdMoneda 

                                                                           AND DAY(TCD.Fecha) = DAY(T.FechaPago) 

                                                                           AND MONTH(TCD.Fecha) = MONTH(T.FechaPago) 

                                                                           AND YEAR(TCD.Fecha) = YEAR(T.FechaPago) 

                WHERE #Facturas.MetodoPago = 'PPD' 

                      AND TF.CvTipoDocFacturacion = 6 

       AND T.IdMoneda <> TM.IdMoneda 

                      AND TM.IdMoneda = FCPDR.IdMoneda 

                GROUP BY F.IdFactura,  

                         F.UUID,  

                         CP.FormaDePagoP,  

                         CP.MonedaP,  

                         F.TipoComprobante,  

                         CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)),  

                         #Facturas.IdRegistro 

    --Respaldo consulta anterior 

                /*SELECT F.IdFactura AS IdFacturaCP,  

                       F.UUID AS UUIDCP,  

                       CP.FormaDePagoP AS FormaPagoCP,  

                       SUM(CPDR.ImpPagado) AS MontoCP,  

                       1 AS TipoCambioCP,  

                       CP.MonedaP AS MonedaCP,  

                       CAST((SUM(CPDR.ImpPagado * TCD.TipoCambio)) AS DECIMAL(15, 2)) AS MontoPesos,  

                       CAST((SUM(CASE 

                                     WHEN TM.IdMoneda = 2 

                                     THEN CPDR.ImpPagado / TCD.TipoCambio 

                                     ELSE CPDR.ImpPagado 

                                 END)) AS DECIMAL(15, 2)) AS MontoDolares,  

                       F.TipoComprobante,  

                       CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)) AS MontoRegistro,  

                       #Facturas.IdRegistro 

                FROM dbo.FI_Transfer T WITH(NOLOCK) 

                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = T.IdTransferencia 

                     JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura 

                     JOIN dbo.FI_Factura F WITH(NOLOCK) ON CP.IdFactura = F.IdFactura 

                     JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CP.IdComplementoDePago = CPDR.IdComplementoDePago 

                     JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID 

                                                               AND F.IdContrato = FCPDR.IdContrato 

                                                               AND F.IdContrato = T.IdContrato 

                     JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON CP.MonedaP = TM.TipoMonedaCorto 

                     JOIN #Facturas ON #Facturas.Idfactura = FCPDR.IdFactura 

                     LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TM.IdMoneda 

                                                                           AND TCD.IdMoneda <> FCPDR.IdMoneda 

                                                                           AND DAY(TCD.Fecha) = DAY(T.FechaPago) 

                                                                           AND MONTH(TCD.Fecha) = MONTH(T.FechaPago) 

                                                              AND YEAR(TCD.Fecha) = YEAR(T.FechaPago) 

                WHERE #Facturas.MetodoPago = 'PPD' 

                      AND TF.CvTipoDocFacturacion = 6 

                      AND TCD.IdMoneda <> FCPDR.IdMoneda 

                GROUP BY F.IdFactura,  

                         F.UUID,  

                         CP.FormaDePagoP,  

                         CP.MonedaP,  

                         F.TipoComprobante,  

                         CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)),  

                         #Facturas.IdRegistro*/ 

    UNION 

    --Se agrego para los casos donde el complemento es igual a la moneda de la transferencia (USD = USD) 

    --y la factura ppd es igual a la moneada del documento relacionado (MXN = MXN) 

    SELECT F.IdFactura AS IdFacturaCP,  

      F.UUID AS UUIDCP,  

      CP.FormaDePagoP AS FormaPagoCP,  

      SUM(CPDR.ImpPagado) AS MontoCP,  

      1, --TCD.TipoCambio AS TipoCambioCP,  

      CP.MonedaP AS MonedaCP,  

      CAST((SUM(CASE  

          WHEN TM.IdMoneda = 2 

           AND FCPDR.IdMoneda = 1  

          THEN CPDR.ImpPagado * 1 --TCD.TipoCambio 

          END)) AS DECIMAL(15, 2)) AS MontoPesos,  

      CAST((SUM(CASE 

          WHEN TM.IdMoneda = 2 

           AND FCPDR.IdMoneda = 1 

          THEN CPDR.ImpPagado / TCD.TipoCambio 

          ELSE CPDR.ImpPagado 

         END)) AS DECIMAL(15, 2)) AS MontoDolares,  

      F.TipoComprobante,  

      CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)) AS MontoRegistro,  

      #Facturas.IdRegistro 

    FROM dbo.FI_Transfer T WITH(NOLOCK) 

      JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = T.IdTransferencia 

      JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura 

      JOIN dbo.FI_Factura F WITH(NOLOCK) ON CP.IdFactura = F.IdFactura 

      JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CP.IdComplementoDePago = CPDR.IdComplementoDePago 

      JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID 

                AND F.IdContrato = FCPDR.IdContrato 

                AND F.IdContrato = T.IdContrato 

      JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON CP.MonedaP = TM.TipoMonedaCorto 

      JOIN #Facturas ON #Facturas.Idfactura = FCPDR.IdFactura 

      LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda <> TM.IdMoneda 

                   AND TCD.IdMoneda = FCPDR.IdMoneda 

                   AND DAY(TCD.Fecha) = DAY(T.FechaPago) 

                   AND MONTH(TCD.Fecha) = MONTH(T.FechaPago) 

                   AND YEAR(TCD.Fecha) = YEAR(T.FechaPago) 

    WHERE #Facturas.MetodoPago = 'PPD' 

      AND TF.CvTipoDocFacturacion = 6 

      AND T.IdMoneda = TM.IdMoneda 

      AND TM.IdMoneda <> FCPDR.IdMoneda 

    GROUP BY F.IdFactura,  

       F.UUID,  

       CP.FormaDePagoP,  

       --TCD.TipoCambio, 

       CP.MonedaP,  

       F.TipoComprobante,  

       CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)),  

       #Facturas.IdRegistro; 

         -- 

         SELECT Con.UUID,  

                Con.Idfactura,  

                Con.TipoComprobante,  

                SUM(Con.MontoDolares) AS MontoDolares,  

                Con.MetodoPago,  

                MAX(Con.TipoCambio) AS TipoCambio,  

                MAX(Con.Fecha) AS Fecha,  

                Con.IdMoneda 

         INTO #SumaDePagosDolares 

         FROM 

         ( 

             SELECT DISTINCT  

                    MCF.UUID,  

                    MCF.Idfactura,  

                    MCF.TipoComprobante, 

                    CASE 

                        WHEN ISNULL(TF.MontoPagado, 0) <> 0 

                        THEN CAST(ROUND((ISNULL(TF.MontoPagado, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2)) 

                        ELSE 0 

                    END AS MontoDolares,  

                    MCF.MetodoPago,  

                    TCD.TipoCambio AS TipoCambio,  

                    TCD.Fecha,  

                    MCF.IdMoneda,  

                    T.IdMoneda AS MonedaTran,  

                    T.IdTransferencia 

             FROM dbo.FI_Transfer T WITH(NOLOCK) 

                  JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON T.IdTransferencia = TF.IdTransfer 

                  JOIN #Facturas MCF ON TF.IdFactura = MCF.Idfactura 

                  LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = MCF.IdMoneda 

                                                                        AND TCD.IdMoneda = T.IdMoneda 

                                                                        AND DAY(TCD.Fecha) = DAY(T.FechaPago) 

                                                                        AND MONTH(TCD.Fecha) = MONTH(T.FechaPago) 

                                                                        AND YEAR(TCD.Fecha) = YEAR(T.FechaPago) 

             WHERE MCF.MetodoPago = 'PUE' 

                   AND TCD.IdMoneda = MCF.IdMoneda 

             -- 

             UNION 

             -- 

             SELECT DISTINCT  

					MCF.UUID,  

                    MCF.Idfactura,  

                    MCF.TipoComprobante, 

                    CASE 

                        WHEN T.IdMoneda = 1 

                             AND F.IdMoneda = 2 

                        THEN CAST(ROUND((ISNULL(TF.MontoPagado, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2)) 

                        WHEN T.IdMoneda = 2 

                             AND F.IdMoneda = 1 

                        THEN TF.MontoPagado 

                    END AS MontoDolares,  

                    MCF.MetodoPago, 

                    CASE 

                        WHEN T.IdMoneda = 1 

                             AND F.IdMoneda = 2 

                        THEN 1 

                        WHEN T.IdMoneda = 2 

                             AND F.IdMoneda = 1 

                        THEN TCD.TipoCambio 

                    END AS TipoCambio,  

                    TCD.Fecha,  

                    MCF.IdMoneda,  

                    T.IdMoneda AS MonedaTran,  

                    T.IdTransferencia 

             FROM dbo.FI_Transfer T WITH(NOLOCK) 

                  JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON T.IdTransferencia = TF.IdTransfer 

                  JOIN #Facturas MCF ON TF.IdFactura = MCF.Idfactura 

                  JOIN dbo.FI_Factura F WITH(NOLOCK) ON MCF.Idfactura = F.IdFactura 

                  LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = T.IdMoneda 

                                                                        AND TCD.IdMoneda <> F.IdMoneda 

                                                                        AND DAY(TCD.Fecha) = DAY(T.FechaPago) 

                                                                        AND MONTH(TCD.Fecha) = MONTH(T.FechaPago) 

                                                                        AND YEAR(TCD.Fecha) = YEAR(T.FechaPago) 

             WHERE MCF.MetodoPago = 'PUE' 

                   AND TCD.IdMoneda <> F.IdMoneda 

         ) AS Con 

         GROUP BY Con.UUID,  

                  Con.Idfactura,  

                  Con.TipoComprobante,  

                  Con.MetodoPago,  

                  Con.IdMoneda; 

         -- 

         CREATE TABLE #MontosTotalTransferenciaPUE 

         (IdRegistro      INT,  

          UUID            NVARCHAR(500),  

          Idfactura       INT,  

          MontoRegistro   FLOAT,  

          TipoComprobante NVARCHAR(50),  

          RC2122          FLOAT,  

          MetodoPago      NVARCHAR(50),  

          TCD             FLOAT,  

          FechaTCD       DATE,  

          IdMoneda        INT 

         ); 

         -- 

         INSERT INTO #MontosTotalTransferenciaPUE 

         (IdRegistro,  

          UUID,  

          Idfactura,  

          MontoRegistro,  

          TipoComprobante,  

          RC2122,  

          MetodoPago,  

          TCD,  

          FechaTCD,  

          IdMoneda 

         ) 

                SELECT DISTINCT  

                       MCF.IdRegistro,  

                       MCF.UUID,  

                       MCF.Idfactura,  

                       MCF.MontoRegistro,  

                       MCF.TipoComprobante,  

                       SPD.MontoDolares,  

                       MCF.MetodoPago,  

                       SPD.TipoCambio,  

                       SPD.Fecha,  

                       MCF.IdMoneda 

                --SELECT *  

                FROM #Facturas MCF 

                     JOIN #SumaDePagosDolares SPD ON MCF.Idfactura = SPD.Idfactura 

                WHERE MCF.MetodoPago = 'PUE'; 

  

         /*PEDIMENTO COMPROBANTE*/ 

  

         CREATE TABLE #MontosConvertidosPedimentosCom 

         (IdRegistro             INT,  

          IdPedimentoComprobante INT,  

          MontoRegistro          FLOAT,  

          RC2122                 FLOAT,  

          TCD                    FLOAT 

         ); 

         -- 

         INSERT INTO #MontosConvertidosPedimentosCom 

         (IdRegistro,  

          IdPedimentoComprobante,  

          MontoRegistro,  

          RC2122,  

          TCD 

         ) 

                SELECT R.IdRegistro,  

                       P.IdPedimentoComprobante,  

                       R.MontoRegistro,  

                       SUM(CASE 

                               WHEN ISNULL(R.MontoRegistro, 0) <> 0 

                               THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCDP.TipoCambio), 2) AS DECIMAL(15, 2)) 

                               ELSE 0 

                           END) AS [RC21_22],  

                       TCDP.TipoCambio 

                FROM dbo.CO_Registro R WITH(NOLOCK) 

                     JOIN dbo.FI_PedimentoComprobante P WITH(NOLOCK) ON P.IdPedimentoComprobante = R.IdPedimentoComprobante 

                     JOIN dbo.CO_Contrato C WITH(NOLOCK) ON C.IdContrato = P.IdContrato 

                     JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes 

                     JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = LPM.IdServicio 

                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdPedimentoComprobante = P.IdPedimentoComprobante 

                     JOIN dbo.FI_Transfer T WITH(NOLOCK) ON T.IdTransferencia = TF.IdTransfer 

                     LEFT JOIN dbo.CO_TipoCambioDiario TCDP WITH(NOLOCK) ON TCDP.IdMoneda = P.IdMoneda 

                                                                            AND DAY(TCDP.Fecha) = DAY(T.FechaPago) 

                                                                            AND MONTH(TCDP.Fecha) = MONTH(T.FechaPago) 

                                                                            AND YEAR(TCDP.Fecha) = YEAR(T.FechaPago) 

                WHERE C.IdContrato = @Contrato 

                      AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes 

                      AND R.IdEstado = 10004 

                      AND R.CvTipoDocFacturacion IN(2, 3) 

                     AND ISNULL(CONVERT(INT, P.ProcesadoSIPAC), 0) = 0 

                     AND S.NombreServicio NOT LIKE '%No elegibles%' 

                     AND LPM.IdPresupuesto = CASE 

                                                 WHEN @IdPresupuesto = 0 

                                                 THEN LPM.IdPresupuesto 

           ELSE @IdPresupuesto 

                                             END 

                GROUP BY R.IdRegistro,  

                         P.IdPedimentoComprobante,  

                         R.MontoRegistro,  

                         TCDP.TipoCambio; 

  

         /*Determinar si tiene gastos o no en el mes seleccionado. Si no tiene devuelve el registro para reportar en 0*/ 

  

         DECLARE @GastosConFacturaPPD INT, @GastosConFacturaPUE INT, @GastosConPedCom INT; 

         -- 

         SELECT @GastosConFacturaPPD = COUNT(IdRegistro) 

         FROM #MontosTotalTransferenciaPPD; 

         -- 

         SELECT @GastosConFacturaPUE = COUNT(IdRegistro) 

         FROM #MontosTotalTransferenciaPUE; 

         -- 

         SELECT @GastosConPedCom = COUNT(IdRegistro) 

         FROM #MontosConvertidosPedimentosCom; 

         -- 

         --SELECT @GastosConFactura, @GastosConPedCom; 

         -- 

         IF(@GastosConFacturaPPD = 0 

            AND @GastosConFacturaPUE = 0 

            AND @GastosConPedCom = 0) 

             BEGIN 

                 SELECT DISTINCT  

                        LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00],  

                        LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00],  

                        LTRIM(RTRIM(C.NumeroContrato)) AS [RF01_01],  

                        SUBSTRING(P.IdPresupuestoCNH, 22, 10) AS [RC21_00],  

                        MONTH(@Mes) AS [RC21_01],  

                        YEAR(@Mes) AS [RC21_02],  

                        1 AS [RC21_03],  

                        NULL AS [RC21_04],  

                        NULL AS [RC21_05],  

                        NULL AS [RC21_06],  

                        NULL AS [RC21_07],  

                        NULL AS [RC21_08],  

                        NULL AS [RC21_09],  

                        NULL AS [RC21_10],  

                        NULL AS [RC21_11],  

                        NULL AS [RC21_12],  

                        NULL AS [RC21_13],  

                        NULL AS [RC21_14],  

                        NULL AS [RC21_15],  

                        NULL AS [RC21_16],  

                        NULL AS [RC21_17],  

                        NULL AS [RC21_18],  

                        NULL AS [RC21_19],  

                        NULL AS [RC21_20],  

                        NULL AS [RC21_21],  

                        0 AS [RC21_22],  

                        0 AS [RC21_23],  

                        NULL AS [RC21_24],  

                        NULL AS [RC21_25],  

                        NULL AS [RC21_26] 

                 FROM dbo.CO_Contrato C WITH(NOLOCK) 

                      JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON CON.IdContratista = C.IdContratista 

                      JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdContrato = C.IdContrato 

                      JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdAnioContractual = AC.IdAnioContractual 

                 WHERE C.IdContrato = @Contrato 

                       AND SUBSTRING(ISNULL(P.IdPresupuestoCNH, ''), 22, 10) <> '' 

                       AND P.IdPresupuesto = CASE 

                                                 WHEN @IdPresupuesto = 0 

                                                 THEN P.IdPresupuesto 

                                                 ELSE @IdPresupuesto 

                                             END;  

             END; 

             ELSE 

             BEGIN 

                 SELECT [RF_00],  

                        [RI_00],  

                        [RF01_01],  

                        [RC21_00],  

                        [RC21_01],  

                        [RC21_02],  

                        ROW_NUMBER() OVER(ORDER BY [RC21_11] ASC) AS [RC21_03],  

                        [RC21_04],  

              [RC21_05],  

                        [RC21_06],  

                        [RC21_07],  

                        [RC21_08],  

                        [RC21_09],  

                        [RC21_10],  

                        [RC21_11],  

                        [RC21_12],  

                        [RC21_13],  

                        [RC21_14],  

                        [RC21_15],  

                        [RC21_16],  

                        [RC21_17],  

                        [RC21_18],  

                        [RC21_19],  

                        [RC21_20],  

                        [RC21_21],  

                        [RC21_22],  

                        [RC21_23],  

                        [RC21_24],  

                        [RC21_25],  

                        [RC21_26] 

                 FROM 

                 ( 

                     SELECT LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00],  

                            LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00],  

                            C.NumeroContrato AS [RF01_01],  

                            SUBSTRING(P.IdPresupuestoCNH, 22, 10) AS [RC21_00],  

                            MONTH(R.MesPresentacion) AS [RC21_01],  

                            YEAR(R.MesPresentacion) AS [RC21_02],  

                            NULL AS [RC21_03],  

                            SUBSTRING(F.IdDocFacturacionSIPAC, 1, 2) AS [RC21_04], 

                            CASE 

                                WHEN R.CvTipoDocFacturacion = 1 

                                THEN ISNULL(F.UUID, 'NÚMERO NO REGISTRADO') 

                                ELSE 'NA' 

                            END AS [RC21_05],  

                            'NA' AS [RC21_06],  

                            'NA' AS [RC21_07],  

                            TTF.TipoComprobante AS [RC21_08],  

                            TTF.MetodoPago AS [RC21_09],  

                            LTRIM(RTRIM(APCNH.id_Actividad)) AS [RC21_10],  

                            LTRIM(RTRIM(SP.[id_Sub-actividad])) AS [RC21_11],  

                            LTRIM(RTRIM(TP.id_Tarea)) AS [RC21_12], 

                            CASE 

                                WHEN R.CostosAtribuiblesAdministracion = 1 

                                THEN 1 

                                ELSE 0 

                            END AS [RC21_13], 

                            CASE 

                                WHEN R.CostosAtribuiblesAdministracion = 1 

                                THEN 'NA' 

                                ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-'))) 

                            END AS [RC21_14], 

                            CASE 

                                WHEN R.CostosAtribuiblesAdministracion = 1 

                                THEN 'NA' 

                                ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-'))) 

                            END AS [RC21_15], 

                            CASE 

                                WHEN R.CostosAtribuiblesAdministracion = 1 

                                THEN 'NA' 

                                ELSE LTRIM(RTRIM(I.NombreInstalacion)) 

                            END AS [RC21_16],  

                            CC.Nivel3 AS [RC21_17],  

                            CC.Descripcion AS [RC21_18],  

                            R.Poliza AS [RC21_19],  

                            SUBSTRING(R.Comentarios, 0, 299) AS [RC21_20], 

                            case when r.CapexOpexEdicion is not null then 
							   case when r.CapexOpexEdicion = 1 then 1 
								else 2 end 
							else 
								case when CC.Operacion = 1 then 1 else 2 end end  AS [RC21_21],  

                            SUM(CASE 

                                    WHEN ISNULL(TTF.MontoRegistro, 0) <> 0 

                                      AND TTF.TipoComprobante IN('I', 'N', 'P') --TTF.RC2122-- 

                                    THEN CAST((TTF.MontoRegistro / TTF.TCD) * (TTF.RC2122 / (F.MontoConIva / TTF.TCD)) AS DECIMAL(15, 2)) 

                                    ELSE 0 

                                END) AS [RC21_22],  

                            SUM(ABS(CASE 

                                        WHEN ISNULL(TTF.MontoRegistro, 0) <> 0 

                                             AND TTF.TipoComprobante IN('E') 

                                        THEN CAST((TTF.MontoRegistro / TTF.TCD) * (TTF.RC2122 / (F.MontoConIva / TTF.TCD)) AS DECIMAL(15, 2))--TTF.RC2122 

                                        ELSE 0 

                                    END)) AS [RC21_23],  

                            TM.TipoMonedaCorto AS [RC21_24],  

                            CAST(TTF.TCD AS DECIMAL(15,4)) AS [RC21_25], 

                            CASE 

                                WHEN ISNULL(RE.IdRelacionada, 2) <> 2 

                                THEN 1 

                                ELSE 2 

                            END AS [RC21_26] 

                     FROM dbo.CO_Registro R WITH(NOLOCK) 

                          JOIN dbo.FI_Factura F WITH(NOLOCK) ON R.IdFactura = F.IdFactura 

                          JOIN #MontosTotalTransferenciaPUE TTF ON TTF.Idfactura = R.IdFactura 

                                                                   AND TTF.IdRegistro = R.IdRegistro 

                          JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes 

                          JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto 

                          JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual 

                          JOIN dbo.CO_Contrato C WITH(NOLOCK) ON AC.IdContrato = C.IdContrato 

                          JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista 

                          JOIN dbo.CO_ActividadPetroleraCNH APCNH WITH(NOLOCK) ON LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera 

                          JOIN dbo.CO_SubactividadPetrolera SP WITH(NOLOCK) ON LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera 

                          JOIN dbo.CO_TareaPetrolera TP WITH(NOLOCK) ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera 

                          JOIN dbo.CO_Instalacion I WITH(NOLOCK) ON R.IdInstalacion = I.IdInstalacion 

                          JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = LPM.IdServicio 

                                                                 AND C.IdContrato = S.IdContrato 

                          LEFT JOIN dbo.PD_Campo CPO WITH(NOLOCK) ON I.IdCampo = CPO.IdCampo 

                          LEFT JOIN dbo.CO_Yacimiento Y WITH(NOLOCK) ON CPO.IdYacimiento = Y.IdYacimiento 

                          LEFT JOIN dbo.CO_CatalogoCuentaSH CC WITH(NOLOCK) ON CC.IdCatalogoCuentasSH = R.IdCatalogoCuentasSH 

                          LEFT JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON F.IdMoneda = TM.IdMoneda 

                          LEFT JOIN dbo.CO_RelacionEmpresas RE WITH(NOLOCK) ON RE.IdContratista = CON.IdContratista 

                                                                               AND F.IdSubcontratista = RE.IdRelacionada 

                     WHERE C.IdContrato = @Contrato 

                           AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes 

                           AND R.IdEstado = 10004 

                           AND R.CvTipoDocFacturacion = 1 

                           AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0 

                           AND S.NombreServicio NOT LIKE '%No elegibles%' 

                           AND TTF.MetodoPago = 'PUE' 

                      AND P.IdPresupuesto = CASE 

                                                     WHEN @IdPresupuesto = 0 

                                                     THEN LPM.IdPresupuesto 

                                                     ELSE @IdPresupuesto 

                                                 END 

                     GROUP BY LTRIM(RTRIM(CON.IDSIPAC)),  

                              LTRIM(RTRIM(C.IDRegFiducidiario)),  

                              C.NumeroContrato,  

                              SUBSTRING(P.IdPresupuestoCNH, 22, 10),  

                              MONTH(R.MesPresentacion),  

                              YEAR(R.MesPresentacion),  

                              SUBSTRING(F.IdDocFacturacionSIPAC, 1, 2), 

                              CASE 

                                  WHEN R.CvTipoDocFacturacion = 1 

                                  THEN ISNULL(F.UUID, 'NÚMERO NO REGISTRADO') 

                                  ELSE 'NA' 

                              END,  

                              LTRIM(RTRIM(APCNH.id_Actividad)),  

                              LTRIM(RTRIM(SP.[id_Sub-actividad])),  

                              LTRIM(RTRIM(TP.id_Tarea)), 

                              CASE 

                                  WHEN R.CostosAtribuiblesAdministracion = 1 

                                  THEN 1 

                                  ELSE 0 

                              END, 

                              CASE 

                                  WHEN R.CostosAtribuiblesAdministracion = 1 

                                  THEN 'NA' 

                                  ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-'))) 

                              END, 

                              CASE 

                                  WHEN R.CostosAtribuiblesAdministracion = 1 

                                  THEN 'NA' 

                                  ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-'))) 

                              END, 

                              CASE 

                                  WHEN R.CostosAtribuiblesAdministracion = 1 

									THEN 'NA' 

                                  ELSE LTRIM(RTRIM(I.NombreInstalacion)) 

                              END, 

                              case when r.CapexOpexEdicion is not null then 
								   case when r.CapexOpexEdicion = 1 then 1 
									else 2 end 
								else 
									case when CC.Operacion = 1 then 1 else 2 end end , 

                              --CASE 

                              --    WHEN ISNULL(TTF.MontoRegistro, 0) <> 0 

                              --         AND TTF.TipoComprobante IN('I', 'N', 'P') 

                              --    THEN TTF.RC2122 

                              --    ELSE 0 

                              --END, 

                              --CASE 

                              --    WHEN ISNULL(TTF.MontoRegistro, 0) <> 0 

                              --         AND TTF.TipoComprobante IN('E') 

                              --    THEN TTF.RC2122 

                              --    ELSE 0 

                              --END, 

                              CASE 

                                  WHEN ISNULL(RE.IdRelacionada, 2) <> 2 

                                  THEN 1 

                                  ELSE 2 

                              END,  

                              TTF.TipoComprobante,  

                              TTF.MetodoPago,  

                              CC.Nivel3,  

                              CC.Descripcion,  

                              R.Poliza,  

                              SUBSTRING(R.Comentarios, 0, 299),  

                              TM.TipoMonedaCorto,  

                              CAST(TTF.TCD AS DECIMAL(15,4))

                     -- 

               UNION 

                     -- 

                     SELECT LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00],  

                            LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00],  

                            C.NumeroContrato AS [RF01_01],  

                            SUBSTRING(P.IdPresupuestoCNH, 22, 10) AS [RC21_00],  

                            MONTH(R.MesPresentacion) AS [RC21_01],  

                            YEAR(R.MesPresentacion) AS [RC21_02],  

                            NULL AS [RC21_03],  

                            SUBSTRING(FCP.IdDocFacturacionSIPAC, 1, 2) AS [RC21_04], 

                            CASE 

                                WHEN R.CvTipoDocFacturacion = 1 

                                THEN ISNULL(FCP.UUID, 'NÚMERO NO REGISTRADO') 

                                ELSE 'NA' 

                            END AS [RC21_05],  

                            'NA' AS [RC21_06],  

                            'NA' AS [RC21_07],  

                            FCP.TipoComprobante AS [RC21_08],  

                            'PPD' AS [RC21_09], --TTF.MetodoPago 

                            LTRIM(RTRIM(APCNH.id_Actividad)) AS [RC21_10],  

                            LTRIM(RTRIM(SP.[id_Sub-actividad])) AS [RC21_11],  

                            LTRIM(RTRIM(TP.id_Tarea)) AS [RC21_12], 

                            CASE 

                                WHEN R.CostosAtribuiblesAdministracion = 1 

                                THEN 1  

                                ELSE 0 

                            END AS [RC21_13], 

                            CASE 

                                WHEN R.CostosAtribuiblesAdministracion = 1 

                                THEN 'NA' 

                                ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-'))) 

                            END AS [RC21_14], 

                            CASE 

                                WHEN R.CostosAtribuiblesAdministracion = 1 

                                THEN 'NA' 

                                ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-'))) 

                            END AS [RC21_15], 

                            CASE 

								WHEN R.CostosAtribuiblesAdministracion = 1 

                                THEN 'NA' 

                                ELSE LTRIM(RTRIM(I.NombreInstalacion)) 

                            END AS [RC21_16],  

                            CC.Nivel3 AS [RC21_17],  

                            CC.Descripcion AS [RC21_18],  

                            R.Poliza AS [RC21_19],  

                            SUBSTRING(R.Comentarios, 0, 299) AS [RC21_20], 

                            case when r.CapexOpexEdicion is not null then 
							   case when r.CapexOpexEdicion = 1 then 1 
								else 2 end 
							else 
								case when CC.Operacion = 1 then 1 else 2 end end  AS [RC21_21],  

                            SUM(CASE 

                                    WHEN ISNULL(TTF.MontoRegistro, 0) <> 0 

                                         AND TTF.TipoComprobante IN('I', 'N', 'P') 

                                    THEN CAST(TTF.MontoRegistro * (TTF.MontoDolares / (F.MontoConIva / TTF.TipoCambioCP)) AS DECIMAL(15, 2)) 

                                    ELSE 0 

                                END) AS [RC21_22],  

                            SUM(ABS(CASE 

                                        WHEN ISNULL(TTF.MontoRegistro, 0) <> 0 

                                             AND TTF.TipoComprobante IN('E') 

                                        THEN CAST(TTF.MontoDolares AS DECIMAL(15, 2)) 

                                        ELSE 0 

                                    END)) AS [RC21_23],  

                            CASE WHEN TTF.TipoCambioCP = 1 

							 THEN 'USD' 

							ELSE 'MXN' 

          END AS [RC21_24], --TM.TipoMonedaCorto AS [RC21_24],  

                            CAST(TTF.TipoCambioCP AS DECIMAL(15,4)) AS [RC21_25], 

                            CASE 

                                WHEN ISNULL(RE.IdRelacionada, 2) <> 2 

                                THEN 1 

                                ELSE 2 

                            END AS [RC21_26] 

                     FROM dbo.CO_Registro R WITH(NOLOCK) 

                          JOIN dbo.FI_Factura F WITH(NOLOCK) ON F.IdFactura = R.IdFactura 

                          JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON F.UUID = CPDR.IdDocumento 

                          JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CPDR.IdComplementoDePago = CP.IdComplementoDePago 

                          JOIN #MontosTotalTransferenciaPPD TTF ON CP.IdFactura = TTF.IdFacturaCP 

                                                                   AND R.IdRegistro = TTF.IdRegistro 

                          JOIN dbo.FI_Factura FCP WITH(NOLOCK) ON TTF.IdFacturaCP = FCP.IdFactura 

                          JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes 

                          JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto 

                          JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual 

                          JOIN dbo.CO_Contrato C WITH(NOLOCK) ON AC.IdContrato = C.IdContrato 

                          JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista 

                          JOIN dbo.CO_ActividadPetroleraCNH APCNH WITH(NOLOCK) ON LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera 

                          JOIN dbo.CO_SubactividadPetrolera SP WITH(NOLOCK) ON LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera 

                          JOIN dbo.CO_TareaPetrolera TP WITH(NOLOCK) ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera 

                          JOIN dbo.CO_Instalacion I WITH(NOLOCK) ON R.IdInstalacion = I.IdInstalacion 

                          JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = LPM.IdServicio 

                                                                 AND C.IdContrato = S.IdContrato 

                          LEFT JOIN dbo.PD_Campo CPO WITH(NOLOCK) ON I.IdCampo = CPO.IdCampo 

                          LEFT JOIN dbo.CO_Yacimiento Y WITH(NOLOCK) ON CPO.IdYacimiento = Y.IdYacimiento 

                          LEFT JOIN dbo.CO_CatalogoCuentaSH CC WITH(NOLOCK) ON CC.IdCatalogoCuentasSH = R.IdCatalogoCuentasSH 

                          LEFT JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON F.IdMoneda = TM.IdMoneda 

                          LEFT JOIN dbo.CO_RelacionEmpresas RE WITH(NOLOCK) ON RE.IdContratista = CON.IdContratista 

                                                                               AND F.IdSubcontratista = RE.IdRelacionada 

                     WHERE C.IdContrato = @Contrato 

                           AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes 

                           AND R.IdEstado = 10004 

                           AND R.CvTipoDocFacturacion = 1 

                           AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0 

                           AND S.NombreServicio NOT LIKE '%No elegibles%' 

                           AND FCP.UUID NOT IN 

                     ( 

                         SELECT UUID 

                         FROM #uuidNoReportar 

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

                              SUBSTRING(P.IdPresupuestoCNH, 22, 10),  

                              MONTH(R.MesPresentacion),  

                              YEAR(R.MesPresentacion),  

                              SUBSTRING(FCP.IdDocFacturacionSIPAC, 1, 2), 

                              CASE 

                                  WHEN R.CvTipoDocFacturacion = 1 

                                  THEN ISNULL(FCP.UUID, 'NÚMERO NO REGISTRADO') 

                                  ELSE 'NA' 

                              END,  

                              LTRIM(RTRIM(APCNH.id_Actividad)),  

                              LTRIM(RTRIM(SP.[id_Sub-actividad])),  

                              LTRIM(RTRIM(TP.id_Tarea)), 

                              CASE 

                                  WHEN R.CostosAtribuiblesAdministracion = 1 

                                  THEN 1 

                                  ELSE 0 

                              END, 

                              CASE 

                                  WHEN R.CostosAtribuiblesAdministracion = 1 

                                  THEN 'NA' 

                                  ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-'))) 

                              END, 

                              CASE 

                                  WHEN R.CostosAtribuiblesAdministracion = 1 

                                  THEN 'NA' 

                                  ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-'))) 

                              END, 

                              CASE 

                                  WHEN R.CostosAtribuiblesAdministracion = 1 

                                  THEN 'NA' 

                                  ELSE LTRIM(RTRIM(I.NombreInstalacion)) 

                              END, 

                              case when r.CapexOpexEdicion is not null then 
								   case when r.CapexOpexEdicion = 1 then 1 
									else 2 end 
								else 
									case when CC.Operacion = 1 then 1 else 2 end end , 

                              --CASE 

                              --    WHEN ISNULL(TTF.MontoRegistro, 0) <> 0 

                              --         AND TTF.TipoComprobante IN('I', 'N', 'P') 

                              --    THEN CAST(TTF.MontoRegistro * (TTF.MontoDolares / (F.MontoConIva / TTF.TipoCambioCP)) AS DECIMAL(15, 2)) 

                              --    ELSE 0 

                              --END, 

                              --CASE 

                              --    WHEN ISNULL(TTF.MontoRegistro, 0) <> 0 

                              --         AND TTF.TipoComprobante IN('E') 

                              --    THEN CAST(TTF.MontoDolares AS DECIMAL(15, 2)) 

                              --    ELSE 0 

                              --END, 

                              CASE 

                                  WHEN ISNULL(RE.IdRelacionada, 2) <> 2 

                                  THEN 1 

                                  ELSE 2 

                              END,  

                              FCP.TipoComprobante, 

                              --TTF.MetodoPago,  

                              CC.Nivel3,  

                              CC.Descripcion,  

                              R.Poliza,  

                              SUBSTRING(R.Comentarios, 0, 299),  

                              --TM.TipoMonedaCorto,  

                              CASE WHEN TTF.TipoCambioCP = 1 

           THEN 'USD' 

           ELSE 'MXN' 

            END, 

                              CAST(TTF.TipoCambioCP AS DECIMAL(15,4))

                     -- 

                     UNION 

                     -- 

                     SELECT LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00],  

                            LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00],  

                            C.NumeroContrato AS [RF01_01],  

                            SUBSTRING(P.IdPresupuestoCNH, 22, 10) AS [RC21_00],  

                            MONTH(R.MesPresentacion) AS [RC21_01],  

                            YEAR(R.MesPresentacion) AS [RC21_02],  

                            NULL AS [RC21_03],  

                            SUBSTRING(PC.IdDocFacturacionSIPAC, 1, 2) AS [RC21_04],  

                            'NA' AS [RC21_05], 

                            CASE 

                                WHEN R.CvTipoDocFacturacion = 1 

                                THEN 'NA' 

                                WHEN R.CvTipoDocFacturacion = 3 

                                THEN 'NA' 

                                WHEN R.CvTipoDocFacturacion = 2 

                                THEN PC.NumeroPedimento 

                            END AS [RC21_06], 

                            CASE 

                                WHEN R.CvTipoDocFacturacion = 1 

                                THEN 'NA' 

                                WHEN R.CvTipoDocFacturacion = 2 

                                THEN 'NA' 

                                WHEN R.CvTipoDocFacturacion = 3 

                                THEN PC.IdDocFacturacionSIPAC 

                            END AS [RC21_07],  

                            'NA' AS [RC21_08],  

                            'PUE' AS [RC21_09],  

                            LTRIM(RTRIM(APCNH.id_Actividad)) AS [RC21_10],  

                            LTRIM(RTRIM(SP.[id_Sub-actividad])) AS [RC21_11],  

                            LTRIM(RTRIM(TP.id_Tarea)) AS [RC21_12], 

                            CASE 

                                WHEN R.CostosAtribuiblesAdministracion = 1 

                                THEN 1 

                                ELSE 0 

                            END AS [RC21_13], 

                            CASE 

                                WHEN R.CostosAtribuiblesAdministracion = 1 

                                THEN 'NA' 

                           ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-'))) 

                            END AS [RC21_14], 

                            CASE 

                                WHEN R.CostosAtribuiblesAdministracion = 1 

                                THEN 'NA' 

                                ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-'))) 

                            END AS [RC21_15], 

                            CASE 

                                WHEN R.CostosAtribuiblesAdministracion = 1 

                                THEN 'NA' 

                                ELSE LTRIM(RTRIM(I.NombreInstalacion)) 

                            END AS [RC21_16],  

                            CC.Nivel3 AS [RC21_17],  

                            CC.Descripcion AS [RC21_18],  

                            R.Poliza AS [RC21_19],  

                            SUBSTRING(R.Comentarios, 0, 299) AS [RC21_20], 

                            case when r.CapexOpexEdicion is not null then 
							   case when r.CapexOpexEdicion = 1 then 1 
								else 2 end 
							else 
								case when CC.Operacion = 1 then 1 else 2 end end  AS [RC21_21],  

                            SUM(CASE 

                                    WHEN ISNULL(MP.MontoRegistro, 0) <> 0 

                                    THEN MP.RC2122 

                                    ELSE 0 

                                END) AS [RC21_22],  

                            0 AS [RC21_23],  

                            TM.TipoMonedaCorto AS [RC21_24],  

                            CAST(MP.TCD AS DECIMAL(15,4)) AS [RC21_25], 

                            CASE 

                                WHEN ISNULL(RE.IdRelacionada, 2) <> 2 

                                THEN 1 

                                ELSE 2 

                            END AS [RC21_26] 

                     FROM dbo.FI_Transfer TR WITH(NOLOCK) 

                          JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TR.IdTransferencia = TF.IdTransfer 

                          JOIN dbo.FI_PedimentoComprobante PC WITH(NOLOCK) ON TF.IdPedimentoComprobante = PC.IdPedimentoComprobante 

                                                                              AND PC.IdContrato = TR.IdContrato 

                          JOIN dbo.CO_Registro R WITH(NOLOCK) ON R.IdPedimentoComprobante = PC.IdPedimentoComprobante 

                          JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes 

                          JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto 

                          JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual 

                          JOIN dbo.CO_Contrato C WITH(NOLOCK) ON AC.IdContrato = C.IdContrato 

                          JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista 

                          JOIN dbo.CO_ActividadPetroleraCNH APCNH WITH(NOLOCK) ON LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera 

                          JOIN dbo.CO_SubactividadPetrolera SP WITH(NOLOCK) ON LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera 

                          JOIN dbo.CO_TareaPetrolera TP WITH(NOLOCK) ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera 

                          JOIN dbo.CO_Instalacion I WITH(NOLOCK) ON R.IdInstalacion = I.IdInstalacion 

                          JOIN dbo.CO_Servicio S WITH(NOLOCK) ON S.IdServicio = LPM.IdServicio 

                                                                 AND C.IdContrato = S.IdContrato 

                          JOIN #MontosConvertidosPedimentosCom MP ON MP.IdRegistro = R.IdRegistro 

                                                                     AND MP.IdPedimentoComprobante = R.IdPedimentoComprobante 

                          LEFT JOIN dbo.PD_Campo CPO WITH(NOLOCK) ON I.IdCampo = CPO.IdCampo 

                          LEFT JOIN dbo.CO_Yacimiento Y WITH(NOLOCK) ON CPO.IdYacimiento = Y.IdYacimiento 

                          LEFT JOIN dbo.CO_CatalogoCuentaSH CC WITH(NOLOCK) ON CC.IdCatalogoCuentasSH = R.IdCatalogoCuentasSH 

                          LEFT JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON PC.IdMoneda = TM.IdMoneda 

                          LEFT JOIN dbo.CO_RelacionEmpresas RE WITH(NOLOCK) ON RE.IdContratista = CON.IdContratista 

                                                                               AND PC.IdSubcontratistaExportador = RE.IdRelacionada 

                     WHERE C.IdContrato = @Contrato 

                           AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes 

                           AND R.IdEstado = 10004 

                           AND R.CvTipoDocFacturacion IN(2, 3) 

                          AND ISNULL(CONVERT(INT, PC.ProcesadoSIPAC), 0) = 0 

                          AND S.NombreServicio NOT LIKE '%No elegibles%' 

                          AND ISNULL(PC.EsnotaCredito, 0) <> 1 

                          AND P.IdPresupuesto = CASE 

                                                    WHEN @IdPresupuesto = 0 

                                                    THEN LPM.IdPresupuesto 

                                                    ELSE @IdPresupuesto 

                                                END 

                     GROUP BY LTRIM(RTRIM(CON.IDSIPAC)),  

                              LTRIM(RTRIM(C.IDRegFiducidiario)),  

                              C.NumeroContrato,  

                              SUBSTRING(P.IdPresupuestoCNH, 22, 10),  

                              MONTH(R.MesPresentacion),  

                              YEAR(R.MesPresentacion),  

                              SUBSTRING(PC.IdDocFacturacionSIPAC, 1, 2), 

                              CASE 

                                  WHEN R.CvTipoDocFacturacion = 1 

                                  THEN 'NA' 

                                  WHEN R.CvTipoDocFacturacion = 3 

                                  THEN 'NA' 

                                  WHEN R.CvTipoDocFacturacion = 2 

                                  THEN PC.NumeroPedimento 

                              END, 

                              CASE 

                                  WHEN R.CvTipoDocFacturacion = 1 

                                  THEN 'NA' 

                                  WHEN R.CvTipoDocFacturacion = 2 

                                  THEN 'NA' 

                                  WHEN R.CvTipoDocFacturacion = 3 

                                  THEN PC.IdDocFacturacionSIPAC 

                              END,  

                              LTRIM(RTRIM(APCNH.id_Actividad)),  

                              LTRIM(RTRIM(SP.[id_Sub-actividad])),  

                              LTRIM(RTRIM(TP.id_Tarea)), 

                              CASE 

                                  WHEN R.CostosAtribuiblesAdministracion = 1 

                                  THEN 1 

                                  ELSE 0 

                              END, 

                              CASE 

                                  WHEN R.CostosAtribuiblesAdministracion = 1 

                                  THEN 'NA' 

                                  ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-'))) 

                              END, 

                              CASE 

                                  WHEN R.CostosAtribuiblesAdministracion = 1 

                                  THEN 'NA' 

                                  ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-'))) 

                              END, 

                              CASE 

                                  WHEN R.CostosAtribuiblesAdministracion = 1 

                                  THEN 'NA' 

                                  ELSE LTRIM(RTRIM(I.NombreInstalacion)) 

                              END,  

							 CC.Nivel3,  

                              CC.Descripcion,  

                              R.Poliza,  

                              SUBSTRING(R.Comentarios, 0, 299), 

                              case when r.CapexOpexEdicion is not null then 
								case when r.CapexOpexEdicion = 1 then 1 
								else 2 end 
							else 
								case when CC.Operacion = 1 then 1 else 2 end end , 

                              TM.TipoMonedaCorto,  

                              CAST(MP.TCD AS DECIMAL(15,4)), 

                              CASE 

                                  WHEN ISNULL(RE.IdRelacionada, 2) <> 2 

                                  THEN 1 

                                  ELSE 2 

                              END 

                 ) AS Resultado; 

             END; 

     END;
