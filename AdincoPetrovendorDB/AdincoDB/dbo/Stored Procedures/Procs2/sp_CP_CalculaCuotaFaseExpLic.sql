CREATE PROCEDURE [dbo].[sp_CP_CalculaCuotaFaseExpLic]  
-- Add the parameters for the stored procedure here  
@IdContrato INT  = 0,  
@Periodo    DATE  
AS  
     BEGIN  
-- =============================================  
-- Author:  Miguel Gomez  
-- Create date:   
-- Description:   
-- =============================================  
   -- SET NOCOUNT ON added to prevent extra result sets from-- interfering with SELECT statements.  
    SET NOCOUNT ON  
  
   DECLARE @TienePlanDesarrrollo INT = 0  
  
 SELECT  
  @TienePlanDesarrrollo = COUNT(1)  
 FROM  
  CO_Presupuesto P  
 JOIN  
  CO_ProgramaActividad PA  
  ON P.IdProgramaActividad = PA.IdProgramaActividad  
 JOIN  
  CO_PeriodoContrato PC  
  ON PA.IdPeriodoContrato = PC.IdPeriodo  
 JOIN  
  CO_TipoProgramaActividad TPA  
  ON PA.IdTIpoProgramaActividad = TPA.IdTIpoProgramaActividad  
 WHERE  
  PC.IdContrato = @IdContrato  
  AND  
  @Periodo BETWEEN PC.Inicio AND PC.Fin  
  AND  
  TPA.TipoPrograma = 'Plan Desarrollo'  
  
 IF @TienePlanDesarrrollo = 0  
 BEGIN  
         -- Insert statements for procedure here  
         SELECT CASE   
                   WHEN YEAR(@Periodo) = 2015  
                    THEN 1150  
                   WHEN YEAR(@Periodo) = 2016  
                    THEN 1175.42  
                   WHEN YEAR(@Periodo) = 2017  
                    THEN 1214.20  
                   WHEN YEAR(@Periodo) = 2018  
                    THEN 1294.71  
				   WHEN YEAR(@Periodo) = 2019  
				 THEN 1355.82  
				  WHEN YEAR(@Periodo) = 2020  
				 THEN 1396.09  
				  WHEN YEAR(@Periodo) = 2021  and DATEDIFF(YEAR, C.FechaFirma, @Periodo) <= 5
				 THEN 1442.58  
				 WHEN YEAR(@Periodo) = 2021  and DATEDIFF(YEAR, C.FechaFirma, @Periodo) > 5 
					THEN 3449.63
				WHEN YEAR(@Periodo) = 2022  and DATEDIFF(YEAR, C.FechaFirma, @Periodo) <= 5
				 THEN 1548.88  
				 WHEN YEAR(@Periodo) = 2022  and DATEDIFF(YEAR, C.FechaFirma, @Periodo) > 5 
					THEN 3703.86
			WHEN YEAR(@Periodo) = 2023  and DATEDIFF(YEAR, C.FechaFirma, @Periodo) <= 5
				 THEN 1669.53  
				 WHEN YEAR(@Periodo) = 2023  and DATEDIFF(YEAR, C.FechaFirma, @Periodo) > 5 
					THEN 3992.39
                 ELSE 1669.53 
                END AS CuotaKm2,  
                AC.SuperficieKm2,  
                CASE 
                   WHEN YEAR(@Periodo)  = 2015  
                    THEN 1150 * AC.SuperficieKm2  
                   WHEN YEAR(@Periodo)  = 2016  
                    THEN 1175.42 * AC.SuperficieKm2  
                   WHEN YEAR(@Periodo)  = 2017  
                    THEN 1214.20 * AC.SuperficieKm2  
				   WHEN YEAR(@Periodo)  = 2018  
				 THEN 1294.71 * AC.SuperficieKm2  
				   WHEN YEAR(@Periodo)  = 2019  
				 THEN 1355.82 * AC.SuperficieKm2  
				   WHEN YEAR(@Periodo)  = 2020  and DATEDIFF(YEAR, C.FechaFirma, @Periodo) <= 5
				 THEN 1396.09  * AC.SuperficieKm2  
				  WHEN YEAR(@Periodo)  = 2021  and DATEDIFF(YEAR, C.FechaFirma, @Periodo) <= 5
				 THEN 1442.58  * AC.SuperficieKm2  
				  WHEN YEAR(@Periodo)  = 2021 AND DATEDIFF(YEAR, C.FechaFirma, @Periodo) > 5 
				  THEN 3449.63 * AC.SuperficieKm2
				  WHEN YEAR(@Periodo)  = 2022  and DATEDIFF(YEAR, C.FechaFirma, @Periodo) <= 5
				 THEN 1548.88  * AC.SuperficieKm2  
				  WHEN YEAR(@Periodo)  = 2022 AND DATEDIFF(YEAR, C.FechaFirma, @Periodo) > 5 
				  THEN 3703.86 * AC.SuperficieKm2
				  WHEN YEAR(@Periodo)  = 2023  and DATEDIFF(YEAR, C.FechaFirma, @Periodo) <= 5
				 THEN 1669.53  * AC.SuperficieKm2  
				  WHEN YEAR(@Periodo)  = 2023 AND DATEDIFF(YEAR, C.FechaFirma, @Periodo) > 5 
				  THEN 3992.39 * AC.SuperficieKm2 
				   ELSE 1669.53 * AC.SuperficieKm2
                END AS Cuota  
         FROM CO_AreaContractual AC  
              JOIN co_contrato C ON c.IdAreaContractual = AC.IdAreaContractual  
         WHERE C.IdContrato = @IdContrato  
  END  
 ELSE -- YA TIENE PLAN DE DESARROLLO APROBADO  
 BEGIN  
  SELECT  
   0 AS CuotaKm2,  
   AC.SuperficieKm2,  
   0 AS Cuota  
  FROM  
   CO_AreaContractual AC  
        JOIN co_contrato C ON c.IdAreaContractual = AC.IdAreaContractual  
        WHERE C.IdContrato = @IdContrato  
 END  
END
