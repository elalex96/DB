-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20200206
-- Description:	Usuarios Adinco
-- =============================================
 CREATE PROCEDURE [dbo].[sp_Obten_AP_Grupos]
	@IdContrato INT,
	@IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
	
		SELECT u.UsuarioID,u.Nombre,u.IsActivo
			FROM   
				AP_Usuario U
			JOIN   
				AP_perfilUsuario PU	
				ON U.UsuarioID = PU.UsuarioID 
			JOIN   
				AP_Perfil P			
				ON PU.PerfilID = P.IdPerfil	
				AND P.IdContrato = @IdContrato
			JOIN  
				AP_Rol R				
				ON P.IdRol = R.IdRol
			WHERE R.Rol LIKE 'Rol de GRUPO de Usuarios'
				AND	ISNULL(IsGrupo,0)	=	1
END;

