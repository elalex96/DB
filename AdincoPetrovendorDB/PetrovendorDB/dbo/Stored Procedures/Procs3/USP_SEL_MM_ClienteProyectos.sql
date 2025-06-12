USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_MM_ClienteProyectos'
)
    DROP PROCEDURE USP_SEL_MM_ClienteProyectos; 
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Daniel AC
-- Create date: 10-06-2025
-- Description: Consultar la lista de catalogo de MM_ClienteProyecto 
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_MM_ClienteProyectos] 
-- Add the parameters for the stored procedure here
@IdContrato  INT,
@IdUsuario  INT
AS
BEGIN
SET NOCOUNT ON

	SELECT CP.Id, CP.Nombre, CP.Activo, CP.CreadoEl, CP.ModificadoEl, UC.Nombre CreadoPor,  UE.Nombre  ModificadoPor
	FROM MM_ClienteProyecto CP(NOLOCK)
	LEFT JOIN S_Usuario UC (NOLOCK)
		ON CP.CreadoPor = UC.IdUsuario
	LEFT JOIN S_Usuario UE (NOLOCK)
		ON CP.ModificadoPor  =  UE.IdUsuario
	ORDER BY CP.Nombre ASC


END;