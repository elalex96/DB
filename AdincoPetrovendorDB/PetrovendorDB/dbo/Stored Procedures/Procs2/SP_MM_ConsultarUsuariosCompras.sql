-- =============================================
-- Author:		DANIEL AC 
-- Create date: 17/08/2018
-- Description:	Se agrupo correos para evitar envio masivo al mismo usuario
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarUsuariosCompras]
@IdProveedor int,
@IdTipoUsuario int 
AS
BEGIN
	
	SELECT U.IdUsuario, U.Nombre, U.Correo 
	FROM S_USUARIO AS U
	INNER JOIN S_TipoUsuario AS TU ON TU.IdTipoUsuario = U.IdTipoUsuario 
	INNER JOIN S_UsuarioProveedor AS UP ON UP.IdUsuario = U.IdUsuario 
	INNER JOIN S_Proveedor AS P ON P.IdProveedor = UP.IdProveedor 
	WHERE U.IdTipoUsuario =@IdTipoUsuario AND P.IdProveedor = @IdProveedor  AND U.Activo = 1
	GROUP BY U.IdUsuario, U.Nombre, U.Correo

END

