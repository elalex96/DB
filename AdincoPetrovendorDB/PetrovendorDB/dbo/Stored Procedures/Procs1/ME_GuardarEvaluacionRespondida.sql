
CREATE procedure ME_GuardarEvaluacionRespondida
	@IdProveedorEvaluado INT,
	@IdMatrizEvaluacion INT,
	@IdSeccion INT,
	@IdPregunta INT,
	@Respuesta VARCHAR(MAX),
	@RespondidoPor INT,
	@IdTipoRespuesta INT,
	@IdPedido INT

AS
BEGIN
	DECLARE @Valor FLOAT,
			@Ponderacion FLOAT

	SET @Ponderacion = (SELECT Ponderacion FROM dbo.ME_Preguntas WHERE IdPregunta = @IdPregunta)
	    
	IF(@IdTipoRespuesta = 2)
	BEGIN
		SET @Valor = (SELECT Valor FROM dbo.ME_RespuestasOpciones WHERE IdPregunta = @IdPregunta AND IdRespuestasOpciones = CAST(@Respuesta AS INT))
	END	

	IF(@IdTipoRespuesta = 3)
	BEGIN
		SET @Valor = (SELECT Valor FROM dbo.ME_RespuestasRango WHERE IdPregunta = @IdPregunta AND (CAST(@Respuesta AS INT) >= ValorMin AND CAST(@Respuesta AS INT) <= ValorMax))
    END

	SET @Valor = @Valor * @Ponderacion
	SET @Valor = @Valor / 10

	
	IF(@IdTipoRespuesta = 1)
	BEGIN
	IF(@Respuesta = '1')
		BEGIN
			SET @Valor = @Ponderacion
		END
        ELSE
        BEGIN
			SET @Valor = 0
		end
    END

	INSERT INTO dbo.ME_Respuestas
	(
	    IdProveedorEvaluado,
	    IdMatrizEvaluacion,
	    IdSeccion,
	    IdPregunta,
	    Respuesta,
	    RespondidoPor,
	    RespondidoEl,
		ValorRespuesta,
		IdPedido
	)
	VALUES
	(   @IdProveedorEvaluado,  -- IdProveedorEvaluado - int
	    @IdMatrizEvaluacion,   -- IdMatrizEvaluacion - int
	    @IdSeccion,            -- IdSeccion - int
	    @IdPregunta,           -- IdPregunta - int
	    @Respuesta,            -- Respuesta - varchar(max)
	    @RespondidoPor,        -- RespondidoPor - int
	    GETDATE(),			   -- RespondidoEl - smalldatetime
		ISNULL(@Valor, 0.0),
		@IdPedido
	)
END