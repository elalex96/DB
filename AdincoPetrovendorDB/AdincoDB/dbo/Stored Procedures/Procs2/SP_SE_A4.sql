
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-10-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_SE_A4]
-- [SP_SE_A4] 10018,1,10079,'2019-01-01','2019-12-01'  
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
  
         SELECT SUM(
					CASE WHEN f.IdMoneda <> 1 then CAST([dbo].[FN_DolaresPesosTipoCambio](R.MontoRegistro,f.Fecha) AS DECIMAL(20,2))
							ELSE ISNULL(R.MontoRegistro,0) 
						END
				) AS SueldosSalarios,   
                SUM(
					CASE WHEN f.IdMoneda <> 1 then CAST([dbo].[FN_DolaresPesosTipoCambio](R.MontoRegistro,f.Fecha) AS DECIMAL(20,2))
							ELSE ISNULL(R.MontoRegistro,0) 
						END * CAST(PCN AS DECIMAL(20, 3))					
				) AS SueldosSalariosNacional,   
                R.IdGastoRubro  
         INTO #DATOS  
         FROM dbo.CO_Registro R  
              JOIN dbo.FI_Factura F ON R.IdFactura = F.IdFactura  
              JOIN dbo.PV_Subcontratista S ON F.IdSubcontratista = S.IdSubcontratista  
              JOIN dbo.CO_LineaPresupuestoMes L ON R.IdPrograma = L.IdLineaPresupuestoMes  
              JOIN #Presupuestos PP ON L.IdPresupuesto = PP.IdPresupuesto  
              JOIN dbo.CO_Presupuesto P ON PP.IdPresupuesto = P.IdPresupuesto  
              JOIN dbo.CO_ProgramaActividad PA ON P.IdProgramaActividad = PA.IdProgramaActividad  
              JOIN dbo.CO_TipoProgramaActividad TPA ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad  
             
         WHERE(CAST(F.Fecha AS DATE) >= @FInicio  
               AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin))  
              AND R.IdGastoRubro = 1  
              AND S.RFC NOT IN  
         (  
             SELECT RFC  
             FROM #RFC  
         )  
              AND F.IdContrato = @IdContrato  
              AND ISNULL(R.PCN, 0) <> 0  
              AND F.IdMoneda IN(1, 2)  
         GROUP BY R.IdGastoRubro;  
  
         /**/  
  
         SELECT ISNULL(CAST(ISNULL(D.SueldosSalarios, 0) AS DECIMAL(20, 2)),0) AS SueldosSalarios,   
                ISNULL(CAST(ISNULL(D.SueldosSalariosNacional, 0) AS DECIMAL(20, 2)),0) AS SueldosSalariosNacional,   
                GR.IdGastoRubro  
         FROM #DATOS D  
              RIGHT JOIN dbo.CO_GastosRubro GR ON D.IdGastoRubro = GR.IdGastoRubro  
         WHERE GR.IdGastoRubro NOT IN(6, 7)  
         ORDER BY GR.IdGastoRubro DESC;  
     END;