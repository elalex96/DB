-- =============================================
-- Author:		DANIEL AC
-- Create date: 24-01-18
-- Description:	Insertar información del flujo de aprobación 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MA_ConsultarFlujosxContrato]
-- Add the parameters for the stored procedure here

@IdContrato	INT=0,
@IdUsuario  INT = 0,
@IdSubcontratista INT =0,
@FechaRegistro DATETIME= '25-01-2017 00:00'

AS
BEGIN
    SET NOCOUNT ON;
	
			SELECT F.IdFlujo,F.Nombre,F.IdTipoOperacion,F.Descripcion,F.IdTipoFlujo, TF.TipoFlujo, TOF.Nombre AS NombreTipoOperacion
			FROM dbo.MA_Flujo AS F			
			INNER JOIN dbo.MA_TipoFlujo AS TF ON TF.IdTipoFlujo=F.IdTipoFlujo
			INNER JOIN dbo.MA_TipoOperacion AS TOF ON TOF.IdTipoOperacion=F.IdTipoOperacion
			WHERE   F.IdContrato=3 AND ISNULL(F.Activo,0)=1 ORDER BY F.Nombre
END;

