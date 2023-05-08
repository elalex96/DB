CREATE PROCEDURE [dbo].[SP_AP_ModificarPermisosUsuarios]
	@IdUsuarioSession  INT,
	@IdContrato  INT,
	@IdUsuario  INT,
	@IdPermiso  INT,
	@Activo  BIT
AS
BEGIN

	SET NOCOUNT ON;

	IF((SELECT COUNT(1) FROM AP_PermisosUsuarios  WHERE UsuarioID=@IdUsuario AND IdPermiso=@IdPermiso AND idContrato=@idContrato)>0)
	BEGIN
		UPDATE AP_PermisosUsuarios 
		SET BitActivo = @Activo
		WHERE UsuarioID = @IdUsuario 
			AND IdPermiso = @IdPermiso
			AND idContrato = @idContrato
    END
	ELSE
	BEGIN
	INSERT INTO AP_PermisosUsuarios (UsuarioID,
									IdPermiso,
									BitActivo,
									idContrato)
	VALUES (@IdUsuario,@IdPermiso,@Activo, @idContrato)
	END

END
