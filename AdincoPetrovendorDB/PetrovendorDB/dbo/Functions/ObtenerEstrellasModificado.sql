CREATE function [dbo].[ObtenerEstrellasModificado]  
(@IdProveedorEvaluado INT) 
returns INT
AS 
BEGIN   


	DECLARE @Estrellas INT = 5
	DECLARE @PuntajeXEstrella INT
	DECLARE @PuntajeMaximo INT
	DECLARE @EstrellasRecibidas INT = 0
	DECLARE @PuntajeTotalEnvaluacion INT
	DECLARE @PromedioGeneral INT = 0

DECLARE @IsEvaluado INT
	SET @IsEvaluado = (SELECT COUNT (IdEvaluacionProveedor) FROM EP_EvaluacionProveedor WHERE EstatusEvaluacion = 1 AND IdProveedorEvaluado = @IdProveedorEvaluado)

	IF (@IsEvaluado != 0)
	BEGIN
	    
		--CREATE TABLE #EstrellasXEvaluacion (IdRow INT IDENTITY(1,1) ,EstrellasXEvaluacion INT, TipoEvaluacion INT)
		DECLARE @EstrellasXEvaluacion TABLE (IdRow INT IDENTITY(1,1) ,EstrellasXEvaluacion INT, TipoEvaluacion INT)
		DECLARE @TipoEvaluaciones TABLE (IdRow INT, IdTipo INT) 
		--CREATE TABLE #TipoEvaluaciones (IdRow INT, IdTipo INT) 

		INSERT INTO @TipoEvaluaciones SELECT DISTINCT 
		                            ROW_NUMBER() OVER(ORDER BY PCE.IdTipoDeEvaluacion  ASC) AS Row#, 
		                            PCE.IdTipoDeEvaluacion
									FROM dbo.EP_EvaluacionProveedor EP 
									INNER JOIN dbo.EP_EvaluacionProveedorDetalle EPD
									ON EPD.IdEvaluacionCabecera = EP.IdEvaluacionProveedor
									INNER JOIN dbo.EP_PregConceptoEvaluar PCE
									ON PCE.IdConceptoEvaluar = EPD.IdConceptoEvaluar
									WHERE EP.IdProveedorEvaluado = @IdProveedorEvaluado
									AND EP.IsActivo = 1
									GROUP BY PCE.IdTipoDeEvaluacion	

									--SELECT * FROM #TipoEvaluaciones
		 
		DECLARE @Cantidad_Evaluaciones INT = (
											 	SELECT DISTINCT COUNT(PCE.IdTipoDeEvaluacion) OVER ()
												FROM dbo.EP_EvaluacionProveedor EP 
												INNER JOIN dbo.EP_EvaluacionProveedorDetalle EPD
												ON EPD.IdEvaluacionCabecera = EP.IdEvaluacionProveedor
												INNER JOIN dbo.EP_PregConceptoEvaluar PCE
												ON PCE.IdConceptoEvaluar = EPD.IdConceptoEvaluar
												WHERE EP.IdProveedorEvaluado = @IdProveedorEvaluado
												AND EP.IsActivo = 1
												GROUP BY PCE.IdTipoDeEvaluacion
											 )
	    DECLARE @contador INT = 1
		WHILE (@contador <= @Cantidad_Evaluaciones)
		BEGIN

		DECLARE @IdTipoDeEvaluacion INT = (SELECT IdTipo FROM @TipoEvaluaciones WHERE IdRow = @contador)
									


		SELECT @PuntajeTotalEnvaluacion =  (
												SELECT (SUM(EP.TotalDePuntos)/COUNT(EP.TotalDePuntos)) AS PuntajeTotal 
												FROM dbo.EP_EvaluacionProveedor EP
												INNER JOIN dbo.EP_EvaluacionProveedorDetalle EPD
												ON EPD.IdEvaluacionCabecera = EP.IdEvaluacionProveedor
												INNER JOIN dbo.EP_PregConceptoEvaluar PCE
												ON PCE.IdConceptoEvaluar = EPD.IdConceptoEvaluar
												WHERE IdProveedorEvaluado = @IdProveedorEvaluado AND PCE.IdTipoDeEvaluacion = @IdTipoDeEvaluacion
												AND EP.IsActivo = 1
										   )

		SET @PuntajeMaximo = (SELECT SUM(valor * 3) FROM EP_PregConceptoEvaluar WHERE IdTipoDeEvaluacion = @IdTipoDeEvaluacion)
		SET @PuntajeXEstrella = (SELECT @PuntajeMaximo/@Estrellas)	
		SET @EstrellasRecibidas = (@PuntajeTotalEnvaluacion/@PuntajeXEstrella)

		INSERT INTO @EstrellasXEvaluacion
		VALUES
		(   
		@EstrellasRecibidas, -- EstrellasXEvaluacion - int
		@IdTipoDeEvaluacion  -- TipoEvaluacion - int
		)

		SET @contador = @contador + 1

        END

		SET @PromedioGeneral = ( SELECT (SUM(EstrellasXEvaluacion)/COUNT(IdRow)) FROM @EstrellasXEvaluacion )
        
	 
	END

	RETURN @PromedioGeneral

END 
