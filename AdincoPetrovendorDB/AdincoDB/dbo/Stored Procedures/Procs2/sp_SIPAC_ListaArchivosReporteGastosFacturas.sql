
-- =============================================
-- Author:      ManuelCruz
-- Create date: 05-06-17
-- Description:
-- =============================================
-- Modificado:       Neri Del Angel
-- Fecha Modificado: 2020-01-13
-- Description:     *Agregar Validacion de @IdPresupuesto = 0
--                  *Agregar WITH (NOLOCK) en las tablas 
-- Modificado:       Neri Del Angel
-- Fecha Modificado: 2022-02-25
-- Description:     *Se ajusta para no traer los xml de los E
-- =============================================
CREATE PROCEDURE [dbo].[sp_SIPAC_ListaArchivosReporteGastosFacturas]
-- [sp_SIPAC_ListaArchivosReporteGastosFacturas] 10024, '2020-12-01', 0
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT  = 0
AS
     BEGIN
         SET NOCOUNT ON;

         --Crear temporal

         IF OBJECT_ID('tempdb..#Factura', 'U') IS NOT NULL
             DROP TABLE #FI_Factura;
         CREATE TABLE #FI_Factura
         ([IdFactura]  [INT], 
          [IdContrato] [INT], 
          [SIPAC]      [INT]
         );

         --

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

         /*Consulta final*/

         SELECT F.IdFactura, 
                F.IdContrato, 
                F.ArchivoXML AS NombreArchivo
         FROM dbo.FI_Transfer TR WITH(NOLOCK)
              JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TR.IdTransferencia = TF.IdTransfer
              JOIN dbo.FI_Factura F WITH(NOLOCK) ON TF.IdFactura = F.IdFactura
                                                    AND TR.IdContrato = F.IdContrato
              JOIN dbo.CO_Registro R WITH(NOLOCK) ON R.IdFactura = F.IdFactura
              JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
              JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
              JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
              JOIN dbo.CO_Contrato C WITH(NOLOCK) ON AC.IdContrato = C.IdContrato
              JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista
              JOIN dbo.CO_Servicio SER WITH(NOLOCK) ON SER.IdServicio = LPM.IdServicio
                                                       AND SER.IdContrato = C.IdContrato
              JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON F.IdMoneda = TM.IdMoneda
              LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TM.IdMoneda
                                                                    AND DAY(TCD.Fecha) = DAY(F.Fecha)
                                                                    AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                                                    AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
         WHERE C.IdContrato = @Contrato
               AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
               AND R.IdEstado = 10004
               AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
               AND SER.NombreServicio NOT LIKE '%No elegibles%'
			   AND F.TipoComprobante NOT LIKE '%egreso%'
			   AND F.TipoComprobante NOT LIKE 'E%'
               AND (F.MetodoPago LIKE '%exhibi%'
                    OR F.MetodoPago LIKE '%PUE%'
                    OR F.FormaPago LIKE '%exhibi%'
                    OR F.FormaPago LIKE '%PUE%')
               AND P.IdPresupuesto = CASE
                                         WHEN @IdPresupuesto = 0
                                         THEN LPM.IdPresupuesto
                                         ELSE @IdPresupuesto
                                     END

         --AND P.IdPresupuesto = @IdPresupuesto

         GROUP BY F.IdFactura, 
                  F.IdContrato, 
                  F.ArchivoXML
         --
         UNION
         --
         SELECT FCPDR.IdFactura, 
                FCPDR.IdContrato, 
                FCPDR.ArchivoXML AS NombreArchivo
         FROM dbo.FI_Transfer TR WITH(NOLOCK)
              JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = TR.IdTransferencia
              JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura
              JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
              JOIN dbo.FI_Factura FCP WITH(NOLOCK) ON FCP.IdFactura = CP.IdFactura
                                                      AND TR.IdContrato = FCP.IdContrato
              JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID
              JOIN dbo.CO_Registro R WITH(NOLOCK) ON FCPDR.IdFactura = R.IdFactura
              JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON LPM.IdLineaPresupuestoMes = R.IdPrograma
              JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
              JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
              JOIN dbo.CO_Contrato C WITH(NOLOCK) ON C.IdContrato = AC.IdContrato
              JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON CON.IdContratista = C.IdContratista
              JOIN dbo.CO_Servicio SER WITH(NOLOCK) ON SER.IdServicio = LPM.IdServicio
                                                       AND SER.IdContrato = C.IdContrato
              JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON TM.IdMoneda = FCPDR.IdMoneda
              LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TM.IdMoneda
                                                                    AND DAY(TCD.Fecha) = DAY(FCPDR.Fecha)
                                                                    AND MONTH(TCD.Fecha) = MONTH(FCPDR.Fecha)
                                                                    AND YEAR(TCD.Fecha) = YEAR(FCPDR.Fecha)
         WHERE C.IdContrato = @Contrato
               AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
               AND R.IdEstado = 10004
               AND ISNULL(CONVERT(INT, FCP.ProcesadoSIPAC), 0) = 0
               AND SER.NombreServicio NOT LIKE '%No elegibles%'
               AND FCPDR.UUID NOT IN
         (
             SELECT RPT.UUID
             FROM #uuidNoReportar RPT
         )
               AND FCPDR.UUID NOT IN
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
         --AND P.IdPresupuesto = @IdPresupuesto

         GROUP BY FCPDR.IdFactura, 
                  FCPDR.IdContrato, 
                  FCPDR.ArchivoXML
         --
         UNION
         --
         SELECT FCP.IdFactura, 
                FCP.IdContrato, 
                FCP.ArchivoXML AS NombreArchivo
         FROM dbo.FI_Transfer TR WITH(NOLOCK)
              JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TF.IdTransfer = TR.IdTransferencia
              JOIN dbo.FI_ComplementoDePago CP WITH(NOLOCK) ON CP.IdFactura = TF.IdFactura
              JOIN dbo.FI_CPDocRelacionado CPDR WITH(NOLOCK) ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
              JOIN dbo.FI_Factura FCP WITH(NOLOCK) ON FCP.IdFactura = CP.IdFactura
                                                      AND TR.IdContrato = FCP.IdContrato
              JOIN dbo.FI_Factura FCPDR WITH(NOLOCK) ON CPDR.IdDocumento = FCPDR.UUID
              JOIN dbo.CO_Registro R WITH(NOLOCK) ON FCPDR.IdFactura = R.IdFactura
              JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON LPM.IdLineaPresupuestoMes = R.IdPrograma
              JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
              JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
              JOIN dbo.CO_Contrato C WITH(NOLOCK) ON C.IdContrato = AC.IdContrato
              JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON CON.IdContratista = C.IdContratista
              JOIN dbo.CO_Servicio SER WITH(NOLOCK) ON SER.IdServicio = LPM.IdServicio
                                                       AND SER.IdContrato = C.IdContrato
              JOIN dbo.PV_TipoMoneda TM WITH(NOLOCK) ON TM.IdMoneda = FCPDR.IdMoneda
              LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = TM.IdMoneda
                                                                    AND DAY(TCD.Fecha) = DAY(FCPDR.Fecha)
                                                                    AND MONTH(TCD.Fecha) = MONTH(FCPDR.Fecha)
                                                                    AND YEAR(TCD.Fecha) = YEAR(FCPDR.Fecha)
         WHERE C.IdContrato = @Contrato
               AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
               AND R.IdEstado = 10004
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
         --AND P.IdPresupuesto = @IdPresupuesto

         GROUP BY FCP.IdFactura, 
                  FCP.IdContrato, 
                  FCP.ArchivoXML;

         ----
         --UNION
         ----
         --SELECT F.IdFactura,
         --       F.IdContrato,
         --       F.ArchivoXML AS NombreArchivo
         --FROM dbo.FI_Transfer TR
         --     JOIN dbo.FI_TransferFactura TF ON TR.IdTransferencia = TF.IdTransfer
         --     JOIN dbo.FI_Factura F ON TF.IdFactura = F.IdFactura
         --                              AND TR.IdContrato = F.IdContrato
         --     JOIN dbo.CO_Registro R ON R.IdFactura = F.IdFactura
         --     JOIN dbo.CO_LineaPresupuestoMes LPM ON R.IdPrograma = LPM.IdLineaPresupuestoMes
         --     JOIN dbo.CO_Presupuesto P ON P.IdPresupuesto = LPM.IdPresupuesto
         --     JOIN dbo.CO_AnioContractual AC ON AC.IdAnioContractual = P.IdAnioContractual
         --     JOIN dbo.CO_Contrato C ON AC.IdContrato = C.IdContrato
         --     JOIN dbo.CO_Contratista CON ON C.IdContratista = CON.IdContratista
         --     JOIN dbo.CO_Servicio SER ON SER.IdServicio = LPM.IdServicio
         --                                 AND SER.IdContrato = C.IdContrato
         --     JOIN dbo.PV_TipoMoneda TM ON F.IdMoneda = TM.IdMoneda
         --     LEFT JOIN dbo.CO_TipoCambioDiario TCD ON TCD.IdMoneda = TM.IdMoneda
         --                                              AND DAY(TCD.Fecha) = DAY(F.Fecha)
         --                                              AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
         --                                              AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
         --WHERE C.IdContrato = @Contrato
         --      AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
         --      AND R.IdEstado = 10004
         --      AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
         --      AND SER.NombreServicio NOT LIKE '%No elegibles%'
         --      AND (F.MetodoPago NOT LIKE '%exhibi%'
         --           OR F.MetodoPago NOT LIKE '%PUE%'
         --           OR F.FormaPago NOT LIKE '%exhibi%'
         --           OR F.FormaPago NOT LIKE '%PUE%')
         ----AND P.IdPresupuesto = @IdPresupuesto
         --GROUP BY F.IdFactura,
         --         F.IdContrato,
         --         F.ArchivoXML;

     END;
