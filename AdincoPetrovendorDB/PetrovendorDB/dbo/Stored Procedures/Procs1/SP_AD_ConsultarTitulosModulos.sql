USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_AD_ConsultarTitulosModulos'
)
    DROP PROCEDURE SP_AD_ConsultarTitulosModulos;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Modified date: 05/05/2026
-- Description:	Consulta los titulos por modulo e incluye datos de auditoria para el grid de administracion.
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_ConsultarTitulosModulos]
-- Add the parameters for the stored procedure here
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT TM.IdTitulosModulo,
           T.IdTitulo,
           T.NombreTitulo,
           T.NombreSubtitulo,
           M.URL_MODULO,
            T.FechaRegistro,
           UC.Nombre AS CreadoPor,
           UM.Nombre AS ModificadoPor,
           T.ModificadoEl,
           (CASE
                WHEN T.IdIdioma = 1 THEN
                    'ESPAÑOL'
                ELSE
                    'INGLES'
            END
           ) AS IDIOMA,
           CASE
               WHEN M.Aplicacion = 0 THEN
                   'Petrovendor'
               ELSE
                   CASE
                       WHEN M.Aplicacion = 1 THEN
                           'Procura'
                   END
           END AS Aplicacion
    FROM dbo.Titulos AS T
        INNER JOIN dbo.TituloModulo AS TM
            ON TM.IdTitulo = T.IdTitulo
        INNER JOIN dbo.Modulo AS M
            ON M.IdModulo = TM.IdModulo
        LEFT JOIN dbo.S_Usuario AS UC
            ON UC.IdUsuario = T.CreadoPor
        LEFT JOIN dbo.S_Usuario AS UM
            ON UM.IdUsuario = T.ModificadoPor

END
