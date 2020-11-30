-- =============================================
-- Author:		Daniel AC
-- Create date: 13/08/2018
-- Description:	Consulta usuarios de procura 
-- =============================================

CREATE  PROCEDURE [dbo].[SP_ConsultarUsuarioProcura] 
@IdProveedor INT, 
@IdUsuario INT,
@IdContrato INT 
AS
	BEGIN
		SELECT U.IdUsuario,CONCAT(U.Nombre,'/',TU.NombreTipoUsuario) AS Nombre
		FROM dbo.S_Usuario U
		INNER JOIN dbo.S_UsuarioProveedor UP ON UP.IdUsuario=U.IdUsuario
		INNER JOIN dbo.S_TipoUsuario TU ON TU.IdTipoUsuario=U.IdTipoUsuario
		WHERE 
		UP.IdProveedor=@IdProveedor
		AND U.Activo=1	
		GROUP BY  U.IdUsuario,U.Nombre,TU.NombreTipoUsuario
				
	END
