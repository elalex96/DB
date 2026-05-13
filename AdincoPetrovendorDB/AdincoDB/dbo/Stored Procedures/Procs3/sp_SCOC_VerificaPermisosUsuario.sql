-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181001
-- Description:	Verifica que permisos tiene el usuario para la pantalla de consulta volumenes
-- =============================================
CREATE PROCEDURE sp_SCOC_VerificaPermisosUsuario
	-- Add the parameters for the stored procedure here
	@IdUsuario INT,
	@IdContrato INT
AS
BEGIN
	
	SET NOCOUNT ON;
  SELECT IdPermiso AS PERMISO FROM dbo.AP_PermisosUsuarios WHERE UsuarioID=@IdUsuario AND BitActivo=1
END
