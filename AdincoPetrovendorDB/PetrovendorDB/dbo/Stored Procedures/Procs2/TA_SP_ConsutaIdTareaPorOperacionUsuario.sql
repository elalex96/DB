
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <09-01-2018>
-- Description:	<Recupero el IdTarea para la firma electronica
-- =============================================

CREATE procedure TA_SP_ConsutaIdTareaPorOperacionUsuario
	@IdUsuario INT,
	@IdOperacion INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    --@IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
  /*---------------------------------------------------------------*/ 

AS
BEGIN
	SELECT T.IdTarea 
		FROM TA_Tarea AS T
		INNER JOIN TA_TareaOperacion AS TA ON TA.IdTarea =T.IdTarea
		WHERE IdAprobador = @IdUsuario AND TA.IdOperacion = @IdOperacion
END