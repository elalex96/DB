USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SEL_PV_ConsultarPalabrasClavesProveedor'
)
    DROP PROCEDURE SEL_PV_ConsultarPalabrasClavesProveedor; 
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Daniel AC
-- Create date: 15-04-2024
-- Description: Consultar la lista de palabras claves de un proveedor
-- =============================================
CREATE PROCEDURE [dbo].[SEL_PV_ConsultarPalabrasClavesProveedor] 
-- Add the parameters for the stored procedure here
@IdProveedor  INT,
@IdUsuario  INT
AS
BEGIN

SELECT Id,IdCategoria,PalabraClave
FROM PV_PerfilPalabraClave
WHERE Activo = 1
ORDER BY PalabraClave ASC

END;