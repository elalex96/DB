CREATE PROCEDURE [dbo].[SP_ObtenPorcentajesMarkup]
@IdContrato  INT,     
@IdUsuario     INT
AS    
     BEGIN       
         SET NOCOUNT ON;
		 CREATE TABLE #Porcentajes( PorcentajeName VARCHAR(50), Porcentaje FLOAT);

		 INSERT INTO #Porcentajes(PorcentajeName,Porcentaje)VALUES('0%',0);
		 INSERT INTO #Porcentajes(PorcentajeName,Porcentaje)VALUES('3%',3);
		 INSERT INTO #Porcentajes(PorcentajeName,Porcentaje)VALUES('7%',7);

		 SELECT * FROM #Porcentajes
		 
END