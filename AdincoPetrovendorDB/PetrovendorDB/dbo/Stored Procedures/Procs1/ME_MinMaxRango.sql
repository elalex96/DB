
create PROCEDURE ME_MinMaxRango
	@IdPregunta INT
AS
BEGIN
	SELECT MIN(ValorMin) AS ValorMinimo, MAX(ValorMax) AS ValorMaximo
	FROM dbo.ME_RespuestasRango 
	WHERE IdPregunta = @IdPregunta
END


