-- =============================================
-- Author:		<Jose Roman>
-- Create date: <09/02/2018>
-- Description:	<Se elimina una sección>
-- =============================================
CREATE procedure ME_EliminarSeccion
	@IdSeccion INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	UPDATE dbo.ME_Seccion
	SET Activo = 0
	WHERE IdSeccion = @IdSeccion

END
