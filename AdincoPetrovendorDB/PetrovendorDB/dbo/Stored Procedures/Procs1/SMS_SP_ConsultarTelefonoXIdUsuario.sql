-- =============================================
-- Author:		<Jose Roman>
-- Create date: <21-08-2018>
-- Description:	<Se consulta el telefono por IdUsuario para las notificaciones SMS>
-- =============================================

create PROCEDURE SMS_SP_ConsultarTelefonoXIdUsuario	
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	SELECT ISNULL(Telefono, '')
	FROM dbo.S_Usuario
	WHERE IdUsuario = @IdUsuario
END
