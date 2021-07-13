USE ADINCO;
GO
CREATE  PROCEDURE [dbo].[SP_ObtenHistoricoDiarioConciliado]--10036,10061,'20200501'
@IdContrato    INT,     
@IdUsuario     INT, 
@Fecha		   DATETIME
AS    
     BEGIN       

         SET NOCOUNT ON; 

		DECLARE	@FactorConverM3_MMPC FLOAT = 0.00003531467;

		CREATE TABLE #Meses(Id int IDENTITY(1,1), Fecha DATE, CantidadDias INT)
		
		CREATE TABLE #InformacionDiaria(
									 Fecha DATE,
									 AceiteBrutoProd FLOAT,
									 AceiteNetoProd FLOAT,
									 GasProd FLOAT,
									 AguaProdBD FLOAT,
									 AguaProdPorcentaje FLOAT); 

		CREATE TABLE #InformacionConciliada(
									 Fecha DATE,
									 AceiteBrutoProd FLOAT,
									 AceiteNetoProd FLOAT,
									 GasProd FLOAT,
									 AguaProdBD FLOAT,
									 AguaProdPorcentaje FLOAT); 

		CREATE TABLE #InformacionResultado(
					Fecha DATE,
					Anio INT,
					Mes INT,
					AceiteBrutoProdDiaria FLOAT,
					AceiteNetoProdDiaria FLOAT,
					GasProdDiaria FLOAT,
					AguaProdDiariaBD FLOAT,
					AguaProdDiariaPorcentaje FLOAT,
					AceiteBrutoProdConc FLOAT,
					AceiteNetoProdConc FLOAT,
					GasConc FLOAT,
					AguaConcBD FLOAT,
					AguaConcPorcentaje FLOAT);
		
		INSERT INTO  #Meses(Fecha, CantidadDias)
		SELECT DISTINCT DATEFROMPARTS(YEAR(PDP.FECHA),MONTH(PDP.FECHA),01), DAY(EOMONTH(DATEFROMPARTS(YEAR(PDP.FECHA),MONTH(PDP.FECHA),01)))
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
				 C.IdContrato =  @IdContrato 
		 UNION
		 SELECT DISTINCT DATEFROMPARTS(YEAR(PDP.FECHA),MONTH(PDP.FECHA),01), DAY(EOMONTH(DATEFROMPARTS(YEAR(PDP.FECHA),MONTH(PDP.FECHA),01)))
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
				C.IdContrato =  @IdContrato
				AND	I.Activo = 1  

		INSERT INTO #InformacionConciliada(Fecha, AceiteBrutoProd,AceiteNetoProd,GasProd,AguaProdBD,AguaProdPorcentaje)	
		 SELECT	
			DATEFROMPARTS(YEAR(PDP.Fecha),MONTH(PDP.Fecha),01) AS Fecha,
			ROUND(SUM(ROUND(ISNULL(PDP.ProduccionReal,0),3))/M.CantidadDias,3) AS	AceiteBrutoProd,
			ROUND(SUM(ROUND(ISNULL(PDP.ProduccionReal,0),3))/M.CantidadDias,3)	AS	AceiteNetoProd,
			ROUND(SUM(ROUND(ISNULL(PDP.ProduccionRealGasM3,0),3) * @FactorConverM3_MMPC)/M.CantidadDias ,3)	AS	GasProd, --confirmar si es por días de mes(sum/dias del mes) o si es dias operado (AVG) -- es sobre los días del mes o los que se encuentran operando -> previo estatus operando o cerrado(PR_ProdDiariaPozo_Previo). para la producción conciliada si es por días operando se debe buscar en 
			ROUND(SUM(ROUND(ISNULL(PDP.PctAguaControl,0),3))/M.CantidadDias,3) AS	AguaProdBD,-- agua en diaria en bl
			 CASE
				WHEN ROUND(SUM(ROUND(ISNULL(PDP.PctAguaControl ,0),3))/M.CantidadDias,3) > 0
			 THEN
				ROUND(ROUND(SUM(ROUND(ISNULL(PDP.ProduccionReal,0),3))/M.CantidadDias,3)/ROUND(SUM(ROUND(ISNULL(PDP.PctAguaControl,0),3))/M.CantidadDias,3) * 100,3)
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
			JOIN
				#Meses M
				ON	DATEFROMPARTS(YEAR(PDP.FECHA),MONTH(PDP.FECHA),01) = M.Fecha
	WHERE  
		 C.IdContrato =  @IdContrato
	GROUP BY  
		DATEFROMPARTS(YEAR(PDP.FECHA),MONTH(PDP.FECHA),01), M.CantidadDias

		INSERT INTO #InformacionDiaria(Fecha, AceiteBrutoProd,AceiteNetoProd,GasProd,AguaProdBD,AguaProdPorcentaje)
		 SELECT 
			 DATEFROMPARTS(YEAR(PDP.Fecha),MONTH(PDP.Fecha),01) AS Fecha,
			 ROUND(SUM(ROUND(ISNULL(PDP.ProdPetroleoBruto,0),3))/M.CantidadDias, 3) AS AceiteBrutoProd ,
			 ROUND(SUM(ROUND(ISNULL(PDP.ProdAceiteNeto,0),3))/M.CantidadDias, 3) AS AceiteNetoProd,
			 ROUND(SUM(ROUND(ISNULL(PDP.GastoGas,0),3))/M.CantidadDias, 3) AS GasProd,
			 ROUND(SUM(ROUND(ISNULL(PDP.Agua,0),3))/M.CantidadDias, 3) AS AguaProdBD, 
			 CASE
				WHEN  ROUND(SUM(ROUND(ISNULL(PDP.Agua,0),3))/M.CantidadDias, 3) > 0
			 THEN
				ROUND(ROUND(SUM(ISNULL(PDP.ProdPetroleoBruto,0))/M.CantidadDias,3)/ROUND(SUM(ISNULL(PDP.Agua,0))/M.CantidadDias,3) * 100,3)
			 ELSE
				0
				END	AS AguaProdPorcentaje
				FROM
					dbo.CO_Contrato C  
				JOIN  
					dbo.CO_Instalacion I  
					ON C.IdContrato	=	 @IdContrato
					AND
					C.IdAreaContractual	=	I.IdAreaContractual  
				JOIN  
					dbo.PR_Pozo	P  
					ON I.WelIID = P.Id  
				JOIN  
					dbo.PR_ProdDiariaPozo_Previo PDP  
					ON P.Id = PDP.Pozo
				JOIN
					#Meses M
					ON	DATEFROMPARTS(YEAR(PDP.FECHA),MONTH(PDP.FECHA),01) = M.Fecha
				WHERE  
					C.IdContrato =   @IdContrato
					AND	I.Activo = 1  
				GROUP BY  
					DATEFROMPARTS(YEAR(PDP.Fecha),MONTH(PDP.Fecha),01), M.CantidadDias

		INSERT INTO #InformacionResultado(Fecha,Anio,Mes,AceiteBrutoProdDiaria,AceiteNetoProdDiaria,GasProdDiaria,AguaProdDiariaBD,AguaProdDiariaPorcentaje,AceiteBrutoProdConc,AceiteNetoProdConc,GasConc,AguaConcBD,AguaConcPorcentaje)
		SELECT							D.Fecha,YEAR(D.Fecha),MONTH(D.Fecha), ISNULL(D.AceiteBrutoProd,0),ISNULL(D.AceiteNetoProd,0),ISNULL(D.GasProd,0),ISNULL(D.AguaProdBD,0),ISNULL(D.AguaProdPorcentaje,0),ISNULL(C.AceiteBrutoProd,0),ISNULL(C.AceiteNetoProd,0),ISNULL(C.GasProd,0),ISNULL(C.AguaProdBD,0),ISNULL(C.AguaProdPorcentaje,0)
		FROM 
			#Meses M
		LEFT JOIN
			#InformacionDiaria	D
			ON M.Fecha = D.Fecha
		LEFT JOIN
			#InformacionConciliada	C
			ON	M.Fecha = C.Fecha
			AND	D.Fecha	=	C.Fecha;

		SELECT * FROM #InformacionResultado
		ORDER BY	Fecha	DESC;
			
END;