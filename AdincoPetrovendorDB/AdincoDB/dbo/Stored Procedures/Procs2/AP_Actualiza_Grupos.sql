USE Adinco
GO
DROP PROC IF EXISTS AP_Actualiza_Grupos
GO
-- =============================================
-- Author:		DAVID DE LA CRUZ
-- Create date: 2024/21/02
-- Description:	ACTUALIZACIÓN GRUPO DE USUARIOS 
-- =============================================
CREATE PROCEDURE [dbo].[AP_Actualiza_Grupos]
	@IdContrato INT,
	@IdUsuario INT,
	@UsuarioId INT,
	@Nombre varchar(max),
	@IsActivo bit
AS
BEGIN
    SET NOCOUNT ON;
	
		
		SET NOCOUNT ON;

		UPDATE U
		SET 
			U.Nombre = RTRIM(LTRIM(@Nombre)),
			U.IsActivo = @IsActivo,
			U.ModificadoPor = @IdUsuario,
			U.ModificadoEl = GETDATE()
		FROM 
			AP_Usuario U
		INNER JOIN   
			AP_perfilUsuario PU ON U.UsuarioID = PU.UsuarioID 
		INNER JOIN   
			AP_Perfil P ON PU.PerfilID = P.IdPerfil AND P.IdContrato = @IdContrato
		INNER JOIN  
			AP_Rol R ON P.IdRol = R.IdRol
		WHERE 
			R.Rol LIKE 'Rol de GRUPO de Usuarios' AND
			ISNULL(U.IsGrupo, 0) = 1 AND
			U.UsuarioID = @UsuarioId;
END;