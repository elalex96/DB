-- Stored PROCEDURE
	-- =============================================
	-- Author:		Reyna Olvera
	-- CREATE DATE: 21/12/17
	-- Description:	Para dibujar las areas contractuales con mas de un poligono 
	-- =============================================
	CREATE PROCEDURE [dbo].[CO_DibujaAreasContractualesC] -- ADD the parameters FOR the stored PROCEDURE here
	@idarea INT AS BEGIN -- SET NOCOUNT ON added TO prevent extra result sets FROM
	-- interfering WITH SELECT statements.
SET 
	NOCOUNT ON; IF OBJECT_ID('tempdb..#tablaTemporalcoords') IS NOT NULL 
DROP 
	TABLE #tablaTemporalcoords;
	CREATE TABLE #tablaTemporalcoords( id INT ,cantidadPol INT, cantCoords INT);
	DECLARE @CantPol INT; 
SELECT 
	@CantPol = COUNT (
		DISTINCT(poligono)
	) 
FROM 
	CO_Coordenadas 
WHERE 
	idareacontractual = @idarea; 
IF (@CantPol > 0) 
	BEGIN 
		INSERT INTO #tablaTemporalcoords
			SELECT 
				DISTINCT(Poligono) AS id, 
				@CantPol AS cantidadPol, 
				COUNT(idcoordenada) AS cantCoords 
			FROM 
				CO_Coordenadas 
			WHERE 
				idareacontractual = @idarea 
			GROUP BY 
				Poligono END 
ELSE 
	BEGIN 
		INSERT INTO #tablaTemporalcoords
			SELECT 
				0, 
				@CantPol, 
				0 
			END 
SELECT 
	* 
FROM 
	#tablaTemporalcoords;
	-- INSERT statements FOR PROCEDURE here
	----Creacion tablas para guardar la cantidad de coordenadas por poligono
	--	IF OBJECT_ID('tempdb..#tablaTemporalcoords') IS NOT NULL
	--				DROP TABLE #tablaTemporalcoords;
	--CREATE TABLE #tablaTemporalcoords( id INT PRIMARY KEY IDENTITY(1,1),cantidadPol INT, cantCoords INT);
	---------------------------------
	----@CantPol cuenta la cantidad de poligonos de dicha area contractual
	--			DECLARE @CantPol INT
	--			SELECT @CantPol=COUNT (DISTINCT(poligono))
	--			FROM CO_Coordenadas
	--			WHERE idareacontractual=@idarea;
	-----------------
	------verifica si hay mas de un poligono
	--IF(@CantPol>1)
	--		BEGIN
	--		--@cantCoord sera la variable que nos guarda la cantidad de coordenadas de dicho poligono
	--		DECLARE @cantCoord INT 
	--		-----------------------
	--			DECLARE @i INT
	--			SET @i = 1
	----mientras el contador @i sea menor que la cantidad de poligonos del area contractual
	--			WHILE(@i<=@CantPol)
	--				BEGIN
	--					--cuenta cuantas coordenadas tiene cada poligono
	--					SELECT @cantCoord= COUNT (idcoordenada)
	--					FROM CO_Coordenadas
	--					WHERE idareacontractual=@idarea 
	--					AND poligono=@i
	--			SET @i = @i+ 1
	----guarda las cantidades en la tabla temporal, y de acuerdo al id es el poligono y su cantidad de coordenadas
	--				INSERT INTO #tablaTemporalcoords(cantidadPol,cantCoords)  SELECT @CantPol,  @cantCoord;
	--			END	
	--			SELECT * FROM #tablaTemporalcoords
	--END
	--IF(@CantPol=1)
	--BEGIN
	--INSERT INTO #tablaTemporalcoords(cantidadPol,cantCoords)  SELECT @CantPol,  @cantCoord;
	--SELECT * FROM #tablaTemporalcoords
	--END
	END