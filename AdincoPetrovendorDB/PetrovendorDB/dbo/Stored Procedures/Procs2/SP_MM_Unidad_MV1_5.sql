-- =============================================
-- Author:		ALEXANDER 
-- Create date: 08/01/2017
-- Description:	 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Unidad_MV1_5] 

--@splitUnidades NVARCHAR(MAX)
	/*--------------------   parametros contrato  --------------------*/
    @IdContrato    INT,
    @IdUsuario     INT,
    @FechaRegistro DATETIME 
  /*----------------------------------------*/

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	     CREATE TABLE #UnidadesTemp (IdRow INT,Unidad int)
		 CREATE TABLE #Unidad(IdRow int,IdUnidad int, Unidad varchar(MAX),Activo bit)
		 INSERT INTO #Unidad(IdRow,IdUnidad, Unidad,Activo)VALUES(0,0,'-- Seleccione una unidad --',1)
		 
		 INSERT INTO  #Unidad
         SELECT 
		 ROW_NUMBER() OVER(ORDER BY IdUnidad ASC),
		 IdUnidad,
		 Unidad,
		 1
         FROM PV_MM_MaterialUnidad as T

		 --INSERT INTO #UnidadesTemp
		 --SELECT
		 --ROW_NUMBER() OVER(ORDER BY Value ASC),
		 --Value 
		 --FROM  dbo.Split(@splitUnidades, ',')

		 --DECLARE @contador INT = 1
		 --DECLARE @cantidadUnidades INT = (SELECT COUNT(Unidad) FROM #UnidadesTemp)
		 
		 --WHILE (@contador <= @cantidadUnidades)
		 --BEGIN

		 --DECLARE @IdUnidad INT = (SELECT Unidad FROM #UnidadesTemp WHERE IdRow = @contador)

		 --IF (@IdUnidad <> 0)
		 --BEGIN
			-- UPDATE #Unidad 
			-- SET 
			-- Activo = 0 
			-- WHERE IdUnidad = @IdUnidad
   --      end

		 --SET @contador = @contador + 1

		 --END  

		 --SELECT * FROM #Unidad
		 SELECT IdUnidad, Unidad  FROM #Unidad WHERE Activo = 1 ORDER BY IdUnidad ASC

END
