CREATE PROCEDURE [dbo].[sp_GuardaElimina_AP_GruposUsuarios]
	@IdGrupo INT,
	@UsuarioID	INT,
	@OpcionEliminar	INT,
	@IdContrato INT,
	@IdUsuarioSession INT 
AS
BEGIN
	SET NOCOUNT ON;

	IF(@OpcionEliminar	=	0)
	BEGIN
		IF((SELECT COUNT(1) FROM EN_GruposUsuarios WHERE IdGrupo=@IdGrupo AND IdUsuariO=@UsuarioID AND IdContrato=@IdContrato)=0)
		BEGIN
			INSERT INTO EN_GruposUsuarios(IdGrupo,IdUsuario,IdContrato,CreadoPor,CreadoEn,Activo)
			VALUES	(@IdGrupo,@UsuarioID,@IdContrato,@IdUsuarioSession,GETDATE(),1)
		END
	END
	ELSE
	BEGIN
		DELETE
		FROM
			EN_GruposUsuarios
		WHERE 
			IdGrupo=@IdGrupo 
			AND IdUsuariO=@UsuarioID 
			AND IdContrato=@IdContrato
	END

END
