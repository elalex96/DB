
USE [Petrovendor]
GO
IF EXISTS
(
	SELECT 1
	FROM dbo.sysobjects
	WHERE name = 'SP_AD_ActualizarDetalleIteracion'
)
	DROP PROCEDURE SP_AD_ActualizarDetalleIteracion;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Modified date: 05/05/2026
-- Description:	Actualiza el detalle de una iteracion y registra la auditoria de modificacion.
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_ActualizarDetalleIteracion]
	-- Add the parameters for the stored procedure here
	@IdDetalleIteracion INT,
	@DescripcionLarga NVARCHAR(MAX),
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.RegistroIteracionesDetalle
	SET DescripcionLarga = @DescripcionLarga,
		ModificadoPor = @IdUsuario,
		FechaModificado = GETDATE()
	WHERE IdDetalleIteracion = @IdDetalleIteracion
END

