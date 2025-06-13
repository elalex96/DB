USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_INS_MM_ClienteProyecto'
)
    DROP PROCEDURE USP_INS_MM_ClienteProyecto; 
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Daniel AC
-- Create date: 10-06-2025
-- Description: Agregar registro de MM_ClienteProyecto
-- =============================================
CREATE PROCEDURE [dbo].[USP_INS_MM_ClienteProyecto] 
-- Add the parameters for the stored procedure here
@IdContrato  INT,
@IdUsuario  INT,
@Id INT,
@Nombre NVARCHAR(MAX),
@Activo BIT

AS
BEGIN
SET NOCOUNT ON


	IF @Id = 0
	BEGIN 

		INSERT INTO MM_ClienteProyecto(Nombre,Activo, CreadoEl, CreadoPor)
		VALUES(LTRIM(RTRIM(@Nombre)), @Activo,GETDATE(),@IdUsuario)

	END 
	ELSE 
	BEGIN 

		UPDATE MM_ClienteProyecto
		SET Nombre = LTRIM(RTRIM(@Nombre)),
		Activo = @Activo,
		ModificadoEl =  GETDATE(),
		ModificadoPor = @IdUsuario
		WHERE Id = @Id

	END

END;