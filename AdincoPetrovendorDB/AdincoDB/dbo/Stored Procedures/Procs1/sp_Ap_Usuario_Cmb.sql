USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_Ap_Usuario_Cmb'
)
    DROP PROCEDURE sp_Ap_Usuario_Cmb;
/****** Object:  StoredProcedure [dbo].[sp_Ap_Usuario_Cmb]    Script Date: 31/01/2024 04:38:05 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Daniel AC
-- Create date: 31/01/2023
-- Description:	Se agrega consulta para mostrar lista de usuarios 
-- =============================================
/****** Object:  StoredProcedure [dbo].[sp_Ap_Usuario_Cmb]    Script Date: 31/01/2024 04:27:44 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Ap_Usuario_Cmb] 
(  
	@IdContrato  int  
)  
AS  
BEGIN  
	
	CREATE TABLE #UsuariosContratoActual(UsuarioID INT,Usuario NVARCHAR(MAX),Nombre NVARCHAR(MAX))

	INSERT INTO #UsuariosContratoActual(UsuarioID,Usuario,Nombre)
	SELECT		u.UsuarioID,  
				u.Usuario,  
				u.Nombre   
	FROM		Ap_Usuario			u  
	INNER JOIN	AP_PerfilUsuario	pu  
	ON			u.UsuarioID			=	pu.UsuarioID
	AND			IsActivo			=	1
	INNER JOIn	AP_Perfil			p  
	ON			pu.PerfilID			=	p.IdPerfil	
	WHERE		p.IdContrato		=	@IdContrato  
	AND			ISNULL(IsGrupo,0)	=	0


	INSERT INTO #UsuariosContratoActual(UsuarioID,Usuario,Nombre)
	SELECT DISTINCT
	   UG.UsuarioID,
		UG.Nombre AS Usuario,
		UG.Nombre
		FROM	EN_GruposUsuarios GU
		JOIN	AP_Usuario AS UG
			ON	GU.IdGrupo	=	UG.UsuarioID
		WHERE	GU.Activo	=	1
			AND	UG.IsActivo	=	1
			AND	GU.IdContrato	= @IdContrato

	SELECT UsuarioID,  
		   Usuario,  
		   Nombre   
	FROM #UsuariosContratoActual
	ORDER BY Nombre ASC 

end  
