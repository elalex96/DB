USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SIPAC_RC_CONT_26_M]    Script Date: 28/03/2022 12:53:40 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Yazmin Glez.
-- Create date: 01-11-17
-- Description: Reporte de CGI - MP Transferencia Electrónica. Plantilla RC_CONT_06_M
-- Modificado: 20180625
-- Modificado: Reyna Olvera
-- Description: Se modifico para que cuando no tenga archivo cargado en la transferencia, muestre una nota de archivo no cargado
-- Modificado: Manuel Cruz
-- Fecha Modificado: 2019-07-01
-- Description: Cambio para mostrar la transferencia con el complemento de pago
-- =============================================
-- Modificado:       Marcos Garcia
-- Fecha Modificado: 2020-01-13
-- Description:     *Agregar Validacion de @IdPresupuesto = 0
--                  *Agregar WITH (NOLOCK) en las tablas 
-- =============================================
-- Modificado:       Manuel Cruz
-- Fecha Modificado: 2021-03-22
-- Description:      Se ajustó consulta de PE/PI para evitar la multiplicación de los montos por la cantidad de registros
-- =============================================
-- Modificado:       Manuel Cruz
-- Fecha Modificado: 2022-03-28
-- Description:      Se ajusta tipo de cambio RC_26_10 a 4 decimales
-- =============================================
ALTER PROCEDURE [dbo].[SIPAC_RC_CONT_26_M]
-- [SIPAC_RC_CONT_26_M] 10036,'2018-12-01',1
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT  = 0
AS
     BEGIN
         SET NOCOUNT ON;

         /*Generar nombre de archivos*/

         EXEC [SIPAC_RC_CONT_26_M_IdDocFormaPago] 
              @Contrato, 
              @Mes, 
              @IdPresupuesto;

         /*Omitir facturas en la hoja 26*/

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

         /**/

         IF OBJECT_ID('tempdb..#Facturas', 'U') IS NOT NULL
             DROP TABLE #Facturas;
         IF OBJECT_ID('tempdb..#MontosTotalTransferenciaPUE', 'U') IS NOT NULL
             DROP TABLE #MontosTotalTransferenciaPUE;
         IF OBJECT_ID('tempdb..#MontosTotalTransferenciaPPD', 'U') IS NOT NULL
             DROP TABLE #MontosTotalTransferenciaPPD;

         --

         CREATE TABLE #Facturas
         (IdFactura       INT, 
          UUID            VARCHAR(500), 
          TipoComprobante VARCHAR(50), 
          MetodoPago      VARCHAR(50), 
          IdMoneda        INT
         );

         --

         INSERT INTO #Facturas
         (IdFactura, 
          UUID, 
          TipoComprobante, 
          MetodoPago, 
          IdMoneda
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
                       END AS MetodoPago, 
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
                         F.UUID, 
                         F.IdMoneda;

         /*PPD*/

         CREATE TABLE #MontosTotalTransferenciaPPD
         (IdFacturaCP  INT, 
          UUIDCP       VARCHAR(500), 
          FormaPagoCP  VARCHAR(50), 
          TipoCambioCP FLOAT, 
          MonedaCP     VARCHAR(50), 
          MontoPesos   FLOAT, 
          MonedaPPD    INT, 
          MontoDolares FLOAT, 
          IdTransfer   INT
         );

         --

         INSERT INTO #MontosTotalTransferenciaPPD
         (IdFacturaCP, 
          UUIDCP, 
          FormaPagoCP, 
          TipoCambioCP, 
          MonedaCP, 
          MontoPesos, 
          MonedaPPD, 
          MontoDolares, 
          IdTransfer
         )
                SELECT Result.IdFacturaCP, 
                       Result.UUIDCP, 
                       Result.FormaPagoCP, 
                       Result.TipoCambioCP, 
                       Result.MonedaCP, 
                       SUM(Result.MontoCP) AS MontoCP, 
                       Result.MonedaPPD, 
                       SUM(Result.MontoDolares) AS MontoDolares, 
                       Result.IdTransferencia
                FROM
                (
                    SELECT F.IdFactura AS IdFacturaCP, 
                           F.UUID AS UUIDCP, 
                           CP.FormaDePagoP AS FormaPagoCP, 
                           TCD.TipoCambio AS TipoCambioCP, 
                           TM.IdMoneda AS MonedaCP, 
                           SUM(CPDR.ImpPagado) AS MontoCP, 
                           FCPDR.IdMoneda AS MonedaPPD, 
                           CAST((SUM(CASE
                                         WHEN TM.IdMoneda = 1
                                              AND FCPDR.IdMoneda = 1
                                         THEN CPDR.ImpPagado / TCD.TipoCambio
                                         WHEN TM.IdMoneda = 2
                                              AND FCPDR.IdMoneda = 2
                                         THEN CPDR.ImpPagado
                                     END)) AS DECIMAL(15, 2)) AS MontoDolares, 
                           T.IdTransferencia
                    FROM dbo.FI_Transfer T WITH(NOLOCK)
                         JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = T.IdTransferencia
                         JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura
                         JOIN dbo.FI_Factura F WITH(NOLOCK) ON F.IdFactura = CP.IdFactura
                         JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
                         JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID
                                                                   AND F.IdContrato = FCPDR.IdContrato
                         JOIN #Facturas ON #Facturas.IdFactura = FCPDR.IdFactura
                         JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON CP.MonedaP = TM.TipoMonedaCorto
                         LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TM.IdMoneda
                                                                               AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                                               AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                                               AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
                    WHERE #Facturas.MetodoPago = 'PPD'
                          AND TF.CvTipoDocFacturacion = 6
                          AND T.IdMoneda = TM.IdMoneda
                          AND TM.IdMoneda = FCPDR.IdMoneda
                    GROUP BY F.IdFactura, 
                             F.UUID, 
                             CP.FormaDePagoP, 
                             TCD.TipoCambio, 
                             TM.IdMoneda, 
                             FCPDR.IdMoneda, 
                             T.IdTransferencia
                    UNION
                    SELECT F.IdFactura AS IdFacturaCP, 
                           F.UUID AS UUIDCP, 
                           CP.FormaDePagoP AS FormaPagoCP, 
                           TCD.TipoCambio AS TipoCambioCP, 
                           TM.IdMoneda AS MonedaCP, 
                           SUM(CPDR.ImpPagado) AS MontoCP, 
                           FCPDR.IdMoneda AS MonedaPPD, 
                           CAST((SUM(CASE
                                         WHEN TM.IdMoneda = 1
                                              AND FCPDR.IdMoneda = 1
                                         THEN CPDR.ImpPagado / TCD.TipoCambio
                                         WHEN TM.IdMoneda = 2
                                              AND FCPDR.IdMoneda = 2
                                         THEN CPDR.ImpPagado
                                     END)) AS DECIMAL(15, 2)) AS MontoDolares, 
                           T.IdTransferencia
                    FROM dbo.FI_Transfer T WITH(NOLOCK)
                         JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = T.IdTransferencia
                         JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura
                         JOIN dbo.FI_Factura F WITH(NOLOCK) ON F.IdFactura = CP.IdFactura
                         JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
                         JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID
                                                                   AND F.IdContrato = FCPDR.IdContrato
                         JOIN #Facturas ON #Facturas.IdFactura = FCPDR.IdFactura
                         JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON CP.MonedaP = TM.TipoMonedaCorto
                         LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TM.IdMoneda
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
                             TCD.TipoCambio, 
                             TM.IdMoneda, 
                             FCPDR.IdMoneda, 
                             T.IdTransferencia
                    UNION
                    SELECT F.IdFactura AS IdFacturaCP, 
                           F.UUID AS UUIDCP, 
                           CP.FormaDePagoP AS FormaPagoCP, 
                           TCD.TipoCambio AS TipoCambioCP, 
                           TM.IdMoneda AS MonedaCP, 
                           CAST((SUM(CASE
                                         WHEN TM.IdMoneda = 1
                                              AND FCPDR.IdMoneda = 2
                                         THEN CPDR.ImpPagado * TCD.TipoCambio
                                         WHEN TM.IdMoneda = 2
                                              AND FCPDR.IdMoneda = 1
                                         THEN CPDR.ImpPagado
                                     END)) AS DECIMAL(15, 2)) AS MontoCP,
                           CASE
                               WHEN TM.IdMoneda = 1
                                    AND FCPDR.IdMoneda = 2
                               THEN 1
                               WHEN TM.IdMoneda = 2
                                    AND FCPDR.IdMoneda = 1
                               THEN 2
                           END AS MonedaPPD, 
                           CAST((SUM(CASE
                                         WHEN TM.IdMoneda = 1
                                              AND FCPDR.IdMoneda = 2
                                         THEN CPDR.ImpPagado
                                         WHEN TM.IdMoneda = 2
                                              AND FCPDR.IdMoneda = 1
                                         THEN CPDR.ImpPagado / TCD.TipoCambio
                                     END)) AS DECIMAL(15, 2)) AS MontoDolares, 
                           T.IdTransferencia
                    FROM dbo.FI_Transfer T WITH(NOLOCK)
                         JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = T.IdTransferencia
                         JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura
                         JOIN dbo.FI_Factura F WITH(NOLOCK) ON F.IdFactura = CP.IdFactura
                         JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
                         JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID
                                                                   AND F.IdContrato = FCPDR.IdContrato
                         JOIN #Facturas ON #Facturas.IdFactura = FCPDR.IdFactura
                         JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON CP.MonedaP = TM.TipoMonedaCorto
                         LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TM.IdMoneda
                                                                               AND TCD.IdMoneda <> FCPDR.IdMoneda
                                                                               AND DAY(TCD.Fecha) = DAY(T.FechaPago)
                                                                               AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
                                                                               AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
                    WHERE #Facturas.MetodoPago = 'PPD'
                          AND TF.CvTipoDocFacturacion = 6
						  AND T.IdMoneda <> TM.IdMoneda
                          AND TM.IdMoneda <> FCPDR.IdMoneda
                    GROUP BY F.IdFactura, 
                             F.UUID, 
                             CP.FormaDePagoP, 
                             TCD.TipoCambio, 
                             TM.IdMoneda,
                             CASE
                                 WHEN TM.IdMoneda = 1
                                      AND FCPDR.IdMoneda = 2
                                 THEN 1
                                 WHEN TM.IdMoneda = 2
                                      AND FCPDR.IdMoneda = 1
                                 THEN 2
                             END, 
                             T.IdTransferencia
					UNION
					--Se agrego para los casos donde el complemento es igual a la moneda de la transferencia (USD = USD)
					--y la factura ppd es igual a la moneada del documento relacionado (MXN = MXN)
					SELECT F.IdFactura AS IdFacturaCP, 
							F.UUID AS UUIDCP, 
							CP.FormaDePagoP AS FormaPagoCP, 
							CASE
								WHEN TM.IdMoneda = 2
									AND FCPDR.IdMoneda = 1
								THEN 1
								WHEN TM.IdMoneda = 1
									AND FCPDR.IdMoneda = 2
								THEN TCDD.TipoCambio
							END,
							TM.IdMoneda AS MonedaCP, 
							CAST((SUM(CASE
											WHEN TM.IdMoneda = 2
												AND FCPDR.IdMoneda = 1
											THEN CPDR.ImpPagado / TCD.TipoCambio
											WHEN TM.IdMoneda = 1
												AND FCPDR.IdMoneda = 2
											THEN CPDR.ImpPagado * TCDD.TipoCambio
										END)) AS DECIMAL(15, 2)) AS MontoCP,
							CASE
								WHEN TM.IdMoneda = 2
									AND FCPDR.IdMoneda = 1
								THEN FCPDR.IdMoneda
								WHEN TM.IdMoneda = 1
									AND FCPDR.IdMoneda = 2
								THEN FCPDR.IdMoneda
							END AS MonedaPPD, 
							CAST((SUM(CASE
											WHEN TM.IdMoneda = 2
												AND FCPDR.IdMoneda = 1
											THEN CPDR.ImpPagado / TCD.TipoCambio
											WHEN TM.IdMoneda = 1
												AND FCPDR.IdMoneda = 2
											THEN CPDR.ImpPagado
										END)) AS DECIMAL(15, 2)) AS MontoDolares, 
							T.IdTransferencia --SELECT *
					FROM dbo.FI_Transfer T WITH(NOLOCK)
							JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = T.IdTransferencia
							JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura
							JOIN dbo.FI_Factura F WITH(NOLOCK) ON F.IdFactura = CP.IdFactura
							JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
							JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID
																	AND F.IdContrato = FCPDR.IdContrato
							JOIN #Facturas ON #Facturas.IdFactura = FCPDR.IdFactura
							JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON CP.MonedaP = TM.TipoMonedaCorto
							LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda <> TM.IdMoneda
																				AND TCD.IdMoneda = FCPDR.IdMoneda
																				AND DAY(TCD.Fecha) = DAY(T.FechaPago)
																				AND MONTH(TCD.Fecha) = MONTH(T.FechaPago)
																				AND YEAR(TCD.Fecha) = YEAR(T.FechaPago)
							LEFT JOIN dbo.CO_TipoCambioDiario TCDD WITH(NOLOCK) ON TCDD.IdMoneda <> FCPDR.IdMoneda
																				AND TCDD.IdMoneda NOT IN  (10000,10003,10004)
																				AND DAY(TCDD.Fecha) = DAY(T.FechaPago)
																				AND MONTH(TCDD.Fecha) = MONTH(T.FechaPago)
																				AND YEAR(TCDD.Fecha) = YEAR(T.FechaPago)
					WHERE #Facturas.MetodoPago = 'PPD'
							AND TF.CvTipoDocFacturacion = 6
							AND T.IdMoneda = TM.IdMoneda
							AND TM.IdMoneda <> FCPDR.IdMoneda
					GROUP BY F.IdFactura,
								F.UUID,
								CP.FormaDePagoP,
								CASE
									WHEN TM.IdMoneda = 2
										AND FCPDR.IdMoneda = 1
									THEN 1
									WHEN TM.IdMoneda = 1
										AND FCPDR.IdMoneda = 2
									THEN TCDD.TipoCambio
								END,
								TM.IdMoneda,
								CASE
									WHEN TM.IdMoneda = 2
										AND FCPDR.IdMoneda = 1
									THEN FCPDR.IdMoneda
									WHEN TM.IdMoneda = 1
										AND FCPDR.IdMoneda = 2
									THEN FCPDR.IdMoneda
								END,
								T.IdTransferencia
					/*SELECT F.IdFactura AS IdFacturaCP, 
							F.UUID AS UUIDCP, 
							CP.FormaDePagoP AS FormaPagoCP, 
							1 AS TipoCambioCP, 
							TM.IdMoneda AS MonedaCP, 
							CAST((SUM(CASE
											WHEN TM.IdMoneda = 2
												AND FCPDR.IdMoneda = 1
											THEN CPDR.ImpPagado / TCD.TipoCambio
										END)) AS DECIMAL(15, 2)) AS MontoCP,
							CASE
								WHEN TM.IdMoneda = 2
									AND FCPDR.IdMoneda = 1
								THEN 2
							END AS MonedaPPD, 
							CAST((SUM(CASE
											WHEN TM.IdMoneda = 2
												AND FCPDR.IdMoneda = 1
											THEN CPDR.ImpPagado / TCD.TipoCambio
										END)) AS DECIMAL(15, 2)) AS MontoDolares, 
							T.IdTransferencia
					FROM dbo.FI_Transfer T WITH(NOLOCK)
							JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = T.IdTransferencia
							JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura
							JOIN dbo.FI_Factura F WITH(NOLOCK) ON F.IdFactura = CP.IdFactura
							JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
							JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID
																	AND F.IdContrato = FCPDR.IdContrato
							JOIN #Facturas ON #Facturas.IdFactura = FCPDR.IdFactura
							JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON CP.MonedaP = TM.TipoMonedaCorto
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
								TCD.TipoCambio, 
								TM.IdMoneda,
								CASE
									WHEN TM.IdMoneda = 2
										AND FCPDR.IdMoneda = 1
									THEN 2
								END, 
								T.IdTransferencia*/
                ) AS Result
                GROUP BY Result.IdFacturaCP, 
                         Result.UUIDCP, 
                         Result.FormaPagoCP, 
                         Result.TipoCambioCP, 
                         Result.MonedaCP, 
                         Result.MonedaPPD, 
                         Result.IdTransferencia;

         /*PUE*/

         CREATE TABLE #MontosTotalTransferenciaPUE
         (IdFacturaPUE   INT, 
          UUIDPUE        VARCHAR(500), 
          FormaPagoPUE   VARCHAR(50), 
          TipoCambio     FLOAT, 
          MonedaTransfer VARCHAR(50), 
          MontoPesos     FLOAT, 
          MonedaFactura  INT, 
          MontoFactura   FLOAT, 
          MontoDolares   FLOAT, 
          IdTransfer     INT
         );

         --

         INSERT INTO #MontosTotalTransferenciaPUE
         (IdFacturaPUE, 
          UUIDPUE, 
          FormaPagoPUE, 
          TipoCambio, 
          MonedaTransfer, 
          MontoPesos, 
          MonedaFactura, 
          MontoFactura, 
          MontoDolares, 
          IdTransfer
         )
                SELECT F.IdFactura AS IdFacturaPUE, 
                       F.UUID AS UUIDPUE, 
                       MP.C_FormaPago AS MetodoPago, 
                       TCD.TipoCambio AS TipoCambioTransfer, 
                       TR.IdMoneda AS MonedaTransfer, 
                       CAST((SUM(CASE
                                     WHEN TR.IdMoneda = 2
                                          AND F.IdMoneda = 2
                                     THEN TF.MontoPagado * TCD.TipoCambio
                                     WHEN TR.IdMoneda = 1
                                          AND F.IdMoneda = 1
                                     THEN TF.MontoPagado
                                 END)) AS DECIMAL(15, 2)) AS MontoPesos, 
                       F.IdMoneda AS MonedaPUE, 
                       F.MontoConIva, 
                       CAST((SUM(CASE
                                     WHEN TR.IdMoneda = 1
                                          AND F.IdMoneda = 1
                                     THEN TF.MontoPagado / TCD.TipoCambio
                                     WHEN TR.IdMoneda = 2
                                          AND F.IdMoneda = 2
                                     THEN TF.MontoPagado
                                 END)) AS DECIMAL(15, 2)) AS MontoDolares, 
                       TR.IdTransferencia
                FROM dbo.FI_Transfer TR WITH(NOLOCK)
                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TR.IdTransferencia = TF.IdTransfer
                     JOIN dbo.PV_MetodoPago MP WITH(NOLOCK) ON MP.idMetodoPago = TR.IdMetodoPago
                     JOIN dbo.FI_Factura F WITH(NOLOCK) ON TF.IdFactura = F.IdFactura
                                                           AND F.IdContrato = TR.IdContrato
                     JOIN #Facturas ON #Facturas.IdFactura = F.IdFactura
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TR.IdMoneda
                                                                           AND TCD.IdMoneda = F.IdMoneda
                                                                           AND DAY(TCD.Fecha) = DAY(TR.FechaPago)
                                                                           AND MONTH(TCD.Fecha) = MONTH(TR.FechaPago)
                                                                           AND YEAR(TCD.Fecha) = YEAR(TR.FechaPago)
                     LEFT JOIN dbo.CO_TipoCambioDiario TCDT WITH(NOLOCK) ON TCDT.IdMoneda <> TR.IdMoneda
                                                                            AND TCDT.IdMoneda <> F.IdMoneda
                                                                            AND TCDT.IdMoneda NOT IN  (10000,10003,10004)
                                                                            AND DAY(TCDT.Fecha) = DAY(TR.FechaPago)
                                                                            AND MONTH(TCDT.Fecha) = MONTH(TR.FechaPago)
                                                                            AND YEAR(TCDT.Fecha) = YEAR(TR.FechaPago)
                WHERE #Facturas.MetodoPago = 'PUE'
                      AND TF.CvTipoDocFacturacion = 1
                      AND F.IdMoneda = TR.IdMoneda
                GROUP BY F.IdFactura, 
                         F.UUID, 
                         MP.C_FormaPago, 
                         TCD.TipoCambio, 
                         TR.IdMoneda, 
                         F.IdMoneda, 
                         F.MontoConIva, 
                         TR.IdTransferencia
                UNION
                SELECT F.IdFactura AS IdFacturaPUE, 
                       F.UUID AS UUIDPUE, 
                       MP.C_FormaPago AS MetodoPago, 
                       TCD.TipoCambio AS TipoCambioTransfer, 
                       TR.IdMoneda AS MonedaTransfer, 
                       CAST((SUM(CASE
                                     WHEN TR.IdMoneda = 2
                                          AND F.IdMoneda = 1
                                     THEN TF.MontoPagado * TCD.TipoCambio
                                     WHEN TR.IdMoneda = 1
                                          AND F.IdMoneda = 2
                                     THEN TF.MontoPagado
                                 END)) AS DECIMAL(15, 2)) AS MontoPesos, 
                       F.IdMoneda AS MonedaPUE, 
                       F.MontoConIva, 
                       CAST((SUM(CASE
                                     WHEN TR.IdMoneda = 1
                                          AND F.IdMoneda = 2
                                     THEN TF.MontoPagado / TCD.TipoCambio
                                     WHEN TR.IdMoneda = 2
                                          AND F.IdMoneda = 1
                                     THEN TF.MontoPagado
                                 END)) AS DECIMAL(15, 2)) AS MontoDolares, 
                       TR.IdTransferencia
                FROM dbo.FI_Transfer TR WITH(NOLOCK)
                     JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TR.IdTransferencia = TF.IdTransfer
                     JOIN dbo.PV_MetodoPago MP WITH(NOLOCK) ON MP.idMetodoPago = TR.IdMetodoPago
                     JOIN dbo.FI_Factura F WITH(NOLOCK) ON TF.IdFactura = F.IdFactura
                                                           AND F.IdContrato = TR.IdContrato
                     JOIN #Facturas ON #Facturas.IdFactura = F.IdFactura
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TR.IdMoneda
                                                                           AND TCD.IdMoneda <> F.IdMoneda
                                                                           AND DAY(TCD.Fecha) = DAY(TR.FechaPago)
                                                                           AND MONTH(TCD.Fecha) = MONTH(TR.FechaPago)
                                                                           AND YEAR(TCD.Fecha) = YEAR(TR.FechaPago)
                     LEFT JOIN dbo.CO_TipoCambioDiario TCDT WITH(NOLOCK) ON TCDT.IdMoneda <> TR.IdMoneda
                                                                            AND TCDT.IdMoneda = F.IdMoneda
                                                                            AND TCDT.IdMoneda NOT IN  (10000,10003,10004)
                                                                            AND DAY(TCDT.Fecha) = DAY(TR.FechaPago)
                                                                            AND MONTH(TCDT.Fecha) = MONTH(TR.FechaPago)
                                                                            AND YEAR(TCDT.Fecha) = YEAR(TR.FechaPago)
                WHERE #Facturas.MetodoPago = 'PUE'
                      AND TF.CvTipoDocFacturacion = 1
                      AND F.IdMoneda <> TR.IdMoneda
                GROUP BY F.IdFactura, 
                         F.UUID, 
                         MP.C_FormaPago, 
                         TCD.TipoCambio, 
                         TR.IdMoneda, 
                         F.IdMoneda, 
                         F.MontoConIva, 
                         TR.IdTransferencia;

         /*SELECT FINAL*/

         SELECT LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00], 
                C.IDRegFiducidiario AS [RI_00], 
                MONTH(R.MesPresentacion) AS [RC26_00], 
                YEAR(R.MesPresentacion) AS [RC26_01], 
                MTT.FormaPagoPUE AS [RC26_02],
                CASE
                    WHEN R.CvTipoDocFacturacion = 1
                    THEN ISNULL(F.UUID, 'NA')
                END AS [RC26_03], 
                TR.FechaPago AS [RC26_04],
                CASE
                    WHEN TR.AWSPDFId IS NULL

                                --OR TR.PDF = ''

                    THEN 'NOTA:Falta ingresar archivo PDF'
                    ELSE TR.NombreExtencionArchivo
                END AS [RC26_05], 
                TR.HashSHA256 AS [RC26_06], 
                CAST(MTT.MontoPesos --/ COUNT(R.IdRegistro))

                AS DECIMAL(15, 2)) AS [RC26_07], 
                TM.TipoMonedaCorto AS [RC26_08], 
                CAST(MTT.MontoDolares --/ COUNT(R.IdRegistro))

                AS DECIMAL(15, 2)) AS [RC26_09], 
                CAST(MTT.TipoCambio AS DECIMAL(15,4)) AS [RC26_10],

                --LTRIM(RTRIM(SUBSTRING(SUBD.RazonSocial, 0, 119))) AS [RC26_11],

                LTRIM(RTRIM(SUBSTRING(S.RazonSocial, 0, 119))) AS [RC26_11], 
                2 AS [RC26_12] --,
         --COUNT(R.IdRegistro)

         FROM dbo.FI_Transfer TR WITH(NOLOCK)
              JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TR.IdTransferencia = TF.IdTransfer
              JOIN #MontosTotalTransferenciaPUE MTT ON TF.IdFactura = MTT.IdFacturaPUE
                                                       AND MTT.IdTransfer = TF.IdTransfer
              JOIN dbo.FI_Factura F WITH(NOLOCK) ON MTT.IdFacturaPUE = F.IdFactura
                                                    AND F.IdContrato = TR.IdContrato
              JOIN dbo.CO_Registro R WITH(NOLOCK) ON R.IdFactura = F.IdFactura
              JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
              JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
              JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
              JOIN dbo.CO_Contrato C WITH(NOLOCK) ON AC.IdContrato = C.IdContrato
              JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista
              JOIN dbo.CO_Servicio SER WITH(NOLOCK) ON SER.IdServicio = LPM.IdServicio
                                                       AND SER.IdContrato = C.IdContrato

              --JOIN dbo.PV_CuentaBancaria CBO ON TR.IdCuentaOrigen = CBO.DatoBancarioID
              --JOIN dbo.PV_CuentaBancaria CBD ON TR.IdCuentaDestino = CBD.DatoBancarioID
              --JOIN dbo.PV_Subcontratista SUBO ON CBO.IdProveedor = SUBO.IdSubcontratista
              --JOIN dbo.PV_Subcontratista SUBD ON CBD.IdProveedor = SUBD.IdSubcontratista

              JOIN dbo.PV_Subcontratista S WITH(NOLOCK) ON F.IdSubcontratista = S.IdSubcontratista
              JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON MTT.MonedaTransfer = TM.IdMoneda
         WHERE C.IdContrato = @Contrato
               AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
               AND R.IdEstado = 10004
               AND ISNULL(CONVERT(INT, TR.ProcesadoSIPAC), 0) = 0
               AND SER.NombreServicio NOT LIKE '%No elegibles%'
               AND P.IdPresupuesto = CASE
                                         WHEN @IdPresupuesto = 0
                                         THEN LPM.IdPresupuesto
                                         ELSE @IdPresupuesto
                                     END
         --AND DATEFROMPARTS(YEAR(TR.FechaPago), MONTH(TR.FechaPago), 1) = @Mes

         GROUP BY LTRIM(RTRIM(CON.IDSIPAC)), 
                  MONTH(R.MesPresentacion), 
                  YEAR(R.MesPresentacion),
                  CASE
                      WHEN R.CvTipoDocFacturacion = 1
                      THEN ISNULL(F.UUID, 'NA')
                  END,
                  CASE
                      WHEN TR.AWSPDFId IS NULL

                  --OR TR.PDF = ''

                      THEN 'NOTA:Falta ingresar archivo PDF'
                      ELSE TR.NombreExtencionArchivo
                  END, 
                  CAST(MTT.MontoPesos --/ COUNT(R.IdRegistro))

                  AS DECIMAL(15, 2)), 
                  CAST(MTT.MontoDolares --/ COUNT(R.IdRegistro))

                  AS DECIMAL(15, 2)),

                  --LTRIM(RTRIM(SUBSTRING(SUBD.RazonSocial, 0, 119))),

                  LTRIM(RTRIM(SUBSTRING(S.RazonSocial, 0, 119))), 
                  C.IDRegFiducidiario, 
                  MTT.FormaPagoPUE, 
                  TR.FechaPago, 
                  TR.HashSHA256, 
                  TM.TipoMonedaCorto, 
                  CAST(MTT.TipoCambio AS DECIMAL(15,4))
         --
         UNION
         --
         SELECT LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00], 
                C.IDRegFiducidiario AS [RI_00], 
                MONTH(R.MesPresentacion) AS [RC26_00], 
                YEAR(R.MesPresentacion) AS [RC26_01], 
                MTT.FormaPagoCP AS [RC26_02], 
                ISNULL(MTT.UUIDCP, 'NA') AS [RC26_03], 
                TR.FechaPago AS [RC26_04],
                CASE
                    WHEN TR.AWSPDFId IS NULL

                                --OR TR.PDF = ''

                    THEN 'NOTA:Falta ingresar archivo PDF'
                    ELSE TR.NombreExtencionArchivo
                END AS [RC26_05], 
                TR.HashSHA256 AS [RC26_06], 
                CAST(MTT.MontoPesos --/ COUNT(R.IdRegistro))

                AS DECIMAL(15, 2)) AS [RC26_07], 
                TM.TipoMonedaCorto AS [RC26_08], 
                CAST(MTT.MontoDolares --/ COUNT(R.IdRegistro))

                AS DECIMAL(15, 2)) AS [RC26_09], 
                CAST(MTT.TipoCambioCP AS DECIMAL(15,4)) AS [RC26_10],

                --LTRIM(RTRIM(SUBSTRING(SUBD.RazonSocial, 0, 119))) AS [RC26_11],

                LTRIM(RTRIM(SUBSTRING(S.RazonSocial, 0, 119))) AS [RC26_11], 
                2 AS [RC26_12] --,
         --COUNT(R.IdRegistro)

         FROM dbo.FI_Transfer TR WITH(NOLOCK)
              JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TR.IdTransferencia = TF.IdTransfer
              JOIN #MontosTotalTransferenciaPPD MTT ON TF.IdFactura = MTT.IdFacturaCP
                                                       AND MTT.IdTransfer = TF.IdTransfer
              JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON MTT.IdFacturaCP = CP.IdFactura
              JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
              JOIN dbo.FI_Factura FCP WITH(NOLOCK) ON TF.IdFactura = FCP.IdFactura
                                                      AND TR.IdContrato = FCP.IdContrato
              JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID
              JOIN dbo.CO_Registro R WITH(NOLOCK) ON FCPDR.IdFactura = R.IdFactura
              JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
              JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
              JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
              JOIN dbo.CO_Contrato C WITH(NOLOCK) ON AC.IdContrato = C.IdContrato
              JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista
              JOIN dbo.CO_Servicio SER WITH(NOLOCK) ON SER.IdServicio = LPM.IdServicio
                                                       AND SER.IdContrato = C.IdContrato

              --JOIN dbo.PV_CuentaBancaria CBO ON TR.IdCuentaOrigen = CBO.DatoBancarioID
              --JOIN dbo.PV_CuentaBancaria CBD ON TR.IdCuentaDestino = CBD.DatoBancarioID
              --JOIN dbo.PV_Subcontratista SUBO ON CBO.IdProveedor = SUBO.IdSubcontratista
              --JOIN dbo.PV_Subcontratista SUBD ON CBD.IdProveedor = SUBD.IdSubcontratista

              JOIN dbo.PV_Subcontratista S WITH(NOLOCK) ON FCPDR.IdSubcontratista = S.IdSubcontratista
              JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON MTT.MonedaCP = TM.IdMoneda
         WHERE C.IdContrato = @Contrato
               AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
               AND R.IdEstado = 10004
               AND ISNULL(CONVERT(INT, TR.ProcesadoSIPAC), 0) = 0
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
         --AND DATEFROMPARTS(YEAR(TR.FechaPago), MONTH(TR.FechaPago), 1) = @Mes

         GROUP BY LTRIM(RTRIM(CON.IDSIPAC)), 
                  MONTH(R.MesPresentacion), 
                  YEAR(R.MesPresentacion), 
                  ISNULL(MTT.UUIDCP, 'NA'),
                  CASE
                      WHEN TR.AWSPDFId IS NULL

                                         --OR TR.PDF = ''

                      THEN 'NOTA:Falta ingresar archivo PDF'
                      ELSE TR.NombreExtencionArchivo
                  END, 
                  CAST(MTT.MontoPesos --/ COUNT(R.IdRegistro))

                  AS DECIMAL(15, 2)), 
                  CAST(MTT.MontoDolares --/ COUNT(R.IdRegistro))

                  AS DECIMAL(15, 2)),

                  --LTRIM(RTRIM(SUBSTRING(SUBD.RazonSocial, 0, 119))),

                  LTRIM(RTRIM(SUBSTRING(S.RazonSocial, 0, 119))), 
                  C.IDRegFiducidiario, 
                  MTT.FormaPagoCP, 
                  TR.FechaPago, 
                  TR.HashSHA256, 
                  TM.TipoMonedaCorto, 
                  CAST(MTT.TipoCambioCP AS DECIMAL(15,4))
         --
         UNION
         --
         SELECT LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00],
                C.IDRegFiducidiario AS [RI_00],
                MONTH(R.MesPresentacion) AS [RC26_00],
                YEAR(R.MesPresentacion) AS [RC26_01],
                PVM.C_FormaPago AS [RC26_02],
                CASE
                    WHEN R.CvTipoDocFacturacion = 2
                    THEN ISNULL(PC.NumeroPedimento, 'NA')
                    WHEN R.CvTipoDocFacturacion = 3
                    THEN ISNULL(PC.IdDocFacturacionSIPAC, 'NA')
                END AS [RC26_04],
                TR.FechaPago AS [RC26_04],
                CASE
                    WHEN TR.AWSPDFId IS NULL
                                --OR TR.PDF = ''
                    THEN 'NOTA:Falta ingresar archivo PDF'
                    ELSE TR.NombreExtencionArchivo
                END AS [RC26_05],
                TR.HashSHA256 AS [RC26_06],
                CAST(SUM(TF.MontoPagado) / COUNT(R.IdRegistro)
                AS DECIMAL(15, 2)) AS [RC26_07],
                TM.TipoMonedaCorto AS [RC26_08],
                CAST((SUM(CASE
                              WHEN ISNULL(TF.MontoPagado, 0) <> 0
                              THEN CAST((ISNULL(TF.MontoPagado, 0) / TCD.TipoCambio) AS DECIMAL(15, 2))
                              ELSE 0
                          END)) / COUNT(R.IdRegistro)
                AS DECIMAL(15, 2)) AS [RC26_09],
                CAST(TCD.TipoCambio AS DECIMAL(15,4)) AS [RC26_10],
                --LTRIM(RTRIM(SUBSTRING(SUBD.RazonSocial, 0, 119))) AS [RC26_11],
                LTRIM(RTRIM(SUBSTRING(S.RazonSocial, 0, 119))) AS [RC26_11],
                2 AS [RC26_12]--,
         --COUNT(R.IdRegistro)
         FROM dbo.FI_Transfer TR WITH(NOLOCK)
              JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TR.IdTransferencia = TF.IdTransfer
              JOIN dbo.FI_PedimentoComprobante PC WITH(NOLOCK) ON TF.IdPedimentoComprobante = PC.IdPedimentoComprobante
                                                                  AND TR.IdContrato = PC.IdContrato
              JOIN dbo.CO_Registro R WITH(NOLOCK) ON R.IdPedimentoComprobante = PC.IdPedimentoComprobante
              JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
              JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
              JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
              JOIN dbo.CO_Contrato C WITH(NOLOCK) ON AC.IdContrato = C.IdContrato
              JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista
              JOIN dbo.CO_Servicio SER WITH(NOLOCK) ON SER.IdServicio = LPM.IdServicio
                                                       AND SER.IdContrato = C.IdContrato
              --JOIN dbo.PV_CuentaBancaria CBO ON TR.IdCuentaOrigen = CBO.DatoBancarioID
              --JOIN dbo.PV_CuentaBancaria CBD ON TR.IdCuentaDestino = CBD.DatoBancarioID
              --JOIN dbo.PV_Subcontratista SUBO ON CBO.IdProveedor = SUBO.IdSubcontratista
              --JOIN dbo.PV_Subcontratista SUBD ON CBD.IdProveedor = SUBD.IdSubcontratista
              --JOIN dbo.PV_Banco BO ON CBO.BancoID = BO.BancoID
              --JOIN dbo.PV_Banco BD ON CBD.BancoID = BD.BancoID
              JOIN dbo.PV_Subcontratista S WITH(NOLOCK) ON PC.IdSubcontratistaExportador = S.IdSubcontratista
              JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON TR.IdMoneda = TM.IdMoneda
              LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TR.IdMoneda
                                                                    AND DAY(TCD.Fecha) = DAY(TR.FechaPago)
                                                                    AND MONTH(TCD.Fecha) = MONTH(TR.FechaPago)
                                                                    AND YEAR(TCD.Fecha) = YEAR(TR.FechaPago)
              LEFT JOIN dbo.PV_MetodoPago PVM WITH(NOLOCK) ON PVM.idMetodoPago = TR.IdMetodoPago
         WHERE C.IdContrato = @Contrato
               AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
               AND R.IdEstado = 10004
               AND ISNULL(CONVERT(INT, TR.ProcesadoSIPAC), 0) = 0
               AND SER.NombreServicio NOT LIKE '%No elegibles%'
               AND ISNULL(PC.EsnotaCredito, 0) <> 1
               AND P.IdPresupuesto = CASE
                                         WHEN @IdPresupuesto = 0
                                         THEN LPM.IdPresupuesto
                                         ELSE @IdPresupuesto
                                     END
         --AND DATEFROMPARTS(YEAR(TR.FechaPago), MONTH(TR.FechaPago), 1) = @Mes
         GROUP BY LTRIM(RTRIM(CON.IDSIPAC)),
                  MONTH(R.MesPresentacion),
                  YEAR(R.MesPresentacion),
                  CASE
                      WHEN R.CvTipoDocFacturacion = 2
                      THEN ISNULL(PC.NumeroPedimento, 'NA')
                      WHEN R.CvTipoDocFacturacion = 3
                      THEN ISNULL(PC.IdDocFacturacionSIPAC, 'NA')
                  END,
                  CASE
                      WHEN TR.AWSPDFId IS NULL
                  --OR TR.PDF = ''
                      THEN 'NOTA:Falta ingresar archivo PDF'
                      ELSE TR.NombreExtencionArchivo
                  END,
                  --LTRIM(RTRIM(SUBSTRING(SUBD.RazonSocial, 0, 119))),
                  LTRIM(RTRIM(SUBSTRING(S.RazonSocial, 0, 119))),
                  C.IDRegFiducidiario,
                  PVM.C_FormaPago,
                  TR.FechaPago,
                  TR.HashSHA256,
                  TM.TipoMonedaCorto,
                  CAST(TCD.TipoCambio AS DECIMAL(15,4));
     END;