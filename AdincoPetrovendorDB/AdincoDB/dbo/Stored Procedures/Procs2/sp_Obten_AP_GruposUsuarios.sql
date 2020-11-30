CREATE PROCEDURE [dbo].[sp_Obten_AP_GruposUsuarios]
	@IdGrupo INT,
	@IdContrato INT,
	@IdUsuarioSession INT 
AS
BEGIN
	SET NOCOUNT ON;

	SELECT gu.IdGrupo,U.UsuarioID
	FROM
		EN_GruposUsuarios GU
	JOIN
		AP_Usuario	U
		ON	GU.IdUsuario	=	U.UsuarioID
	WHERE
		GU.IdGrupo	=	@IdGrupo
END






