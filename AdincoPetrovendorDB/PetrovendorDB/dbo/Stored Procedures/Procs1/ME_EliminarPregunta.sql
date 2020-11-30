-- =============================================
-- Author:		<Jose Roman>
-- Create date: <09/02/2018>
-- Description:	<Se elimina una pregunta>
-- =============================================
CREATE procedure ME_EliminarPregunta
	@IdPregunta INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	UPDATE dbo.ME_Preguntas
	SET Activo = 0
	WHERE IdPregunta = @IdPregunta
END
