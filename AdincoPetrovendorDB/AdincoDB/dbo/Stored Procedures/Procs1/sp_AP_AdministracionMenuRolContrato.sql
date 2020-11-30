-- =============================================
-- Author:	Reyna Olvera
-- Create date: 12/01/2018
-- Description:	Cambia visibilidad de estatus menu

--20180709   Reyna olvera		modificado para tamblas nuevas de menu
-- =============================================
CREATE PROCEDURE [dbo].[sp_AP_AdministracionMenuRolContrato]
    @MenuPorIds VARCHAR(MAX),
    @idRol INT,
    @idContrato INT,
    @idUsuario INT = NULL
AS
BEGIN

    SET NOCOUNT ON;
    ------------------------------Tables------------------

    IF OBJECT_ID('tempdb..#MenusOrden') IS NOT NULL
        DROP TABLE #MenusOrden;
    CREATE TABLE #MenusOrden
    (
        id INT PRIMARY KEY IDENTITY(1, 1),
        idMenu INT,
        Orden INT,
        ElementId NVARCHAR(MAX),
        idMenuRol INT
    );

    IF OBJECT_ID('tempdb..#Headers') IS NOT NULL
        DROP TABLE #Headers;
    CREATE TABLE #Headers
    (
        idMenuRol INT,
        idMenuRolHeader INT
    );

    IF OBJECT_ID('tempdb..#idMenuRolesT') IS NOT NULL
        DROP TABLE #idMenuRolesT;
    CREATE TABLE #idMenuRolesT
    (
        id INT PRIMARY KEY IDENTITY(1, 1),
        idMenuRolContrato INT
    );
    -----------------------------------------------
    ----Menús enviados y sus papás------------
    DECLARE @cont INT,
            @cantIdRM INT,
            @IdPerfil INT,
            @idSubMenu INT,
            @menupadre INT,
            @intMenupadre INT;
    SET @cont = 1;
    --Apaga todo

    --================================================

    UPDATE AP_MenuDPorRol
    SET Visible = 0
    WHERE IdRol = @idRol;
    --Guarda ID's
    INSERT INTO #idMenuRolesT
    (
        idMenuRolContrato
    )
    SELECT splitdata AS idMenuRolContrato
    FROM [dbo].[fnSplitString](@MenuPorIds, ',');

	SELECT * FROM #idMenuRolesT TMR
	JOIN dbo.AP_MenuDPorRol MR ON TMR.idMenuRolContrato= MR.idMenuRol
	JOIN dbo.AP_MenuD M ON MR.IdMenu=M.MenuId

    SELECT @cantIdRM = COUNT(id)
    FROM #idMenuRolesT;

    UPDATE MR
    SET Visible = 1
    FROM dbo.AP_MenuDPorRol MR
        JOIN #idMenuRolesT MRT
            ON MR.idMenuRol = MRT.idMenuRolContrato
    WHERE MR.IdRol = @idRol;

    UPDATE MR2
    SET Visible = 1
    FROM dbo.AP_MenuDPorRol MR
        JOIN #idMenuRolesT MRT
            ON MR.idMenuRol = MRT.idMenuRolContrato
        JOIN dbo.AP_MenuD M
            ON M.MenuId = MR.IdMenu
        JOIN AP_MenuDPorRol MR2
            ON MR2.IdMenu = M.MenuPadreId
               AND MR2.IdRol = @idRol;

    UPDATE MR2
    SET Visible = 1
    FROM dbo.AP_MenuD M
        JOIN dbo.AP_MenuDPorRol MR
            ON M.MenuId = MR.IdMenu
        JOIN AP_MenuDPorRol MR2
            ON MR2.IdMenu = M.MenuPadreId
    WHERE Url = '#'
          AND MR.Visible = 1
          AND MR.IdRol = @idRol
          AND MR2.IdRol = @idRol;
    ----------------------------------------------------------------------------------------
    ------------------------------PARA HEADERS----------------------------------------------
    INSERT INTO #MenusOrden
    (
        idMenu,
        Orden,
        ElementId,
        idMenuRol
    )
    SELECT MenuId,
           Orden,
           ElementId,
           idMenuRol
    FROM dbo.AP_MenuDPorRol
        JOIN dbo.AP_MenuD
            ON AP_MenuD.MenuId = AP_MenuDPorRol.IdMenu
    WHERE idMenuRol IN (
                              SELECT idMenuRolContrato FROM #idMenuRolesT TMR
							JOIN dbo.AP_MenuDPorRol MR ON TMR.idMenuRolContrato= MR.idMenuRol
							JOIN dbo.AP_MenuD M ON MR.IdMenu=M.MenuId WHERE dbo.AP_MenuD.Class <> 'header'
                       );
    ------------------------------------------------------------------------------------------
    --------------------------------GUARDO HEADERS--------------------------------------------
    INSERT INTO #Headers
    (
        idMenuRol,
        idMenuRolHeader
    )
    SELECT #MenusOrden.idMenuRol,
           MAX(MR.idMenuRol)
    FROM #MenusOrden
        CROSS JOIN dbo.AP_MenuDPorRol MR
        JOIN dbo.AP_MenuD
            ON MenuId = MR.IdMenu
    WHERE #MenusOrden.idMenuRol > MR.idMenuRol
          AND dbo.AP_MenuD.Class = 'header'
          AND #MenusOrden.Orden > dbo.AP_MenuD.Orden
          AND MR.IdRol = @idRol
    GROUP BY #MenusOrden.idMenuRol;

    UPDATE MRH
    SET MRH.Visible = 1
    FROM #Headers
        JOIN dbo.AP_MenuDPorRol MRH
            ON MRH.idMenuRol = #Headers.idMenuRolHeader
        JOIN AP_MenuD M
            ON M.MenuId = MRH.IdMenu;

------------------------------------------------------------------------------------------
END