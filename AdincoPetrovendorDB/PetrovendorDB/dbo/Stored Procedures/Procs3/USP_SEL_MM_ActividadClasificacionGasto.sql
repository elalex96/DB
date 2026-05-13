USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_MM_ActividadClasificacionGasto'
)
    DROP PROCEDURE USP_SEL_MM_ActividadClasificacionGasto; 
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Daniel AC
-- Create date: 10-06-2025
-- Description: Consultar la tabla MM_ActividadClasificacionGasto
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_MM_ActividadClasificacionGasto] 
-- Add the parameters for the stored procedure here
@IdContrato  INT,
@IdUsuario  INT
AS
BEGIN
SET NOCOUNT ON


SELECT ACG.Id,ACG.Nombre, ACG.Activo, ACG.CreadoEl, ACG.ModificadoEl,  UC.Nombre CreadoPor,  UE.Nombre  ModificadoPor
FROM MM_ActividadClasificacionGasto ACG (NOLOCK)
LEFT JOIN S_Usuario UC (NOLOCK)
	ON ACG.CreadoPor = UC.IdUsuario
LEFT JOIN S_Usuario UE (NOLOCK)
	ON ACG.ModificadoPor  =  UE.IdUsuario
ORDER BY ACG.Nombre ASC


END;