-- =============================================
-- Author:		<Jose Roman>
-- Create date: <09/02/2018>
-- Description:	<Se agrega Matriz de evaluacion>
-- =============================================

CREATE procedure ME_AgregarMatriz
	@IdTipoEvaluacion INT,
	@Nombre VARCHAR(MAX),
	@Descripcion VARCHAR(max),
	@IdProveedorEvaluador INT,
	@CreadoPor INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	INSERT INTO dbo.ME_MatrizEvaluacion
	(
	    IdTipoEvaluacion,
	    Nombre,
	    Descripcion,
	    IdProveedorEvaluador,
	    CreadoPor,
	    CreadoEl,
		Activo
	)
	VALUES
	(   @IdTipoEvaluacion,                    -- IdTipoEvaluacion - int
	    @Nombre,                   -- Nombre - varchar(max)
	    @Descripcion,                   -- Descripcion - varchar(max)
	    @IdProveedorEvaluador,                    -- IdProveedorEvaluador - int
	    @CreadoPor,                    -- CreadoPor - int
	    GETDATE(),
		1 -- CreadoEl - smalldatetime
	)
END


