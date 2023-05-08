
CREATE procedure [dbo].[ME_CalcularResultadoEvaluacion]
	@IdProveedorEvaluado INT,
	@IdMatrizEvaluacion INT,
	@IdPedido int

AS
BEGIN
	DECLARE @Resultado FLOAT,
			@ExisteResultado int

	CREATE TABLE #ResultadoSeccion(Resultado FLOAT)

	INSERT INTO #ResultadoSeccion
	SELECT CAST((SUM(CASE WHEN r.ValorAutorizado is NULL THEN r.ValorRespuesta ELSE r.ValorAutorizado end) * (cast(s.Ponderacion AS float)/100 ))  AS float)
		FROM dbo.ME_Respuestas r
			INNER JOIN dbo.ME_Seccion s ON s.IdSeccion = r.IdSeccion
		WHERE r.IdMatrizEvaluacion = @IdMatrizEvaluacion AND r.IdPedido = @IdPedido AND r.IdProveedorEvaluado = @IdProveedorEvaluado
		GROUP BY r.IdSeccion, s.Ponderacion 

	SET @Resultado = (SELECT SUM(Resultado) FROM #ResultadoSeccion)

	SET @ExisteResultado = (SELECT COUNT(IdResultadoMatriz) FROM dbo.ME_ResultadoMatriz WHERE IdMatrizEvaluacion = @IdMatrizEvaluacion AND IdProveedorEvaluado = @IdProveedorEvaluado AND IdPedido = @IdPedido)
	
	IF(@ExisteResultado = 0)
	begin
		INSERT INTO dbo.ME_ResultadoMatriz
		(
			IdProveedorEvaluado,
			IdMatrizEvaluacion,
			Resultado,
			IdPedido
		)
		VALUES
		(   @IdProveedorEvaluado, -- IdProveedorEvaluado - int
			@IdMatrizEvaluacion, -- IdMatrizEvaluacion - int
			@Resultado,  -- Resultado - int
			@IdPedido
		)
	END
    ELSE
	begin
		UPDATE dbo.ME_ResultadoMatriz
			SET Resultado = @Resultado
			WHERE IdMatrizEvaluacion = @IdMatrizEvaluacion AND IdProveedorEvaluado = @IdProveedorEvaluado AND IdPedido = @IdPedido
    end
END

