-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarExistenciaEnCatalogo]
--@IdAltaCatalogoProveedor INT, 
--@IdProveedor             INT,
--@IdUsuario               INT
@Descripcion  NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	CREATE TABLE #SPLITSTRING(IdRow INT,Palabra NVARCHAR(MAX))
	
	INSERT INTO #SPLITSTRING SELECT 
	ROW_NUMBER() OVER(ORDER BY Value  ASC) AS Row#,
	Value
	FROM dbo.Split(@Descripcion ,' ')

	DECLARE @WHERE NVARCHAR(MAX) = ''
	DECLARE @SQL_EXISTENTE NVARCHAR(MAX)
	DECLARE @Contador INT = 1
    DECLARE @CountSplit INT = (SELECT COUNT(IdRow) FROM #SPLITSTRING)

	DECLARE @SQL_RESULT NVARCHAR(MAX) 

	WHILE ( @Contador <= @CountSplit )
	BEGIN
	DECLARE @LIKE_WORD NVARCHAR(MAX) = (SELECT Palabra FROM #SPLITSTRING WHERE IdRow = @Contador)
	SET @LIKE_WORD = '''%' + @LIKE_WORD + '%'''

	SET @WHERE = @WHERE + 'TextoCorto' + ' ' + 'LIKE ' +  @LIKE_WORD  + ' AND ' 

	SET @Contador = @Contador + 1
	END 
	--- END WHILE 

	SET @WHERE = LEFT(@WHERE, LEN(@WHERE) - 3)

	SET @SQL_EXISTENTE = 'SELECT COUNT (TextoCorto) AS Encontradas FROM MM_Maestro WHERE ' + @WHERE

	DECLARE @RESULT INT
	DECLARE @tab AS TABLE (condicion INT) 
	INSERT into @tab EXECUTE  sp_executesql @SQL_EXISTENTE

	SET @RESULT = (SELECT * FROM @tab)

	DECLARE @material NVARCHAR(20) = '''material''',
	        @servicio NVARCHAR(20) = '''servicio''',
			@materiales NVARCHAR(20) = '''materiales''',
			@servicios  NVARCHAR(20) = '''servicios'''

	IF (@RESULT = 1)
	BEGIN 
	
	SET @SQL_RESULT = 'SELECT TextoCorto, CASE WHEN IdTipoCatalogoMaestro = 1 THEN ' + @material + ' ELSE ' + @servicio +' END AS Encontradas FROM MM_Maestro WHERE ' + @WHERE
	EXECUTE sp_executesql @SQL_RESULT
	END

	IF (@RESULT > 1)
	BEGIN
	SET @SQL_RESULT = 'SELECT TextoCorto, CASE WHEN IdTipoCatalogoMaestro = 1 THEN ' + @materiales + ' ELSE ' + @servicios +' END AS Encontradas FROM MM_Maestro WHERE ' + @WHERE
	EXECUTE sp_executesql @SQL_RESULT
	END

	-------------------------
    IF (@RESULT = 0)
	BEGIN
	--CREATE TABLE #SPLITSTRING2(IdRow INT,Palabra NVARCHAR(MAX))
	--INSERT INTO #SPLITSTRING2 SELECT 
	--ROW_NUMBER() OVER(ORDER BY Value  ASC) AS Row#,
	--Value
	--FROM dbo.Split(@Descripcion ,' ')

	--SET @WHERE = ''
	--SET @SQL_RESULT = ''
	--SET @LIKE_WORD =  ''
	--WHILE ( @Contador <= @CountSplit )
	--BEGIN
	--SET @LIKE_WORD  = (SELECT Palabra FROM #SPLITSTRING2 WHERE IdRow = @Contador)
	--SET @LIKE_WORD = '''%' + @LIKE_WORD + '%'''

	--SET @WHERE = @WHERE + 'TextoCorto' + ' ' + 'LIKE ' +  @LIKE_WORD  + ' OR ' 

	--SET @Contador = @Contador + 1
	--END 
	----- END WHILE 
	--SET @WHERE = LEFT(@WHERE, LEN(@WHERE) - 2)
	--SET @SQL_RESULT = 'SELECT TextoCorto AS Encontradas FROM MM_Maestro WHERE ' + @WHERE
	--EXECUTE sp_executesql @SQL_RESULT
	SELECT 'NO_ENCONTRADO' AS Encontrado,'VACIO' AS Campo
	END


END

