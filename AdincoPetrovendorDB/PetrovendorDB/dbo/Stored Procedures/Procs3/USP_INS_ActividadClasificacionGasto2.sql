USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_INS_ActividadClasificacionGasto2'
)
    DROP PROCEDURE USP_INS_ActividadClasificacionGasto2; 
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
CREATE PROCEDURE [dbo].[USP_INS_ActividadClasificacionGasto2] 
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

INSERT INTO MM_ActividadClasificacionGasto2(Nombre,Activo, CreadoEl)
VALUES(@Nombre, @Activo,GETDATE())

END 
ELSE 
BEGIN 

UPDATE MM_ActividadClasificacionGasto2
SET Nombre = @Nombre,
Activo = @Activo,
ModificadoEl =  GETDATE()
WHERE Id = @Id

END

SELECT AC2.Id, AC2.Nombre, AC2.Activo, AC2.CreadoEl, AC2.ModificadoEl, AC2.Activo
FROM MM_ActividadClasificacionGasto2 AC2

END;


