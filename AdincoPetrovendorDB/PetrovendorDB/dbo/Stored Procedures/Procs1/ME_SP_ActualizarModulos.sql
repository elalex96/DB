
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <07-03-2018>
-- Description:	<Actualizar modulos>
-- =============================================

CREATE procedure ME_SP_ActualizarModulos
	@IdModulo INT,
	@Modulo varchar(200),
	@IdModuloUrl INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	UPDATE dbo.ME_EG_Modulos
	SET Modulo = @Modulo,
		IdModuloUrl = @IdModuloUrl
	WHERE IdModulo = @IdModulo
END
