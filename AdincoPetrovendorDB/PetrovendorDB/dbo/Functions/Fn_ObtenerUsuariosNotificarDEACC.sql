-- =============================================
-- Author: Daniel AC
-- Create date: 14/11/2019
-- Description: obtener los usuarios a notificar DEA por centro de costo separados  comas
-- =============================================

CREATE FUNCTION Fn_ObtenerUsuariosNotificarDEACC
	( @IdCentroCosto INT,
	@TipoNotificacion NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
	BEGIN
		DECLARE @Retorno NVARCHAR(MAX)

		SELECT	@Retorno =
			(SELECT	STUFF(
				(	SELECT		CAST(',' AS VARCHAR(MAX)) + CONVERT ( NVARCHAR(MAX), CCG.IdUsuario )
				FROM		dbo.DEA_UsuariosNotificar AS CCG								
				INNER JOIN	dbo.S_Usuario AS U
					ON U.IdUsuario = CCG.IdUsuario
				INNER JOIN dbo.S_UsuarioProveedor UP ON UP.IdUsuario = U.IdUsuario															
				WHERE U.Activo = 1 
				AND CCG.Activo=1				
				AND CCG.IdCentroCosto=@IdCentroCosto
				AND CCG.TipoNotificacion=@TipoNotificacion
				GROUP BY CCG.IdUsuario,U.Nombre
				ORDER BY U.Nombre ASC 
				FOR XML PATH ( '' )), 1, 1, '' ) AS IdUsuario)

		RETURN @Retorno
	END


