-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <10-04-18>
-- Description:	<Consulta la cabecera de las nuevas actualizaciones>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Help_ConsultarIteraciones]
@aplicacion NVARCHAR(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	CREATE TABLE #tempRegistros(IdRow INT IDENTITY(1,1),IdIteracion INT ,VersionActual BIT,IsEliminado BIT, 
	Aplicacion NVARCHAR(30),VersionIteracion NVARCHAR(50),Modulo NVARCHAR(MAX),IconoModulo NVARCHAR(MAX),TipoActualizacion NVARCHAR(MAX))
	INSERT INTO #tempRegistros
	(
	  IdIteracion,
      VersionIteracion,
      Modulo,
      IconoModulo,
      VersionActual,
      IsEliminado,
      Aplicacion,
      TipoActualizacion
	)
	SELECT 
	  IdIteracion,
      VersionIteracion,
      Modulo,
      IconoModulo,
      VersionActual,
      IsEliminado,
      Aplicacion,
      TipoActualizacion
		FROM dbo.RegistroIteraciones
		WHERE IsEliminado IS NULL

	DECLARE @count_cards INT = (
								 SELECT COUNT(IdIteracion) FROM #tempRegistros 
								 WHERE VersionActual = 1 AND IsEliminado IS NULL AND Aplicacion = @aplicacion
								 AND VersionIteracion  IN (SELECT max(VersionIteracion) From #tempRegistros) 								  
							   )

   	DECLARE @count_cards_extra INT = (
								 SELECT COUNT(IdIteracion) FROM #tempRegistros 
								 WHERE VersionActual = 1 AND IsEliminado IS NULL AND Aplicacion = @aplicacion
								 AND VersionIteracion  != (SELECT max(VersionIteracion) From #tempRegistros) 								  
							   )

	IF (@count_cards > 0 OR @count_cards_extra > 0)
	BEGIN
		CREATE TABLE #iteracionesTemp(IdRow INT IDENTITY(1,1), IdIteracion INT )
	CREATE TABLE #IteracionesFinal ( IdIteracion INT ,VersionIteracion NVARCHAR(10),Modulo NVARCHAR(max),IconoModulo NVARCHAR(100),FechaRegistro DATETIME,
	VersionActual BIT ,Descripcion NVARCHAR(MAX),TipoActualizacion NVARCHAR(MAX))

	--insertar las iteraciones mas actuales
	INSERT INTO #iteracionesTemp
	(
	 IdIteracion
	)
	SELECT 
	IdIteracion
	FROM 
	#tempRegistros
	WHERE VersionIteracion  IN (SELECT max(VersionIteracion) From #tempRegistros) 
	AND VersionActual = 1 AND IsEliminado IS NULL AND Aplicacion = @aplicacion

	--insertar las iteraciones que no son actuales pero tienen el bit de versionActual = 0
    INSERT INTO #iteracionesTemp
	(
		IdIteracion
	)
	SELECT
		IdIteracion
		FROM #tempRegistros WHERE VersionActual = 1 AND IsEliminado IS NULL
		AND VersionIteracion != (SELECT max(VersionIteracion) From #tempRegistros)
		AND Aplicacion = @aplicacion

    DECLARE @count_cards_final INT = (SELECT COUNT(IdIteracion) FROM #iteracionesTemp)
    DECLARE @contador INT = 1
	WHILE (@contador <= @count_cards_final)
	BEGIN
	
	DECLARE @IdIteracion INT = (SELECT IdIteracion FROM #iteracionesTemp WHERE IdRow = @contador)
	DECLARE @primeraDescripcion NVARCHAR(MAX),@ExisteRegistro INT
												IF EXISTS
													(												
														SELECT TOP 1 ISNULL(rid.DescripcionLarga,'Sin descripción') 
														FROM dbo.RegistroIteraciones ri
														LEFT JOIN dbo.RegistroIteracionesDetalle rid
														ON rid.IdIteracion = ri.IdIteracion
														WHERE rid.IdIteracion = @IdIteracion AND ri.VersionIteracion IN (SELECT max(VersionIteracion) From RegistroIteraciones) 
													)
													 SET @ExisteRegistro = 1
												ELSE
													 SET @ExisteRegistro = 2

	IF (@ExisteRegistro = 1)
	BEGIN
		    SET @primeraDescripcion = (
										SELECT TOP 1 ISNULL(rid.DescripcionLarga,'Sin descripción') 
										FROM dbo.RegistroIteraciones ri
										LEFT JOIN dbo.RegistroIteracionesDetalle rid
										ON rid.IdIteracion = ri.IdIteracion
										WHERE rid.IdIteracion = @IdIteracion AND ri.VersionIteracion IN (SELECT max(VersionIteracion) From RegistroIteraciones) 
									   )
			END
			ELSE
				SET @primeraDescripcion = 'Sin descripción'

	
			INSERT INTO #IteracionesFinal
			(
				IdIteracion,
				VersionIteracion,
				Modulo,
				IconoModulo,
				FechaRegistro,
				VersionActual,
				Descripcion,
				TipoActualizacion
			)
			SELECT IdIteracion,
			VersionIteracion,
			Modulo,
			IconoModulo,
			FechaRegistro,
			VersionActual,
			CASE 
			WHEN LEN(@primeraDescripcion) < 30
			THEN @primeraDescripcion + '...'
			ELSE LEFT(@primeraDescripcion,100) + '...' END AS Descripcion,
			ISNULL(TipoActualizacion,'Ultima actualización')	
			FROM dbo.RegistroIteraciones	
			WHERE  VersionActual = 1 AND IdIteracion = @IdIteracion AND IsEliminado IS NULL

			SET @contador = @contador + 1

			END

			--Buscar cards por versionActual sin validar la versionIteracion mas reciente

			--DECLARE @contador_extras INT = 0
			--DECLARE @iteraciones_extra INT = (SELECT COUNT(IdIteracion) FROM #tempRegistros WHERE VersionActual = 1 AND IsEliminado IS NULL
			--                                  AND VersionIteracion != (SELECT max(VersionIteracion) From #tempRegistros))
	  --      WHILE(@contador_extras <= @iteraciones_extra)
			--BEGIN
				
   --         END



    
			SELECT * FROM #IteracionesFinal
	END

END
