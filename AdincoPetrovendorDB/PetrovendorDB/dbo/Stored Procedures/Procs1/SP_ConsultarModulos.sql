USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_ConsultarModulos'
)
    DROP PROCEDURE SP_ConsultarModulos;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Modified date: 05/05/2026
-- Description:	Se agregan datos de auditoria en la consulta de modulos.
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarModulos]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SELECT M.IdModulo,
           M.NombreModulo,
           ISNULL(StringModuloId, 'Sin identificador') StringModuloId,
           M.URL_MODULO,
            UC.Nombre AS CreadoPor,
            M.CreadoEl,
            UM.Nombre AS ModificadoPor,
            M.ModificadoEl,
            CASE WHEN M.Aplicacion = 1 THEN 'Procura' ELSE 'Petrovendor' END AS Aplicacion
        FROM Modulo M
         LEFT JOIN dbo.S_Usuario UC ON M.CreadoPor = UC.IdUsuario
         LEFT JOIN dbo.S_Usuario UM ON M.ModificadoPor = UM.IdUsuario
    ORDER BY NombreModulo

END
