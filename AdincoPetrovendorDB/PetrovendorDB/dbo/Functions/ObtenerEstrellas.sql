create function [dbo].[ObtenerEstrellas]  
( @IdProveedorEvaluado int) 
returns INT
AS 
BEGIN   
	DECLARE @Estrellas INT = 5
	DECLARE @PuntajeXEstrella INT
	DECLARE @PuntajeMaximo INT
	DECLARE @EstrellasRecibidas INT = 0
	DECLARE @PuntajeTotalEnvaluacion INT

	DECLARE @IsEvaluado INT
	SET @IsEvaluado = (SELECT COUNT (IdEvaluacionProveedor) FROM EP_EvaluacionProveedor WHERE IsContestada = 1 AND IdProveedorEvaluado = @IdProveedorEvaluado)

	IF (@IsEvaluado != 0)
	BEGIN
		SET @PuntajeTotalEnvaluacion = (SELECT TotalDePuntos FROM EP_EvaluacionProveedor						        								
									WHERE IdProveedorEvaluado = @IdProveedorEvaluado)
									 

	SET @PuntajeMaximo = (SELECT SUM(valor * 3) FROM EP_PregConceptoEvaluar)

	SET @PuntajeXEstrella = (SELECT @PuntajeMaximo/@Estrellas)
	


	SET @EstrellasRecibidas = (@PuntajeTotalEnvaluacion/@PuntajeXEstrella)

	 
	END

	 

   RETURN @EstrellasRecibidas

END 