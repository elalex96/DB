USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_CD_ValidarAprobaciónTarea'
)
    DROP PROCEDURE USP_SEL_CD_ValidarAprobaciónTarea;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 30/08/2023
-- Description:	verificar que la tarea esta pendiente o aprobada
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_CD_ValidarAprobaciónTarea]
	-- Add the parameters for the stored procedure here
	@IdTarea INT,
	@IdContrato INT,
	@FechaRegistro DATETIME,
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @PENDIENTE INT = 1,
			@ESTATUS_TAREA INT,
			@PROCEDE_APROBACION BIT = 0;


	SELECT
		@ESTATUS_TAREA = IdEstatus
	FROM TA_Tarea AS T
	WHERE IdTarea = @IdTarea
		AND Activo = 1
		AND ModificadoEl IS NULL
		AND ModificadoPor IS NULL

	IF ISNULL(@ESTATUS_TAREA,0) = @PENDIENTE
	BEGIN
		
		SET @PROCEDE_APROBACION = 1;

	END

	SELECT ISNULL(@PROCEDE_APROBACION,0) AS PROCEDE_APROBACION;

END
