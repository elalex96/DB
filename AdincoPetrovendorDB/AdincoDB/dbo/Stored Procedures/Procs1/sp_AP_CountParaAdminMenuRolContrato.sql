
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 13/01/2018
-- Description:	<Description,,>
--20180709   Reyna olvera		modificado para tamblas nuevas de menu
-- =============================================
-- Autor:				Neri Garcia del Angel
-- Fecha de Edición:	22 de Febrero del 2023
-- Descripción:			Se agrega NOLOCK y se quitan acrónimos de tablas
-- =============================================
CREATE PROCEDURE [dbo].[sp_AP_CountParaAdminMenuRolContrato]
	@idRol INT,
	@idContrato INT,
	@idUsuario INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @idRolContrato INT;

	SELECT @idRolContrato = idRolContrato
	FROM AP_RolPorContrato(NOLOCK)
	WHERE idContrato = @idContrato
		AND idRol = @idRol;

	--===========================================================
	SELECT AP_MenuDPorRol.IdMenuRol,
		AP_MenuDPorRol.Visible
	FROM AP_MenuDPorRol(NOLOCK)
	INNER JOIN AP_MenuD(NOLOCK) ON AP_MenuDPorRol.IdMenu = AP_MenuD.menuid
	WHERE AP_MenuDPorRol.IdRol = @idRol
		AND AP_MenuD.Visible = 1
	ORDER BY AP_MenuD.Orden
END;