-- =============================================
-- Author:		<Jose Roman>
-- Create date: <09/02/2018>
-- Description:	<Se agrega una pregunta a una Sección>
-- =============================================
CREATE procedure ME_AgregarPregunta
	@IdSeccion INT,
	@IdTipoRespuesta INT,
	@Pregunta VARCHAR(MAX),
	@Ponderacion FLOAT,
	@AplicaPersonaMoral BIT,
	@RequiereDocumento BIT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	INSERT INTO dbo.ME_Preguntas
	(
	    IdSeccion,
	    IdTipoRespuesta,
	    Pregunta,
	    Ponderacion,
	    AplicaPersonaMoral,
	    RequiereDocumento,
		Activo
	)
	VALUES
	(   @IdSeccion,    -- IdSeccion - int
	    @idTiporespuesta,    -- IdTipoRespuesta - int
	    @Pregunta,   -- Pregunta - varchar(max)
	    @Ponderacion,  -- Ponderacion - float
	    @AplicaPersonaMoral, -- AplicaPersonaMoral - bit
	    @RequiereDocumento,
		1  -- RequiereDocumento - bit
	)
END
