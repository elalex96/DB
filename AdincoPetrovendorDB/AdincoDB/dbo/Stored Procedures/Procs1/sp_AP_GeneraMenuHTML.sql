
create PROCEDURE [dbo].[sp_AP_GeneraMenuHTML] 
	-- Add the parameters for the stored procedure here
	-- =============================================
-- Author:		Miguel Gomez
-- Create date: 09062018
-- Description:	Lista el menu por usuario en html
-- =============================================
@IdRol      INT = 0,
@IdContrato INT = 0,
@IdUsuario  INT = 0
AS
     BEGIN
         DECLARE @Menu AS NVARCHAR(MAX);


         --SELECT @Menu = COALESCE(@Menu + CHAR(13), '')+M.html
	    SELECT @Menu = COALESCE(@Menu , '')+M.html
         --SELECT *
	    FROM dbo.AP_MenuN M
	    JOIN dbo.AP_MenuPorRol MR ON MR.IdMenu  = m.MenuId
         WHERE M.html IS NOT NULL AND MR.IdRol = @IdRol
	    ORDER BY M.Orden asc
         SELECT @Menu;
     END;

