-- =============================================
-- Author:		Reyna Olvera
-- Create date: 11/01/2018
-- Description:	Extrae todos los roles
-- =============================================
CREATE PROCEDURE [dbo].[sp_AP_SelectAllRol]--3,10061
	@IdContrato int,
	@IdUsuario int
AS
BEGIN

	SET NOCOUNT ON;
	Select 
		idRol,Rol as nombreRol 
	FROM
		AP_ROL 
	WHERE
		Activo	=	1 
		AND rol <> 'Rol de GRUPO de Usuarios'
END
