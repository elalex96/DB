-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-10-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_SE_A7]
-- [SP_SE_A7] 10018,1,10079,'2019-01-01','2019-12-01'
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

         SELECT ROW_NUMBER() OVER(ORDER BY R.Comentarios) AS NoGasto, 
                R.Comentarios AS Descripcion, 
                SUM(CAST(R.MontoRegistro * TCD.TipoCambio AS DECIMAL(20, 2))) AS SubTotal
         FROM dbo.CO_Registro R
              JOIN dbo.FI_Factura F ON R.IdFactura = F.IdFactura
              JOIN dbo.PV_Subcontratista S ON F.IdSubcontratista = S.IdSubcontratista
              JOIN dbo.CO_LineaPresupuestoMes L ON R.IdPrograma = L.IdLineaPresupuestoMeS
              JOIN #Presupuestos PP ON L.IdPresupuesto = PP.IdPresupuesto
              JOIN dbo.CO_Presupuesto P ON PP.IdPresupuesto = P.IdPresupuesto
              JOIN dbo.CO_ProgramaActividad PA ON P.IdProgramaActividad = PA.IdProgramaActividad
              JOIN dbo.CO_TipoProgramaActividad TPA ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
              JOIN dbo.CO_TipoCambioDiario TCD ON F.IdMoneda <> TCD.IdMoneda
                                                  AND DAY(TCD.Fecha) = DAY(F.Fecha)
                                                  AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                                  AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
         WHERE(CAST(F.Fecha AS DATE) >= @FInicio
               AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin))
              AND R.IdGastoRubro = 6
              AND S.RFC NOT IN
         (
             SELECT RFC
             FROM #RFC
         )
              AND ISNULL(R.PCN, 0) <> 0
              AND TCD.IdMoneda IN(1, 2)
         GROUP BY R.Comentarios;
     END;