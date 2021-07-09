USE ADINCO;
GO
CREATE  PROCEDURE [dbo].[SP_ObtenProduccionDiariaPozoMes]--10036,10061,'20200501'
@IdContrato    INT,     
@IdUsuario     INT, 
@Fecha		   DATETIME
AS    
     BEGIN  
	      
         SET NOCOUNT ON; 

		 CREATE TABLE #Informacion(
				 Pozo VARCHAR(300),
				 AceiteBrutoProd FLOAT,
				 AceiteNetoProd FLOAT,
				 GasProd FLOAT,
				 AguaProdBD FLOAT,
				 AguaProdPorcentaje FLOAT); 
		
		 DECLARE @CantidadDias INT;

		 SELECT @CantidadDias = DAY(EOMONTH(@Fecha));

		 INSERT INTO #Informacion(Pozo, AceiteBrutoProd,AceiteNetoProd,GasProd,AguaProdBD,AguaProdPorcentaje)
		 SELECT 
			 P.Nombre, 
			 ROUND(SUM(ROUND(ISNULL(PDP.ProdPetroleoBruto,0),3))/@CantidadDias, 3) AS AceiteBrutoProd ,
			 ROUND(SUM(ROUND(ISNULL(PDP.ProdAceiteNeto,0),3))/@CantidadDias, 3) AS AceiteNetoProd,
			 ROUND(SUM(ROUND(ISNULL(PDP.GastoGas,0),3))/@CantidadDias, 3) AS GasProd,
			 ROUND(SUM(ROUND(ISNULL(PDP.Agua,0),3))/@CantidadDias, 3) AS AguaProdBD, 
			 CASE
				WHEN ROUND(SUM(ROUND(ISNULL(PDP.Agua,0),3))/@CantidadDias,3) > 0
			 THEN
			ROUND((ROUND(SUM(ROUND(ISNULL(PDP.ProdPetroleoBruto,0),3))/@CantidadDias,3)/ROUND(SUM(ROUND(ISNULL(PDP.Agua,0),3))/@CantidadDias,3) * 100),3)
			 ELSE
				0
			END	AS	AguaProdPorcentaje
				FROM
					dbo.CO_Contrato C  
				JOIN  
					dbo.CO_Instalacion I  
					ON C.IdContrato	=	@IdContrato
					AND
					C.IdAreaContractual	=	I.IdAreaContractual  
				JOIN  
					dbo.PR_Pozo	P  
					ON I.WelIID = P.Id  
				JOIN  
					dbo.PR_ProdDiariaPozo_Previo PDP  
					ON P.Id = PDP.Pozo
				WHERE  
					DATEFROMPARTS(YEAR(PDP.FECHA),MONTH(PDP.FECHA),01) = @Fecha
					AND	I.Activo = 1  
				GROUP BY  P.Nombre;


		 SELECT * FROM #Informacion;
END;


