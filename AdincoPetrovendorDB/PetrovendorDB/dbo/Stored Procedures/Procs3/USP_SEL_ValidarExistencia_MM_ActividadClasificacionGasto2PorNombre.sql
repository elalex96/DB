USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_ValidarExistencia_MM_ActividadClasificacionGasto2PorNombre'
)
    DROP PROCEDURE USP_SEL_ValidarExistencia_MM_ActividadClasificacionGasto2PorNombre; 
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Daniel AC
-- Create date: 10-06-2025
-- Description:Validar si ya existe un registro con el mismo nombre en MM_ActividadClasificacionGasto2
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_ValidarExistencia_MM_ActividadClasificacionGasto2PorNombre] 
-- Add the parameters for the stored procedure here
@ContratoId  INT,
@UsuarioId  INT,
@Nombre NVARCHAR(MAX), 
@Id INT,
@ActividadClasificacionGastoId INT
AS
BEGIN
SET NOCOUNT ON
DECLARE @Count INT = 0

	SELECT @Count = COUNT(Id)
	FROM MM_ActividadClasificacionGasto2 (NOLOCK)
	WHERE LTRIM(RTRIM(UPPER(Nombre)))=LTRIM(RTRIM(@Nombre))
	AND Id <> @Id
	AND ActividadClasificacionGastoId = @ActividadClasificacionGastoId

 SELECT @Count As Cantidad
END;