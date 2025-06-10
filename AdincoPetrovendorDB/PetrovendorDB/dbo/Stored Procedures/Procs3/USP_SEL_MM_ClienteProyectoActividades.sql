USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_MM_ClienteProyectoActividades'
)
    DROP PROCEDURE USP_SEL_MM_ClienteProyectoActividades; 
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Daniel AC
-- Create date: 10-06-2025
-- Description: Consultar la lista de catalogo de clientes-proyectos y actividades
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_MM_ClienteProyectoActividades] 
-- Add the parameters for the stored procedure here
@IdProveedor  INT,
@IdUsuario  INT,
@ActividadId INT,
@Consulta NVARCHAR(MAX)
AS
BEGIN

IF @Consulta = 'PROYECTOS'
BEGIN 

SELECT Id, Nombre, Activo, CreadoEl, ModificadoEl
FROM MM_ClienteProyecto 

END 


IF @Consulta = 'ACTIVIDAD-CLASIFICACIONES'
BEGIN 

SELECT Id, Nombre, Activo, CreadoEl, ModificadoEl
FROM MM_ActividadClasificacionGasto 

END 

IF @Consulta = 'ACTIVIDAD-CLASIFICACIONES-2'
BEGIN 

SELECT AC2.Id, AC2.Nombre, AC2.Activo, AC2.CreadoEl, AC2.ModificadoEl, AC2.Activo
FROM MM_ActividadClasificacionGasto2 AC2

END 

END;


