IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'p_AP_UsuarioMenuAccion_Sel'
)
    DROP PROCEDURE p_AP_UsuarioMenuAccion_Sel
GO
CREATE PROC [dbo].[p_AP_UsuarioMenuAccion_Sel]
@pUrl VARCHAR(250),
@pUsuarioId INT
AS
 BEGIN

	SELECT 
		AP_UsuarioMenuAccion.IdUsuario,
		AP_UsuarioMenuAccion.MenuDId,
		AP_UsuarioMenuAccion.IdAccion,
		AP_UsuarioMenuAccion.Permitir
	FROM AP_MenuD (NOLOCK)
	INNER JOIN AP_UsuarioMenuAccion (NOLOCK)
		ON AP_UsuarioMenuAccion.IdUsuario = @pUsuarioId  
			AND AP_MenuD.MenuId = AP_UsuarioMenuAccion.MenuDId
	INNER JOIN AP_Acciones (NOLOCK)
		ON AP_UsuarioMenuAccion.IdAccion = AP_Acciones.IdAccion
	where Url like '%' + ISNULL(@pUrl, '') + '%'
END					    