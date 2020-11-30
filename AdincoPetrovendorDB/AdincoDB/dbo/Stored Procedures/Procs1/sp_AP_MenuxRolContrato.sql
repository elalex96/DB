-- Stored Procedure

-- =============================================
-- Author:		Reyna Olvera
-- Create date: 09/10/2018
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_AP_MenuxRolContrato]
    -- Add the parameters for the stored procedure here
@idRol      INT,
@idContrato INT,
@idUsuario  INT = NULL
AS
         BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
             SET NOCOUNT ON;
             IF(@idRol = 1)
                 BEGIN
                     SELECT M.Clave
                     FROM AP_MenuPorRol MR
                          JOIN AP_MenuN M ON M.MenuId = MR.IdMenu
                     WHERE MR.IdRol = @idRol
					 And  MR.Visible = 1;--Esto se añadio
                 END;
                 ELSE
                 BEGIN
                     SELECT M.Clave
                     FROM AP_MenuPorRol MR
                          JOIN AP_MenuN M ON M.MenuId = MR.IdMenu
                     WHERE MR.Visible = 1
                           AND MR.IdRol = @idRol;
                 END;
    --SELECT
    -- Insert statements for procedure here
/*
    DECLARE @cont INT = 1,
            @cantidadMenu INT,
            @idRolContrato INT;
    SELECT @idRolContrato = idRolContrato
    FROM AP_RolPorContrato
    WHERE idContrato = @idContrato
          AND idRol = @idRol;
    IF OBJECT_ID('tempdb..#tablaTemporaId') IS NOT NULL
        DROP TABLE #tablaTemporaId;
    CREATE TABLE #tablaTemporaId
    (
        id INT PRIMARY KEY IDENTITY(1, 1),
        menuid INT
    );
    IF OBJECT_ID('tempdb..#tablaTemporaMenus') IS NOT NULL
        DROP TABLE #tablaTemporaMenus;
    CREATE TABLE #tablaTemporaMenus
    (
        id INT PRIMARY KEY IDENTITY(1, 1),
        clave VARCHAR(150)
    );
    SELECT @cantidadMenu = COUNT(menuId)
    FROM AP_MenuPorRolContrato
    WHERE idRolContrato = @idRolContrato;
    INSERT INTO #tablaTemporaId
    (
        menuid
    )
    SELECT menuId
    FROM AP_MenuPorRolContrato
    WHERE idRolContrato = @idRolContrato
          AND Visible = 1;
    IF (@idRol = 1)
    BEGIN
        SELECT Clave
        FROM AP_MenuN;
    END;
    ELSE
    BEGIN
        WHILE (@cont <= @cantidadMenu)
        BEGIN
            INSERT INTO #tablaTemporaMenus
            (
                clave
            )
            SELECT Clave
            FROM AP_MenuN
            WHERE MenuId =
            (
                SELECT menuid FROM #tablaTemporaId WHERE id = @cont
            );
            SET @cont = @cont + 1;
        END;
        SELECT clave
        FROM #tablaTemporaMenus;
    END;
    */

         END;
