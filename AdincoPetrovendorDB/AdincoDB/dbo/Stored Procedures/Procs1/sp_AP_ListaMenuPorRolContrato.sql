-- =============================================
-- Author:		Reyna Olvera
-- Create date: 11/01/2018
-- Description:Extrae lista de menu
--20180709   Reyna olvera		modificado para tamblas nuevas de menu
-- =============================================
CREATE PROCEDURE [dbo].[sp_AP_ListaMenuPorRolContrato]--17,3
-- Add the parameters for the stored procedure here
@idRol      INT, 
@idContrato INT, 
@idUsuario  INT = NULL
AS
     BEGIN
         SET NOCOUNT ON;

         --===================================================

         SELECT IdMenuRol, 
                M.MenuId AS menuId, 
                MR.idRol, 
                M.InnerHtml AS nombreMenu, 
                ISNULL(M.Url, 'HEADER') AS Url, 
                MR.visible AS Visible
         FROM AP_MenuDPorRol MR
              INNER JOIN AP_MenuD M ON MR.IdMenu = M.MenuId
         WHERE MR.IdRol = @idRol
               AND M.Visible = 1
         ORDER BY M.Orden;
     END;