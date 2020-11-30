-- =============================================
-- Author:		Reyna Olvera
-- Create date: 13/01/2018
-- Description:	<Description,,>

--20180709   Reyna olvera		modificado para tamblas nuevas de menu
-- =============================================
CREATE PROCEDURE [dbo].[sp_AP_CountParaAdminMenuRolContrato]
	-- Add the parameters for the stored procedure here
@idRol      INT,
@idContrato INT,
@idUsuario  INT = NULL
AS
         BEGIN

             SET NOCOUNT ON;

             DECLARE @idRolContrato INT;

             SELECT @idRolContrato = idRolContrato
             FROM AP_RolPorContrato
             WHERE idContrato = @idContrato
                   AND idRol = @idRol;

--===========================================================

             SELECT MR.IdMenuRol,
                    MR.Visible
             FROM AP_MenuDPorRol MR
                  INNER JOIN AP_MenuD M ON M.menuid = MR.IdMenu
             WHERE MR.IdRol = @idRol
			AND M.Visible=1
			
			    order by M.Orden



         END;


