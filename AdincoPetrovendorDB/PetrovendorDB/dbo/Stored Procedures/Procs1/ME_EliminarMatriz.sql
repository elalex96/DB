-- =============================================
-- Author:		<Jose Roman>
-- Create date: <09/02/2018>
-- Description:	<Se elimina una Matriz>
-- =============================================
CREATE procedure ME_EliminarMatriz
	@Id INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	UPDATE dbo.ME_MatrizEvaluacion
	SET Activo = 0
	WHERE IdMatrizEvaluacion = @Id
END
