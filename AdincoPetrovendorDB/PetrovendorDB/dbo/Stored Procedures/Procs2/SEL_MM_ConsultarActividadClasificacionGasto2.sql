USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SEL_MM_ConsultarActividadClasificacionGasto2'
)
    DROP PROCEDURE SEL_MM_ConsultarActividadClasificacionGasto2; 
GO
/****** Object:  StoredProcedure [dbo].[MM_ConsultarPreferenciaContrato]    Script Date: 01/03/2024 12:02:08 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		DANIEL AC
-- Create date: 29/02/2023
-- Description:	Consultar lista de Actividades Clasificaciones Gastos 2 
-- =============================================
CREATE PROCEDURE [dbo].[SEL_MM_ConsultarActividadClasificacionGasto2] 
@IdContrato INT,
@IdUsuario INT,
@ActividadClasificacionGastoId INT NULL
AS
BEGIN	
		SELECT ACG.Id, ACG.Nombre
		FROM MM_ActividadClasificacionGasto2 ACG (NOLOCK)		
		WHERE ACG.Activo =1 
		AND ACG.ActividadClasificacionGastoId = ISNULL(@ActividadClasificacionGastoId,0)
		ORDER BY ACG.Nombre ASC
END