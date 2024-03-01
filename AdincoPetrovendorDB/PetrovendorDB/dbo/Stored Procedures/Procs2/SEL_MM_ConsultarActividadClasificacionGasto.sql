USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SEL_MM_ConsultarActividadClasificacionGasto'
)
    DROP PROCEDURE SEL_MM_ConsultarActividadClasificacionGasto; 
GO
/****** Object:  StoredProcedure [dbo].[SEL_MM_ConsultarActividadClasificacionGasto]    Script Date: 01/03/2024 12:02:08 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		DANIEL AC
-- Create date: 29/02/2023
-- Description:	Consultar lista de Actividades Clasificaciones Gastos  
-- =============================================
CREATE PROCEDURE [dbo].[SEL_MM_ConsultarActividadClasificacionGasto] 
@IdContrato INT,
@IdUsuario INT
AS
BEGIN	
		SELECT ACG.Id, ACG.Nombre
		FROM MM_ActividadClasificacionGasto ACG (NOLOCK)		
		WHERE ACG.Activo =1 
		ORDER BY ACG.Nombre ASC
END