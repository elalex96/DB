USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_ENT_ConsultarGrupoUsuarioSeleccionado'
)
    DROP PROCEDURE USP_SEL_ENT_ConsultarGrupoUsuarioSeleccionado;
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <10/10/2024>
-- Description:	<Consulta del usuario en grupos de usuario>
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_ENT_ConsultarGrupoUsuarioSeleccionado]
	-- Add the parameters for the stored procedure here
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	CREATE TABLE #GRUPOIDS(
		IdGruposUsuarios INT
	)
 
	INSERT INTO #GRUPOIDS
	SELECT
		GU.IdGrupo
	FROM EN_GruposUsuarios GU
		JOIN AP_Usuario	U
		ON	GU.IdUsuario = U.UsuarioID
	WHERE U.UsuarioID = @IdUsuario
	GROUP BY GU.IdGrupo
 
	SELECT
		GRUPOS.IdGruposUsuarios,
		US.Usuario,
		(SELECT STUFF(
				(SELECT ', ' + U.Nombre
				FROM EN_GruposUsuarios GU
					JOIN AP_Usuario	U
				ON	GU.IdUsuario	=	U.UsuarioID
				WHERE GU.IdGrupo	=	GRUPOS.IdGruposUsuarios
				FOR XML PATH ('')),
			1,2, '')) AS Integrantes,
		(SELECT 
			COUNT(IdContratoEntregable) 
			FROM EN_Actividad 
			WHERE idUsuario = GRUPOS.IdGruposUsuarios) AS CantEntregables,
		US.IsActivo AS Activo
	FROM #GRUPOIDS AS GRUPOS
		JOIN AP_Usuario AS US
			ON GRUPOS.IdGruposUsuarios = US.UsuarioID
	GROUP BY GRUPOS.IdGruposUsuarios,
		US.Usuario,
		IsActivo;
END
