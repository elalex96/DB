USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_MM_ActividadClasificacionGasto2'
)
    DROP PROCEDURE USP_SEL_MM_ActividadClasificacionGasto2; 
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Daniel AC
-- Create date: 10-06-2025
-- Description: Consultar la tabla MM_ActividadClasificacionGasto2
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_MM_ActividadClasificacionGasto2] 
@IdContrato  INT,
@IdUsuario  INT,
@IdActividadClasificacionGasto INT
AS
BEGIN
SET NOCOUNT ON


	SELECT ACG.Id,ACG.Nombre, ACG.Activo, ACG.CreadoEl, ACG.ModificadoEl,  UC.Nombre CreadoPor,  UE.Nombre  ModificadoPor, ACG.ActividadClasificacionGastoId as IdActividadClasificacionGasto
	FROM MM_ActividadClasificacionGasto2 ACG (NOLOCK)
	LEFT JOIN S_Usuario UC (NOLOCK)
		ON ACG.CreadoPor = UC.IdUsuario
	LEFT JOIN S_Usuario UE (NOLOCK)
		ON ACG.ModificadoPor  =  UE.IdUsuario
	WHERE  ACG.ActividadClasificacionGastoId =  @IdActividadClasificacionGasto
	ORDER BY ACG.Nombre ASC


END;