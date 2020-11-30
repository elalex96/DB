-- =============================================
-- Author:		Reyna Olvera
-- Create date: 30/05/18
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE EN_BuscaUsuariosContrato_ResponsableInstancia --3,10061,10000
	@IdContrato int,
	@UsuarioId int=0,
	@Estado INT = 0
AS
BEGIN
	/*	10000	Elaboración ó Correción
		10001	Revisión
		10002	Aprobación*/
	SET NOCOUNT ON;
	DECLARE @ContratistaId INT;

	SELECT @ContratistaId	=	IdContratista FROM CO_Contrato WHERE IdContrato=@IdContrato

	IF(@Estado	= 10002)--SIN GRUPOS
	BEGIN
		SELECT DISTINCT(U.UsuarioID) as UsuarioID, U.Usuario as usuario, Nombre 
		FROM	AP_Usuario	AS	U 
		JOIN	AP_PerfilUsuario	AS	PU	
		ON	U.UsuarioID	=	PU.UsuarioID 
		JOIN	AP_Perfil	AS	P	
		ON	PU.PerfilID	=	P.IdPerfil 
		WHERE	P.IdContrato	=	@IdContrato
			AND	U.IsActivo	=	1	
			AND	IsEliminado	=	0
			AND	ISNULL(IsGrupo,0)	<>	1
			AND U.UsuarioID NOT IN (10691)		-- CAMBIO PARA ENI, PARA QUE NO SE ASIGNE NINGUNA ACTIVIDAD A LINO
	END
	ELSE
	BEGIN


	-----####	POR PERFIL ####
		/*SELECT DISTINCT(U.UsuarioID) as UsuarioID, U.Usuario as usuario, Nombre 
		FROM	AP_Usuario	AS	U 
		JOIN	AP_PerfilUsuario	AS	PU	
		ON	U.UsuarioID	=	PU.UsuarioID 
		JOIN	AP_Perfil	AS	P	
		ON	PU.PerfilID	=	P.IdPerfil 
		WHERE	P.IdContrato	=	@IdContrato
			AND	
			U.IsActivo	=	1	
			AND	IsEliminado	=	0
			AND	ISNULL(IsGrupo,0)	<>	1*/


		SELECT DISTINCT(U.UsuarioID) as UsuarioID, U.Usuario as usuario, Nombre--, C.NumeroContrato, P.IdContrato, C.IdContratista  
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
			AND U.UsuarioID NOT IN (10691)		-- CAMBIO PARA ENI, PARA QUE NO SE ASIGNE NINGUNA ACTIVIDAD A LINO


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
END