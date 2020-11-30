-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-10-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_SE_A3]
-- [SP_SE_A3] 10018,1,10079,'2019-01-01','2019-12-01'
-- Add the parameters for the stored procedure here
@IdContrato    INT, 
@IdUsuario     INT, 
@IdPresupuesto INT, 
@FInicio       DATE, 
@FFin          DATE
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         CREATE TABLE #Presupuestos(IdPresupuesto INT);
         CREATE TABLE #RFC(RFC VARCHAR(25));

         /**/

         --IF 1 =
         --(
         --    SELECT COUNT(1)
         --    FROM dbo.CO_Presupuesto P
         --         JOIN dbo.CO_AnioContractual AC ON P.IdAnioContractual = AC.IdAnioContractual
         --         JOIN dbo.CO_Contrato C ON AC.IdContrato = C.IdContrato
         --    WHERE P.idpresupuesto = @IdPresupuesto
         --          AND P.nombre LIKE '%provisional%'
         --          AND C.IdContratista IN(10005, 10006)
         --)
         --    BEGIN
         --        INSERT INTO #Presupuestos(IdPresupuesto)
         --               SELECT P.IdPresupuesto
         --               FROM dbo.CO_Presupuesto P
         --                    JOIN dbo.CO_AnioContractual AC ON P.IdAnioContractual = AC.IdAnioContractual
         --                    JOIN dbo.CO_Contrato C ON AC.IdContrato = C.IdContrato
         --               WHERE C.IdContrato = @IdContrato
         --                     AND P.nombre LIKE '%provisional%'
         --                     AND C.IdContratista IN(10005, 10006);
         --    END;
         IF 1 =
         (
             SELECT COUNT(1)
             FROM dbo.CO_Presupuesto P
                  JOIN dbo.CO_AnioContractual AC ON P.IdAnioContractual = AC.IdAnioContractual
                  JOIN dbo.CO_Contrato C ON AC.IdContrato = C.IdContrato
             WHERE P.idpresupuesto = @IdPresupuesto
                   AND P.nombre LIKE '%exploración%'
                   AND C.IdContratista IN(10005, 10006)
         )
             BEGIN
                 INSERT INTO #Presupuestos(IdPresupuesto)
                        SELECT P.IdPresupuesto
                        FROM dbo.CO_Presupuesto P
                             JOIN dbo.CO_AnioContractual AC ON P.IdAnioContractual = AC.IdAnioContractual
                             JOIN dbo.CO_Contrato C ON AC.IdContrato = C.IdContrato
                        WHERE C.IdContrato = @IdContrato
                              AND P.nombre LIKE '%exploración%'
                              AND C.IdContratista IN(10005, 10006);
             END;
             ELSE
             BEGIN
                 INSERT INTO #Presupuestos(IdPresupuesto)
             SELECT @IdPresupuesto;
             END;

         /**/

         INSERT INTO #RFC(RFC)
                SELECT 'FMP140930MW3'
                UNION
                SELECT 'SAT970701NN3';
         IF 1 =
         (
             SELECT COUNT(1)
             FROM dbo.CO_Presupuesto P
                  JOIN dbo.CO_AnioContractual AC ON P.IdAnioContractual = AC.IdAnioContractual
                  JOIN dbo.CO_Contrato C ON AC.IdContrato = C.IdContrato
             WHERE P.idpresupuesto = @IdPresupuesto
                   AND C.IdContratista IN(10005, 10006)
         )
             BEGIN
                 INSERT INTO #RFC(RFC)
                        SELECT 'FMO930803PB1'
                        UNION
                        SELECT 'GMS971110BTA';
             END;

         /*Consulta final*/

         IF(@FFin <= '2018-12-01')
             BEGIN
                 SELECT ISNULL(A.Codigo, 'SinClasificar') AS Codigo, 
                        R.Comentarios AS Descripcion, 
                        S.RazonSocial AS RazonSocial, 
                        S.RFC AS RFC, 
                        SUM(CAST(ROUND((ISNULL(R.MontoRegistro, 0) * TCD.TipoCambio), 2) AS DECIMAL(20, 2))) AS SubTotal, 
                        ISNULL(R.PCN, 0) AS PCN, 
                        SUM(CAST(ROUND((ISNULL((ISNULL(R.PCN, 0) * R.MontoRegistro), 0) * TCD.TipoCambio), 2) AS DECIMAL(20, 2))) AS CN, 
                        ROW_NUMBER() OVER(ORDER BY F.IdFactura) AS ID, 
                        ROW_NUMBER() OVER(PARTITION BY F.IdFactura, 
                                                       S.RFC ORDER BY R.Comentarios) AS Repetido, 
                        F.IdFactura
                 FROM dbo.CO_Registro R
                      JOIN dbo.CO_LineaPresupuestoMes L ON L.IdLineaPresupuestoMes = R.IdPrograma
                      JOIN #Presupuestos PP ON L.IdPresupuesto = PP.IdPresupuesto
                      JOIN dbo.CO_Presupuesto P ON P.IdPresupuesto = PP.IdPresupuesto
                      JOIN dbo.CO_ProgramaActividad PA ON PA.IdProgramaActividad = P.IdProgramaActividad
                      JOIN dbo.CO_TipoProgramaActividad TPA ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
                      LEFT JOIN dbo.CO_PCNPorPeriodos PPP ON PPP.IdTipoPgrogramaActividad = TPA.IdTipoProgramaActividad
                      LEFT JOIN dbo.FI_Factura F ON F.IdFactura = R.IdFactura
                      LEFT JOIN dbo.CO_TipoCambioDiario TCD ON F.IdMoneda <> TCD.IdMoneda
                                                               AND DAY(TCD.Fecha) = DAY(F.Fecha)
                                                               AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                                               AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
                      LEFT JOIN dbo.PV_Subcontratista S ON S.IdSubcontratista = F.IdSubcontratista
                      LEFT JOIN dbo.MM_BS_Actividad A ON R.IdCBSISH = A.IdActividad
                      LEFT JOIN dbo.CO_Servicio SE ON SE.IdServicio = L.IdServicio
                 WHERE(CAST(F.Fecha AS DATE) >= @FInicio
                       AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin))
                      AND R.IdGastoRubro = 3
                      AND S.RFC NOT IN
                 (
                     SELECT RFC
                     FROM #RFC
                 )
                      AND F.IdContrato = @IdContrato
                      AND ISNULL(R.PCN, 0) <> 0
                      AND PPP.IdContrato = @IdContrato
                 GROUP BY ISNULL(A.Codigo, 'SinClasificar'), 
                          R.Comentarios, 
                          S.RazonSocial, 
                          S.RFC, 
                          --CAST(ROUND((ISNULL(R.MontoRegistro, 0) * TCD.TipoCambio), 2) AS DECIMAL(20, 2)), 
                          ISNULL(R.PCN, 0), 
                          --CAST(ROUND((ISNULL((ISNULL(R.PCN, 0) * R.MontoRegistro), 0) * TCD.TipoCambio), 2) AS DECIMAL(20, 2)), 
                          F.IdFactura
                 ORDER BY S.RFC;
             END;
             ELSE
             BEGIN
                 CREATE TABLE #DATOS
                 (Codigo                    VARCHAR(50), 
                  Descripcion               VARCHAR(300), 
                  RazonSocial               VARCHAR(300), 
                  RFC                       VARCHAR(100), 
                  SubTotal                  FLOAT, 
                  SubTotalOriginal          FLOAT, 
                  PCN                       FLOAT, 
                  IdFactura                 INT, 
                  IdAceptacionPedidoDetalle INT
                 )
                 INSERT INTO #DATOS
                 (Codigo, 
                  Descripcion, 
                  RazonSocial, 
                  RFC, 
                  SubTotal, 
                  SubTotalOriginal, 
                  PCN, 
                  IdFactura, 
                  IdAceptacionPedidoDetalle
                 )
                 SELECT ISNULL(A.Codigo, 'SinClasificar') AS Codigo, 
                        ISNULL(A.Nombre, 'SinClasificar') AS Descripcion, 
                        S.RazonSocial AS RazonSocial, 
                        S.RFC AS RFC, 
                        CAST(R.MontoRegistro * TCD.TipoCambio AS DECIMAL(20, 2)) AS SubTotal, 
                        F.SubTotal AS SubTotalOriginal, 
                        R.PCN AS PCN, 
                        F.IdFactura, 
                        R.IdAceptacionPedidoDetalle
                 FROM dbo.CO_Registro R
                      JOIN dbo.FI_Factura F ON R.IdFactura = F.IdFactura
                      JOIN dbo.PV_Subcontratista S ON F.IdSubcontratista = S.IdSubcontratista
                                                      AND S.TipoPersonaFiscalID = 2
                      JOIN dbo.CO_LineaPresupuestoMes L ON R.IdPrograma = L.IdLineaPresupuestoMeS
                      JOIN #Presupuestos PP ON L.IdPresupuesto = PP.IdPresupuesto
                      JOIN dbo.CO_Presupuesto P ON PP.IdPresupuesto = P.IdPresupuesto
                      JOIN dbo.CO_ProgramaActividad PA ON P.IdProgramaActividad = PA.IdProgramaActividad
                      JOIN dbo.CO_TipoProgramaActividad TPA ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
                      JOIN dbo.CO_TipoCambioDiario TCD ON F.IdMoneda <> TCD.IdMoneda
                                                          AND DAY(TCD.Fecha) = DAY(F.Fecha)
                                                          AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                                          AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
                      LEFT JOIN dbo.MM_BS_Actividad A ON R.IdCBSISH = A.IdActividad
                 WHERE(CAST(F.Fecha AS DATE) >= @FInicio
                       AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin))
                      AND R.IdGastoRubro = 3
                      AND S.RFC NOT IN
                 (
                     SELECT RFC
                     FROM #RFC
                 )
                      AND F.IdContrato = @IdContrato
                      AND ISNULL(R.PCN, 0) <> 0
                      AND TCD.IdMoneda IN(1, 2)
                 --
                 UNION
                 --
                 SELECT ISNULL(A.Codigo, 'SinClasificar') AS Codigo, 
                        ISNULL(A.Nombre, 'SinClasificar') AS Descripcion, 
                        S.RazonSocial AS RazonSocial, 
                        S.RFC AS RFC, 
                        CAST(F.SubTotal * TCD.TipoCambio AS DECIMAL(20, 2)) AS SubTotal, 
                        F.SubTotal AS SubTotalOriginal, 
                        R.PCN AS PCN, 
                        F.IdFactura, 
                        R.IdAceptacionPedidoDetalle
                 FROM dbo.CO_Registro R
                      JOIN dbo.FI_Factura F ON R.IdFactura = F.IdFactura
                      JOIN dbo.PV_Subcontratista S ON F.IdSubcontratista = S.IdSubcontratista
                                                      AND S.TipoPersonaFiscalID = 1
                      JOIN dbo.CO_LineaPresupuestoMes L ON R.IdPrograma = L.IdLineaPresupuestoMeS
                      JOIN #Presupuestos PP ON L.IdPresupuesto = PP.IdPresupuesto
                      JOIN dbo.CO_Presupuesto P ON PP.IdPresupuesto = P.IdPresupuesto
                      JOIN dbo.CO_ProgramaActividad PA ON P.IdProgramaActividad = PA.IdProgramaActividad
                      JOIN dbo.CO_TipoProgramaActividad TPA ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
                      JOIN dbo.CO_TipoCambioDiario TCD ON F.IdMoneda <> TCD.IdMoneda
                                                          AND DAY(TCD.Fecha) = DAY(F.Fecha)
                                                          AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                                          AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
                      LEFT JOIN dbo.MM_BS_Actividad A ON R.IdCBSISH = A.IdActividad
                 WHERE(CAST(F.Fecha AS DATE) >= @FInicio
                       AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin))
                      AND R.IdGastoRubro = 3
                      AND S.RFC NOT IN
                 (
                     SELECT RFC
                     FROM #RFC
                 )
                      AND F.IdContrato = @IdContrato
                      AND ISNULL(R.PCN, 0) <> 0
                      AND TCD.IdMoneda IN(1, 2)
                 ORDER BY ISNULL(A.Nombre, 'SinClasificar');

                 /*SELECT FINAL*/

                 SELECT Codigo, 
                        Descripcion, 
                        RazonSocial, 
                        RFC, 
                        SUM(SubTotal) AS SubTotal, 
                        SUM(SubTotal * PCN) AS PCN, 
                        IdFactura
                 INTO #FINAL
                 FROM #DATOS
                 GROUP BY Codigo, 
                          Descripcion, 
                          RazonSocial, 
                          RFC, 
                          IdFactura;

                 /**/

                 SELECT Codigo, 
                        Descripcion, 
                        RazonSocial, 
                        RFC, 
                        SUM(SubTotal) AS SubTotal, 
                        CAST(SUBSTRING(LTRIM(SUM(PCN)/SUM(SubTotal)), 1, CHARINDEX('.', LTRIM(SUM(PCN)/SUM(SubTotal)))+3) AS FLOAT) AS PCN, 
                        (SUM(SubTotal)*CAST(SUBSTRING(LTRIM(SUM(PCN)/SUM(SubTotal)), 1, CHARINDEX('.', LTRIM(SUM(PCN)/SUM(SubTotal)))+3) AS FLOAT)) AS CN, 
                        IdFactura
                 FROM #FINAL
                 GROUP BY Codigo, 
                          Descripcion, 
                          RazonSocial, 
                          RFC, 
                          IdFactura
                 ORDER BY RazonSocial, 
                          Descripcion, 
                          IdFactura
             END;
     END;