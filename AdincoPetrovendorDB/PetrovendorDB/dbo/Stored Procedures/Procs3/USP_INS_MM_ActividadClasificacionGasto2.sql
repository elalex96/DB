USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_INS_MM_ActividadClasificacionGasto2'
)
    DROP PROCEDURE USP_INS_MM_ActividadClasificacionGasto2; 
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Daniel AC
-- Create date: 10-06-2025
-- Description: Agregar/Editar registro de MM_ActividadClasificacionGasto2
-- =============================================
CREATE PROCEDURE [dbo].[USP_INS_MM_ActividadClasificacionGasto2] 
@IdContrato  INT,
@IdUsuario  INT,
@Id INT,
@Nombre NVARCHAR(MAX),
@Activo BIT,
@IdActividadClasificacionGasto INT

AS
BEGIN
SET NOCOUNT ON


	IF @Id = 0
	BEGIN 

		INSERT INTO MM_ActividadClasificacionGasto2(Nombre,Activo, CreadoEl, CreadoPor, ActividadClasificacionGastoId)
		VALUES(LTRIM(RTRIM(@Nombre)), @Activo,GETDATE(),@IdUsuario,@IdActividadClasificacionGasto)

	END 
	ELSE 
	BEGIN 

		UPDATE MM_ActividadClasificacionGasto2
		SET Nombre = LTRIM(RTRIM(@Nombre)),
		Activo = @Activo,
		ModificadoEl =  GETDATE(),
		ModificadoPor = @IdUsuario
		WHERE Id = @Id

	END

END;


