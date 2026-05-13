USE [Petrovendor]
GO
IF EXISTS
(
	SELECT 1
	FROM dbo.sysobjects
	WHERE name = 'SP_AD_ActualizarIteracion'
)
	DROP PROCEDURE SP_AD_ActualizarIteracion;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Modified date: 05/05/2026
-- Description:	Se agrega auditoria de usuario a la edicion de iteraciones.
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_ActualizarIteracion]
	-- Add the parameters for the stored procedure here
	@IdIteracion INT,
	@VersionIteracion NVARCHAR(MAX),
	@Modulo NVARCHAR(MAX),
	@TipoActualizacion NVARCHAR(MAX),
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.RegistroIteraciones
	SET VersionIteracion = @VersionIteracion,
		Modulo = @Modulo,
		TipoActualizacion = @TipoActualizacion,
		ModificadoPor = @IdUsuario,
		ModificadoEl = GETDATE()
	WHERE IdIteracion = @IdIteracion
END
