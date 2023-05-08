
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 11/01/2018
-- Description:Extrae lista de menu
--20180709   Reyna olvera		modificado para tamblas nuevas de menu
-- =============================================
-- Autor:				Neri Garcia del Angel
-- Fecha de Edición:	22 de Febrero del 2023
-- Descripción:			Se agrega NOLOCK y se quitan acrónimos de tablas
-- =============================================
CREATE PROCEDURE [dbo].[sp_AP_ListaMenuPorRolContrato] 
@idRol INT,
	@idContrato INT,
	@idUsuario INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT AP_MenuDPorRol.IdMenuRol,
		AP_MenuD.MenuId AS menuId,
		AP_MenuDPorRol.idRol,
		AP_MenuD.InnerHtml AS nombreMenu,
		ISNULL(AP_MenuD.Url, 'HEADER') AS Url,
		AP_MenuDPorRol.visible AS Visible
	FROM AP_MenuDPorRol(NOLOCK)
	INNER JOIN AP_MenuD(NOLOCK) ON AP_MenuDPorRol.IdMenu = AP_MenuD.MenuId
	WHERE AP_MenuDPorRol.IdRol = @idRol
		AND AP_MenuD.Visible = 1
	ORDER BY AP_MenuD.Orden;
END;