
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20200206
-- Description:	Usuarios Adinco
-- =============================================

-- =============================================
-- Author:		Daniel AC
-- Create date: 19/01/2022
-- Description:	Optimizacion
-- =============================================
ALTER PROCEDURE [dbo].[sp_Obten_AP_UsuariosContrato]--3,10109,0
	@IdContrato INT,
	@IdUsuario INT,
	@OpcionTodos INT=0
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @IsAdminGeneral INT;
	CREATE TABLE #Usuarios(UsuarioID INT, Usuario VARCHAR(MAX),Nombre VARCHAR(MAX),IsActivo BIT)

		SELECT @IsAdminGeneral =
			CASE @IdContrato
				WHEN 3
					THEN 1
				ELSE
					COUNT(1)
				END
			FROM   AP_Usuario U (NOLOCK)
			JOIN   AP_perfilUsuario PU	(NOLOCK)
			ON U.UsuarioID = PU.UsuarioID AND U.UsuarioID = @IdUsuario
			JOIN   AP_Perfil P (NOLOCK)		
			ON PU.PerfilID = P.IdPerfil	AND P.IdContrato = @IdContrato
			JOIN   AP_Rol R	(NOLOCK)		
			ON P.IdRol = R.IdRol
			WHERE R.Rol LIKE '%Administra%general%Entregabl%'
				AND	ISNULL(IsGrupo,0)	=	0			

IF(@OpcionTodos=1)
BEGIN
	If(@IsAdminGeneral>0)
	BEGIN

			INSERT INTO #Usuarios(UsuarioID, Usuario,Nombre, IsActivo)
			SELECT U.UsuarioID as UsuarioID, U.Usuario as Usuario, U.Nombre ,IsActivo 			
			FROM AP_Usuario AS U  (NOLOCK)
			JOIN AP_PerfilUsuario AS PU  (NOLOCK)
				ON U.UsuarioID = PU.UsuarioID
			JOIN AP_Perfil AS P  (NOLOCK)
				ON PU.PerfilID = P.IdPerfil 
			WHERE P.IdContrato = @IdContrato
			AND	ISNULL(IsGrupo,0)	=	0
			AND U.IsActivo = 1
			GROUP BY U.UsuarioID, U.Usuario, U.Nombre,IsActivo 
			ORDER BY U.Nombre ASC

		    SELECT 0 AS UsuarioID,'TODOS' as Usuario,'TODOS' as Nombre, 1
		    UNION 
		    SELECT UsuarioID, Usuario,Nombre,IsActivo 
			FROM #Usuarios

	END
	ELSE
	BEGIN

		INSERT INTO #Usuarios(UsuarioID, Usuario,Nombre, IsActivo)
		SELECT U.UsuarioID as UsuarioID, U.Usuario as Usuario, Nombre ,IsActivo 		
			FROM AP_Usuario AS U  (NOLOCK)
			JOIN AP_PerfilUsuario AS PU  (NOLOCK)
			ON U.UsuarioID = PU.UsuarioID
			JOIN AP_Perfil AS P  (NOLOCK)
			ON PU.PerfilID = P.IdPerfil 
			WHERE P.IdContrato =@IdContrato
			AND	  U.Usuario NOT LIKE '%@smps%' 
			AND	  U.Usuario NOT LIKE '%@ogss%'
			AND	  U.Usuario NOT LIKE '%@adinco%'
			AND	ISNULL(IsGrupo,0)	=	0
			AND U.IsActivo = 1
		GROUP BY U.UsuarioID, U.Usuario, U.Nombre,IsActivo 
		ORDER BY  U.Nombre ASC

		SELECT 0 AS UsuarioID,'TODOS' as Usuario,'TODOS' as Nombre, 1
		UNION 
		SELECT UsuarioID, Usuario,Nombre,IsActivo 
		FROM #Usuarios


	END
END
ELSE
BEGIN
If(@IsAdminGeneral>0)
	BEGIN
	        SELECT U.UsuarioID as UsuarioID, U.Usuario as Usuario, Nombre ,IsActivo
			FROM AP_Usuario AS U  (NOLOCK)
			JOIN AP_PerfilUsuario AS PU  (NOLOCK)
				ON U.UsuarioID = PU.UsuarioID
			JOIN AP_Perfil AS P  (NOLOCK)
				ON PU.PerfilID = P.IdPerfil 
			WHERE P.IdContrato =@IdContrato
				AND	ISNULL(IsGrupo,0)	=	0
				AND U.IsActivo = 1
			GROUP BY U.UsuarioID, U.Usuario, Nombre,IsActivo 
			ORDER BY U.Nombre ASC
	END
	ELSE
	BEGIN
		SELECT U.UsuarioID as UsuarioID, U.Usuario as Usuario, Nombre ,IsActivo 
			FROM AP_Usuario AS U  (NOLOCK)
			JOIN AP_PerfilUsuario AS PU  (NOLOCK)
				ON U.UsuarioID = PU.UsuarioID
			JOIN AP_Perfil AS P  (NOLOCK)
				ON PU.PerfilID = P.IdPerfil 
			WHERE P.IdContrato =@IdContrato
			AND	  U.Usuario NOT LIKE '%@smps%' 
			AND	  U.Usuario NOT LIKE '%@ogss%'
			AND	  U.Usuario NOT LIKE '%@adinco%'
				AND	ISNULL(IsGrupo,0)	=	0
				AND U.IsActivo = 1
		GROUP BY U.UsuarioID, U.Usuario, Nombre,IsActivo 
		ORDER BY U.Nombre ASC
	END
END
END;

