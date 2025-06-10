USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_INS_ActividadClasificacionGasto'
)
    DROP PROCEDURE USP_INS_ActividadClasificacionGasto; 
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Daniel AC
-- Create date: 10-06-2025
-- Description: Agregar registro de actividad clasificación gasto
-- =============================================
CREATE PROCEDURE [dbo].[USP_INS_ActividadClasificacionGasto] 
-- Add the parameters for the stored procedure here
@IdProveedor  INT,
@IdUsuario  INT,
@Id INT,
@Nombre NVARCHAR(MAX),
@Activo BIT

AS
BEGIN

IF @Id = 0
BEGIN 

INSERT INTO MM_ActividadClasificacionGasto(Nombre,Activo, CreadoEl)
VALUES(@Nombre, @Activo,GETDATE())

END 
ELSE 
BEGIN 

UPDATE MM_ActividadClasificacionGasto
SET Nombre = @Nombre,
Activo = @Activo,
ModificadoEl =  GETDATE()
WHERE Id = @Id

END

END;


