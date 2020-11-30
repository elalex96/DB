-- =============================================
-- Author:		Daniel AC
-- Create date: 13/08/2018
-- Description:	Cosultar los usuarios de petrovendor 
-- =============================================

CREATE  PROCEDURE [dbo].[SP_ConsultarUsuarioCompras] 

@IdProveedor INT, 
@IdUsuario INT,
@IdContrato INT 
AS
	BEGIN

		SELECT U.IdUsuario, CONCAT(U.Nombre,ISNULL('('+TU.NombreTipoUsuario+')','')) AS Nombre 
		FROM dbo.S_Usuario U
		INNER JOIN dbo.S_UsuarioProveedor UP ON UP.IdUsuario=U.IdUsuario
		INNER JOIN dbo.S_TipoUsuario TU ON TU.IdTipoUsuario=U.IdTipoUsuario
		WHERE 
	    UP.IdProveedor=@IdProveedor
		AND U.Activo=1	
		GROUP BY U.IdUsuario, U.Nombre,TU.NombreTipoUsuario

		-->TU.IdTipoUsuario=5 -->CTE USUARIO DE COMPRAS SELECT * FROM dbo.S_TipoUsuario
				
	END
