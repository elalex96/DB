
-- =============================================
-- Author:Yazmin Glez.
-- Create date:2017-11-28
-- Description:Reporte de CGI - Registro de CFDIs Relacionados_CONT_23_M
-- Modificado: Reyna Olvera
-- Fecha Modificado: 20180625
-- Description: Se modifico para que  solo muestre los que tengan Tipo Relacion 01,02,07 y que el numero de parcialidad si es null sea 0
-- Modificado: Manuel Cruz
-- Fecha Modificado: 2019-07-01
-- Description: Cambio para mostrar la relacion del principal con el complemento de pago
-- Modificado:       Marcos Garcia
-- Fecha Modificado: 2020-01-13
-- Description:     *Agregar Validacion de @IdPresupuesto = 0
--                  *Agregar WITH (NOLOCK) en las tablas 
-- =============================================

CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_23_M]
-- [SIPAC_RC_CONT_23_M] 10011,'2019-06-01',1
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT  = 0
AS
     BEGIN
         SET NOCOUNT ON;
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

         SELECT LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00], 
                LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00], 
                C.NumeroContrato AS [RF01_01], 
                MONTH(R.MesPresentacion) AS [RC23_00], 
                YEAR(R.MesPresentacion) AS [RC23_01], 
                F.UUID AS [RC23_02], 
                FR.UUID AS [RC23_03], 
                FR.TipoRelacion AS [RC23_04], 
                ISNULL(FR.NoParcialidad, 0) AS [RC23_05]
         FROM dbo.FI_Transfer TR WITH(NOLOCK)
              JOIN dbo.FI_TransferFactura TF WITH(NOLOCK) ON TR.IdTransferencia = TF.IdTransfer
              JOIN dbo.FI_Factura F WITH(NOLOCK) ON TF.IdFactura = F.IdFactura
              JOIN dbo.CO_Registro R WITH(NOLOCK) ON R.IdFactura = F.IdFactura
              JOIN dbo.CO_LineaPresupuestoMes LPM WITH(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
              JOIN dbo.CO_Presupuesto P WITH(NOLOCK) ON P.IdPresupuesto = LPM.IdPresupuesto
              JOIN dbo.CO_AnioContractual AC WITH(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
              JOIN dbo.CO_Contrato C WITH(NOLOCK) ON AC.IdContrato = C.IdContrato
              JOIN dbo.CO_Contratista CON WITH(NOLOCK) ON C.IdContratista = CON.IdContratista
              LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = F.IdMoneda
                                                                    AND DAY(TCD.Fecha) = DAY(TR.FechaPago)
                                                                    AND MONTH(TCD.Fecha) = MONTH(TR.FechaPago)
                                                                    AND YEAR(TCD.Fecha) = YEAR(TR.FechaPago)
              LEFT JOIN dbo.CO_Servicio SER WITH(NOLOCK) ON SER.IdServicio = LPM.IdServicio
                                                            AND SER.IdContrato = C.IdContrato
              JOIN dbo.FI_CFDIRelacionados FR WITH(NOLOCK) ON FR.CFDIId = F.IdFactura
         WHERE C.IdContrato = @Contrato
               AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
               AND R.IdEstado = 10004
               AND R.CvTipoDocFacturacion = 1
               AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
               AND FR.TipoRelacion IN(01, 02, 07)
              AND SER.NombreServicio NOT LIKE '%No elegibles%'
              AND (F.TipoComprobante LIKE '%egreso%'
                   OR F.TipoComprobante LIKE 'E%')
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
         )
              AND P.IdPresupuesto = CASE
                                        WHEN @IdPresupuesto = 0
                                        THEN LPM.IdPresupuesto
                                        ELSE @IdPresupuesto
                                    END
         GROUP BY LTRIM(RTRIM(CON.IDSIPAC)), 
                  LTRIM(RTRIM(C.IDRegFiducidiario)), 
                  MONTH(R.MesPresentacion), 
                  YEAR(R.MesPresentacion), 
                  ISNULL(FR.NoParcialidad, 0), 
                  C.NumeroContrato, 
                  F.UUID, 
                  FR.UUID, 
                  FR.TipoRelacion
         --
         UNION
         --
         SELECT LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00], 
                LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00], 
                C.NumeroContrato AS [RF01_01], 
                MONTH(R.MesPresentacion) AS [RC23_00], 
                YEAR(R.MesPresentacion) AS [RC23_01], 
                FCP.UUID AS [RC23_02],
                CASE
                    WHEN FCP.TipoComprobante = 'P'
                    THEN FCPDR.UUID
                    ELSE FCP.UUID
                END AS [RC23_03], 
                '07' AS [RC23_04], 
                MAX(CASE
                        WHEN FCP.TipoComprobante = 'P'
                        THEN CPDR.NumParcialidad
                        ELSE 0
                    END) AS [RC23_05]
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
              LEFT JOIN dbo.CO_TipoCambioDiario TCD WITH(NOLOCK) ON TCD.IdMoneda = FCPDR.IdMoneda
                                                                    AND DAY(TCD.Fecha) = DAY(TR.FechaPago)
                                                                    AND MONTH(TCD.Fecha) = MONTH(TR.FechaPago)
                                                                    AND YEAR(TCD.Fecha) = YEAR(TR.FechaPago)
              LEFT JOIN dbo.CO_Servicio SER ON SER.IdServicio = LPM.IdServicio
                                               AND SER.IdContrato = C.IdContrato
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
                  MONTH(R.MesPresentacion), 
                  YEAR(R.MesPresentacion),
                  CASE
                      WHEN FCP.TipoComprobante = 'P'
                      THEN FCPDR.UUID
                      ELSE FCP.UUID
                  END, 
                  C.NumeroContrato, 
                  FCP.UUID;
     END;
