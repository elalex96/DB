
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <07-03-2018>
-- Description:	<Actualizar rubros>
-- =============================================

CREATE procedure ME_SP_ActualizarRubros
	@IdRubro INT,
	@Rubro VARCHAR(200),
	@Puntos FLOAT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	UPDATE dbo.ME_EG_Rubros
	SET Rubro = @Rubro,
		Puntos = @Puntos
	WHERE IdRubro = @IdRubro
END
