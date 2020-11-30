-- =============================================
-- Author:		<Jose Roman>
-- Create date: <13/02/2018>
-- Description:	<Se valida si existe el correo>
-- =============================================

CREATE procedure PV_SP_ValidarCorreoUsuario
	@Correo varchar(50),
    @IdUsuario     INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	
	SELECT COUNT(IdUsuario) FROM dbo.S_Usuario WHERE Correo = @Correo AND IdUsuario <> @IdUsuario
	
END