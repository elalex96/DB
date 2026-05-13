-- =============================================
-- Author:		<Jose Roman>
-- Create date: <22-03-2018>
-- Description:	<Adaptacion del sp "SP_ReenviarCorreoActivacion" para el login_v3>
-- =============================================

CREATE procedure S_SP_ConsultarDatosCorreoActivacion
	@Correo VARCHAR(500),
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT TOP 1 
		 N.Para,
		 N.Asunto,
		 N.Mensaje,
		 N.De,
		 EC.IdCorreo,
		 EC.IdIdentificacion 
	FROM Adinco.dbo.S_Notificacion N (NOLOCK)
		INNER JOIN dbo.TA_EnvioCorreo EC ON N.IdNotificacion = EC.IdEnvioAdinco
		INNER JOIN dbo.S_Usuario U ON U.IdUsuario = EC.EnviadoPor 
	WHERE EC.IdCorreo = 16
		AND  para = @Correo
END