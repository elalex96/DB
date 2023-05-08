CREATE  PROCEDURE [dbo].[SP_ObtenProduccionConciliadaPozoMes]--10036,10061,'20200501'
@IdContrato    INT,     
@IdUsuario     INT, 
@Fecha		   DATETIME
AS    
     BEGIN     
	   
         SET NOCOUNT ON;

	 DECLARE	@FactorConverM3_MMPC FLOAT = 0.00003531467;
	 DECLARE @CantidadDias INT;

	 SELECT @CantidadDias = DAY(EOMONTH(@Fecha));

	 CREATE TABLE #Informacion(Pozo VARCHAR(150),
								 AceiteBrutoProd FLOAT,
								 AceiteNetoProd FLOAT,
								 GasProd FLOAT,
								 AguaProdBD FLOAT,
								 AguaProdPorcentaje FLOAT); 

	INSERT INTO #Informacion(Pozo, AceiteBrutoProd,AceiteNetoProd,GasProd,AguaProdBD,AguaProdPorcentaje)
	SELECT	P.Nombre AS Pozo,
			ROUND(SUM(ROUND(ISNULL(PDP.ProduccionReal,0),3))/@CantidadDias,3) AS	AceiteBrutoProd, -- dividirlo entre la cantidad de dias del mes
			ROUND(SUM(ROUND(ISNULL(PDP.ProduccionReal,0),3))/@CantidadDias,3)	AS	AceiteNetoProd,
			ROUND(SUM(ROUND(ISNULL(PDP.ProduccionRealGasM3,0),3) * @FactorConverM3_MMPC)/@CantidadDias ,3)	AS	GasProd,
			ROUND(SUM(ROUND(ISNULL(PDP.PctAguaControl,0),3))/@CantidadDias,3) AS	AguaProdBD,
			 CASE
				WHEN ROUND(SUM(ROUND(ISNULL(PDP.PctAguaControl,0),3))/@CantidadDias,3) > 0
			 THEN
				ROUND((ROUND(SUM(ROUND(ISNULL(PDP.ProduccionReal,0),3))/@CantidadDias,3)/ROUND(SUM(ROUND(ISNULL(PDP.PctAguaControl,0),3))/@CantidadDias,3) * 100),3)
			 ELSE
				0
			END	AS	AguaProdPorcentaje
			FROM
				dbo.CO_Contrato C  
			JOIN  
				 dbo.CO_Instalacion I  
				 ON C.IdContrato =  @IdContrato
			 AND
				C.IdAreaContractual = I.IdAreaContractual  
			JOIN  
				 dbo.PR_Pozo P  
				 ON I.WelIID = P.Id  
			JOIN  
				 dbo.PR_ProdDiariaPozo PDP  
				 ON P.Id = PDP.Pozo 
	WHERE  
			DATEFROMPARTS(YEAR(PDP.FECHA),MONTH(PDP.FECHA),01) = @Fecha
			AND	I.Activo = 1  
	GROUP BY  
		P.Nombre;

	SELECT * FROM #Informacion;
	
END;