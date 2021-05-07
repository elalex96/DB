-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-10-02
-- Description:	
-- =============================================
create PROCEDURE [dbo].[SP_SE_A5]
-- [SP_SE_A5] 10018,1,10079,'2019-01-01','2019-12-01'  
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
  
         SELECT ROW_NUMBER() OVER(ORDER BY R.Comentarios) AS NoCapacitacion,   
                R.Comentarios AS Descripcion,   
                S.RazonSocial AS RazonSocial,   
                S.RFC AS RFC,   
                SUM(
					CASE WHEN F.IdMoneda = 1 
								THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0)), 2) AS DECIMAL(20, 2))
								ELSE CAST([dbo].[FN_PesosDolaresTipoCambio](R.MontoRegistro,F.Fecha) AS DECIMAL(20, 2))
							END
				) AS SubTotal,   
                R.PCN AS PCN,   
                F.IdFactura,   
                R.IdAceptacionPedidoDetalle  
         INTO #DATOS  
         FROM dbo.CO_Registro R  
              JOIN dbo.FI_Factura F ON R.IdFactura = F.IdFactura  
              JOIN dbo.PV_Subcontratista S ON F.IdSubcontratista = S.IdSubcontratista  
              JOIN dbo.CO_LineaPresupuestoMes L ON R.IdPrograma = L.IdLineaPresupuestoMeS  
              JOIN #Presupuestos PP ON L.IdPresupuesto = PP.IdPresupuesto  
              JOIN dbo.CO_Presupuesto P ON PP.IdPresupuesto = P.IdPresupuesto  
              JOIN dbo.CO_ProgramaActividad PA ON P.IdProgramaActividad = PA.IdProgramaActividad  
              JOIN dbo.CO_TipoProgramaActividad TPA ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad  
              
         WHERE(CAST(F.Fecha AS DATE) >= @FInicio  
               AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin))  
              AND R.IdGastoRubro = 4  
              AND S.RFC NOT IN  
         (  
             SELECT RFC  
             FROM #RFC  
         )  
              AND F.IdContrato = @IdContrato  
              AND ISNULL(R.PCN, 0) <> 0  
              AND F.IdMoneda IN(1, 2)  
         GROUP BY R.Comentarios,   
                  S.RazonSocial,   
                  S.RFC,   
                  R.PCN,   
                  F.IdFactura,   
                  R.IdAceptacionPedidoDetalle  
         ORDER BY F.IdFactura;  
  
         /*SELECT FINAL*/  
  
         SELECT NoCapacitacion,   
                Descripcion,   
                RazonSocial,   
                RFC,   
                ISNULL(CAST(SUM(SubTotal) AS DECIMAL(20, 2)),0) AS SubTotal,   
                ISNULL(CAST(SUM(PCN) / COUNT(IdFactura) AS DECIMAL(20, 3)),0) AS PCN,   
                ISNULL(CAST(CAST(SUM(SubTotal) AS DECIMAL(20, 2)) * CAST(SUM(PCN) / COUNT(IdFactura) AS DECIMAL(20, 3)) AS DECIMAL(20, 2)),0) AS CN,   
                IdFactura  
         FROM #DATOS  
         GROUP BY NoCapacitacion,   
                  Descripcion,   
                  RazonSocial,   
                  RFC,   
                  IdFactura;  
     END;