-- ============================================= 
-- Author:		Pedro Acuña
-- Create date: 11/Jun/2018
-- Description:	se obtienen los usuarios para que puedan ser seleccioandos para que no sean notificados
-- =============================================
-- ============================================= 
-- Author:	Daniel AC
-- Create date: 17/02/2021
-- Description: Se remueve filtro de usuario-rol, ya que solo se necesita el flitro por proveedor
-- =============================================

CREATE PROCEDURE [dbo].[SP_ListaNoNotificacion] @IdProveedor INT
AS
	BEGIN
	

		SELECT U.IdUsuario, U.Nombre, U.Correo
		FROM S_UsuarioProveedor UP
		JOIN S_Usuario AS U
		ON UP.IdUsuario=U.IdUsuario
		JOIN S_Proveedor P 
		ON UP.IdProveedor=P.IdProveedor
		WHERE U.Activo = 1	--> USUARIO ACTIVO				
		AND P.IdProveedor =@IdProveedor
		GROUP BY	U.IdUsuario, U.Nombre, U.Correo
		ORDER BY U.Nombre ASC

END