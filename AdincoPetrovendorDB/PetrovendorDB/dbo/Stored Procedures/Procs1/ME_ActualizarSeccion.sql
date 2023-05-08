
CREATE procedure [dbo].[ME_ActualizarSeccion]
	@IdSeccion INT,
	@Nombre VARCHAR(MAX),
	@Ponderacion INT 

AS
BEGIN
	UPDATE dbo.ME_Seccion
		SET Nombre = @Nombre,
			Ponderacion = @Ponderacion
		WHERE IdSeccion = @IdSeccion
END
