-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <28/05/2020>
-- Description:	<Consulta el tablero de jaguar>
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeClavesTablero_Jaguar] --2205,10014
    @idUsuario INT,
    @IdTableroContrato INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


    --SELECT Workbook,
    --       Sheet,
    --       Tabs,
    --       Site,
    --       CASE Site
    --           WHEN '' THEN
    --               ''
    --           ELSE
    --               '/t/' + Site
    --       END AS SiteT,
    --       DNS,
    --       HeightPX,
    --       ISNULL(REPLACE(Parametros COLLATE SQL_Latin1_General_CP1_CI_AS, '##Usuario##', U.Nombre), '') AS Parametros,
    --       CASE
    --           WHEN ISNULL(MuestraToolbar, 0) = 1
    --                AND ISNULL(UserTableau, 'admin') <> 'admin' THEN
    --               'si'
    --           ELSE
    --               'no'
    --       END AS Toolbar,
    --       ISNULL(UserTableau, 'admin') AS UserTableau
    --FROM Adinco.dbo.EN_TableroContrato
    --    JOIN Petrovendor.dbo.S_Usuario U
    --        ON U.IdUsuario = @idUsuario
    --WHERE IdContrato = @idContrato
    --      AND IdTableroContrato = @IdTableroContrato;

    SELECT Workbook,
           Sheet,
           Tabs,
           Site,
           CASE Site
               WHEN '' THEN
                   ''
               ELSE
                   '/t/' + Site
           END AS SiteT,
           DNS,
           HeightPX,
           ISNULL(REPLACE(Parametros COLLATE SQL_Latin1_General_CP1_CI_AS, '##Usuario##', U.Nombre), '') AS Parametros,
           CASE
               WHEN ISNULL(MuestraToolbar, 0) = 1
                    AND ISNULL(UserTableau, 'admin') <> 'admin' THEN
                   'si'
               ELSE
                   'no'
           END AS Toolbar,
           ISNULL(UserTableau, 'admin') AS UserTableau
    FROM Adinco.dbo.EN_TableroContrato
	JOIN Petrovendor.dbo.S_Usuario U 
		ON U.IdUsuario = @idUsuario
    WHERE IdTableroContrato = @IdTableroContrato;



END;
