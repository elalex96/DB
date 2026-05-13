
USE [Petrovendor]
GO
IF EXISTS
(
	SELECT 1
	FROM dbo.sysobjects
	WHERE name = 'SP_AD_ConsultaDetalleModuloIteracion'
)
	DROP PROCEDURE SP_AD_ConsultaDetalleModuloIteracion;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Modified date: 05/05/2026
-- Description:	Consulta el detalle de iteraciones por modulo e incluye datos de auditoria.
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_ConsultaDetalleModuloIteracion] 
	-- Add the parameters for the stored procedure here
	@IdIteracion INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT RID.IdDetalleIteracion,
		   RID.IdIteracion,
		   RID.DescripcionLarga,
		   (CASE WHEN RID.ImagenVideo IS NULL THEN 'SIN CARGAR IMAGEN' ELSE 'IMAGEN CARGADA' END) AS ImagenVideo,
		   RID.FechaRegistro,
		   UC.Nombre AS CreadoPor,
		   UM.Nombre AS ModificadoPor,
		   RID.FechaModificado AS ModificadoEl
	FROM dbo.RegistroIteracionesDetalle RID
		LEFT JOIN dbo.S_Usuario UC
			ON RID.CreadoPor = UC.IdUsuario
		LEFT JOIN dbo.S_Usuario UM
			ON RID.ModificadoPor = UM.IdUsuario
	WHERE RID.IdIteracion = @IdIteracion
		AND RID.IsEliminado = 0
END

