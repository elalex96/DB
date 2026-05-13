USE [Petrovendor]
GO
IF EXISTS
(
	SELECT 1
	FROM dbo.sysobjects
	WHERE name = 'SP_AD_SubirImagenActualizacion'
)
	DROP PROCEDURE SP_AD_SubirImagenActualizacion;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Modified date: 06/05/2026
-- Description:	Actualiza la imagen de la iteracion detalle y registra auditoria de modificacion.
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_SubirImagenActualizacion]
	-- Add the parameters for the stored procedure here
	@IdDetalleIteracion INT,
	@ImagenVideo VARBINARY(MAX),
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.RegistroIteracionesDetalle
	SET ImagenVideo = @ImagenVideo,
		ModificadoPor = @IdUsuario,
		FechaModificado = GETDATE()
	WHERE IdDetalleIteracion = @IdDetalleIteracion

	SELECT COUNT(1) FROM dbo.RegistroIteracionesDetalle WHERE IdDetalleIteracion = @IdDetalleIteracion
END

