
CREATE procedure [dbo].[ME_ActualizarMatriz]
	@Id INT,
	@Nombre VARCHAR(MAX),
	@Descripcion VARCHAR(max)

AS
BEGIN
	UPDATE dbo.ME_MatrizEvaluacion
		SET Nombre = @Nombre,
			Descripcion = @Descripcion
		WHERE IdMatrizEvaluacion = @Id
END

