-- =============================================
-- Author:		<Jose Roman>
-- Create date: <09/02/2018>
-- Description:	<Se agrega Seccion(Evaluacion) a una Matriz>
-- =============================================
CREATE procedure ME_AgregarSeccion
	@IdMatrizEvaluacion INT,
	@Nombre VARCHAR(MAX),
	@Ponderacion int,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	INSERT INTO dbo.ME_Seccion
	(
	    IdMatrizEvaluacion,
	    Nombre,
	    Ponderacion,
		Activo
	)
	VALUES
	(   @IdMatrizEvaluacion,  -- IdMatrizEvaluacion - int
	    @Nombre, -- Nombre - varchar(max)
	    @Ponderacion,
		1   -- Ponderacion - int
	)
END
