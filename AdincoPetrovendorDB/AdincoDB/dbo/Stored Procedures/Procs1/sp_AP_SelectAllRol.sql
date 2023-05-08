
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 11/01/2018
-- Description:	Extrae todos los roles
-- =============================================
-- Autor:				Neri Garcia del Angel
-- Fecha de Edición:	22 de Febrero del 2023
-- Descripción:			Se agrega NOLOCK y ardenamiento ASC por Nombre Rol
-- =============================================
CREATE PROCEDURE [dbo].[sp_AP_SelectAllRol] 
@IdContrato INT,
	@IdUsuario INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT idRol,
		Rol AS nombreRol
	FROM AP_ROL (NOLOCK)
	WHERE Activo = 1
		AND Rol <> 'Rol de GRUPO de Usuarios'
	ORDER BY Rol ASC
END