USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SEL_MM_ConsultarClientesProyectos'
)
    DROP PROCEDURE SEL_MM_ConsultarClientesProyectos; 
GO
/****** Object:  StoredProcedure [dbo].[SEL_MM_ConsultarClientesProyectos]    Script Date: 01/03/2024 12:02:08 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		DANIEL AC
-- Create date: 29/02/2023
-- Description:	Consultar lista de Clientes/Proyectos
-- =============================================
CREATE PROCEDURE [dbo].[SEL_MM_ConsultarClientesProyectos] 
@IdContrato INT,
@IdUsuario INT
AS
BEGIN	
		SELECT CP.Id, CP.Nombre
		FROM MM_ClienteProyecto CP (NOLOCK)		
		WHERE CP.Activo =1 
		ORDER BY CP.Nombre ASC
END