-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20200206
-- Description:	Usuarios Adinco
-- =============================================
CREATE PROCEDURE [dbo].[sp_Obten_AP_UsuariosContrato]--3,10061,0
	@IdContrato INT,
	@IdUsuario INT,
	@OpcionTodos INT=0
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @IsAdminGeneral INT;
		SELECT @IsAdminGeneral =
			CASE @IdContrato
				WHEN 3
					THEN 1
				ELSE
					COUNT(1)
				END
			FROM   AP_Usuario U
			JOIN   AP_perfilUsuario PU	ON U.UsuarioID = PU.UsuarioID AND U.UsuarioID = @IdUsuario
			JOIN   AP_Perfil P			ON PU.PerfilID = P.IdPerfil	AND P.IdContrato = @IdContrato
			JOIN   AP_Rol R				ON P.IdRol = R.IdRol
			WHERE R.Rol LIKE '%Administra%general%Entregabl%'
				AND	ISNULL(IsGrupo,0)	=	0
IF(@OpcionTodos=1)
BEGIN
	If(@IsAdminGeneral>0)
	BEGIN
	SELECT 0 AS UsuarioID,'TODOS' as Usuario,'TODOS' as Nombre, 1
		    UNION 
		SELECT U.UsuarioID as UsuarioID, U.Usuario as Usuario, Nombre ,IsActivo 
			FROM AP_Usuario AS U 
			JOIN AP_PerfilUsuario AS PU ON U.UsuarioID = PU.UsuarioID
			JOIN AP_Perfil AS P ON PU.PerfilID = P.IdPerfil 
			WHERE P.IdContrato =@IdContrato
			AND	ISNULL(IsGrupo,0)	=	0
			AND U.IsActivo = 1
			GROUP BY U.UsuarioID, U.Usuario, Nombre,IsActivo 
	END
	ELSE
	BEGIN
		SELECT 0 AS UsuarioID,'TODOS' as Usuario,'TODOS' as Nombre, 1
		    UNION 
		SELECT U.UsuarioID as UsuarioID, U.Usuario as Usuario, Nombre ,IsActivo 
			FROM AP_Usuario AS U 
			JOIN AP_PerfilUsuario AS PU ON U.UsuarioID = PU.UsuarioID
			JOIN AP_Perfil AS P ON PU.PerfilID = P.IdPerfil 
			WHERE P.IdContrato =@IdContrato
			AND	  U.Usuario NOT LIKE '%@smps%' 
			AND	  U.Usuario NOT LIKE '%@ogss%'
			AND	  U.Usuario NOT LIKE '%@adinco%'
			AND	ISNULL(IsGrupo,0)	=	0
			AND U.IsActivo = 1
		GROUP BY U.UsuarioID, U.Usuario, Nombre,IsActivo 
	END
END
ELSE
BEGIN
If(@IsAdminGeneral>0)
	BEGIN
	SELECT U.UsuarioID as UsuarioID, U.Usuario as Usuario, Nombre ,IsActivo
			FROM AP_Usuario AS U 
			JOIN AP_PerfilUsuario AS PU ON U.UsuarioID = PU.UsuarioID
			JOIN AP_Perfil AS P ON PU.PerfilID = P.IdPerfil 
			WHERE P.IdContrato =@IdContrato
				AND	ISNULL(IsGrupo,0)	=	0
				AND U.IsActivo = 1
			GROUP BY U.UsuarioID, U.Usuario, Nombre,IsActivo 
	END
	ELSE
	BEGIN
		SELECT U.UsuarioID as UsuarioID, U.Usuario as Usuario, Nombre ,IsActivo 
			FROM AP_Usuario AS U 
			JOIN AP_PerfilUsuario AS PU ON U.UsuarioID = PU.UsuarioID
			JOIN AP_Perfil AS P ON PU.PerfilID = P.IdPerfil 
			WHERE P.IdContrato =@IdContrato
			AND	  U.Usuario NOT LIKE '%@smps%' 
			AND	  U.Usuario NOT LIKE '%@ogss%'
			AND	  U.Usuario NOT LIKE '%@adinco%'
				AND	ISNULL(IsGrupo,0)	=	0
				AND U.IsActivo = 1
		GROUP BY U.UsuarioID, U.Usuario, Nombre,IsActivo 
	END
END
END;

