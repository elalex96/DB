-- =============================================
-- Author:		Reyna Olvera
-- =============================================
CREATE PROCEDURE sp_JOA_ObtenUsuario --3,10061,0
	@IdContrato int,
	@UsuarioId int,
	@SocioId	int = 0
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ContratistaId INT;

	SELECT @ContratistaId	=	IdContratista FROM CO_Contrato WHERE IdContrato=@IdContrato

	SELECT DISTINCT(U.UsuarioID) as UsuarioID, U.Usuario as usuario, Nombre
		FROM 
			AP_Usuario	U
		JOIN
			AP_PerfilUsuario PU
			ON U.UsuarioID	=	PU.UsuarioID
		JOIN
			AP_Perfil	P
			ON PU.PerfilID	=	P.IdPerfil
		JOIN
			CO_Contrato	C
			ON P.IdContrato	=	C.IdContrato
			AND C.IdContratista	=	@ContratistaId	 
		WHERE 	
			U.IsActivo	=	1	
			AND	IsEliminado	=	0
			AND	ISNULL(IsGrupo,0)	<>	1

		UNION ALL

		SELECT DISTINCT
		UG.UsuarioID,
		 STUFF((
			SELECT ', '  + U.Nombre
			FROM	AP_Usuario U
			INNER	JOIN	EN_GruposUsuarios	GUT	ON U.UsuarioID	=	GUT.IdUsuario 
			WHERE	GUT.IdGrupo	=	GU.IdGrupo
			FOR XML PATH('')),
			1, 2, '')	
			AS	usuario,
			UG.Nombre

			FROM	EN_GruposUsuarios GU
			JOIN	AP_Usuario AS UG
				ON	GU.IdGrupo	=	UG.UsuarioID
			WHERE	GU.Activo	=	1
			  AND	UG.IsActivo	=	1
			  AND	GU.IdContrato	=	@IdContrato

END



