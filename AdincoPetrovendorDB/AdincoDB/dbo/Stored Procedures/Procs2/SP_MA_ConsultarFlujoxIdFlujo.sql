-- =============================================
-- Author:		DANIEL AC
-- Create date: 24-01-18
-- Description:	Consultar información del flujo npor IdFlujo
-- =============================================
CREATE PROCEDURE [dbo].[SP_MA_ConsultarFlujoxIdFlujo]
-- Add the parameters for the stored procedure here
@IdFlujo INT,
@IdContrato	INT=0,
@IdUsuario  INT = 0,
@IdSubcontratista INT =0,
@FechaRegistro DATETIME= '25-01-2017 00:00'

AS
BEGIN
    SET NOCOUNT ON;
	
			SELECT F.IdFlujo,F.Nombre,F.IdTipoOperacion,F.Descripcion,F.IdTipoFlujo, TF.TipoFlujo, TOF.Nombre
			FROM dbo.MA_Flujo AS F			
			INNER JOIN dbo.MA_TipoFlujo AS TF ON TF.IdTipoFlujo=F.IdTipoFlujo
			INNER JOIN dbo.MA_TipoOperacion AS TOF ON TOF.IdTipoOperacion=F.IdTipoOperacion
			WHERE f.IdFlujo=@IdFlujo
END;

